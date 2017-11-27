//--------------------------------------------------------------------------------
// Project    : SWITCH
// File       : rx_engine.v
// Version    : 0.1
// Author     : Vipin.K
//
// Description: 64 bit PCIe transaction layer receive unit
//
//--------------------------------------------------------------------------------

`timescale 1ns/1ns

module rx_engine  #(
  parameter C_DATA_WIDTH  = 256,                                 // RX interface data width
  parameter FPGA_ADDR_MAX = 'h400,
  parameter KEEP_WIDTH    = C_DATA_WIDTH / 32
) (
  input                         clk_i,                           // 250Mhz clock from PCIe core
  input                         rst_n,                           // Active low reset
  // AXI-S
  // Completer Request Interface
  input      [C_DATA_WIDTH-1:0] m_axis_cq_tdata,
  input                         m_axis_cq_tlast,
  input                         m_axis_cq_tvalid,
  input                  [84:0] m_axis_cq_tuser,
  input        [KEEP_WIDTH-1:0] m_axis_cq_tkeep,
  output reg                    m_axis_cq_tready,
  output                        pcie_cq_np_req,
  // Requester Completion Interface
  input      [C_DATA_WIDTH-1:0] m_axis_rc_tdata,
  input                         m_axis_rc_tlast,
  input                         m_axis_rc_tvalid,
  input        [KEEP_WIDTH-1:0] m_axis_rc_tkeep,
  input                  [74:0] m_axis_rc_tuser,
  output                        m_axis_rc_tready,
  //Tx engine
  input                         compl_done_i,                    // Tx engine indicating completion packet is sent
  output reg [1:0]              addr_type_o,                     // Address type for the received packet
  output reg                    req_compl_wd_o,                  // Request Tx engine for completion packet transmission 
  output reg [31:0]             tx_reg_data_o,                   // Data for completion packet              
  output reg [2:0]              req_tc_o,                        // Memory Read TC
  output reg [2:0]              req_attr_o,                      // Memory Read Attribute
  output reg [10:0]             req_len_o,                       // Memory Read Length (1DW)
  output reg [15:0]             req_rid_o,                       // Memory Read Requestor ID
  output reg [7:0]              req_tag_o,                       // Memory Read Tag
  output reg [6:0]              req_addr_o,                      // Memory Read Address
  //Register file
  output reg [31:0]             reg_data_o,                      // Write data to register
  output reg                    reg_data_valid_o,                // Register write data is valid
  output reg [9:0]              reg_addr_o,                      // Register address
  input                         fpga_reg_wr_ack_i,               // Register write acknowledge
  output reg                    fpga_reg_rd_o,                   // Register read enable
  input      [31:0]             reg_data_i,                      // Register read data
  input                         fpga_reg_rd_ack_i,               // Register read acknowledge
  output reg [7:0]              cpld_tag_o,
  //User interface
  output reg [31:0]             user_data_o,                     // User write data
  output reg                    user_wr_req_o,                   // User write request
  input                         user_wr_ack_i,                   // Write command ack
  input      [31:0]             user_data_i,                     // User read data
  input                         user_rd_ack_i,                   // User read acknowledge 
  output reg                    user_rd_req_o,                   // User read request
  //DDR interface
  output reg [C_DATA_WIDTH-1:0] rcvd_data_o,                     // Memory ready completion data after DMA read request
  output reg                    rcvd_data_valid_o                // Completion data is valid
);

   ///* synthesis translate_off */

   // Local Registers
	wire               sop;
	wire               c_sop;
	reg [2:0]          state;
	reg [2:0]          rcv_state;
	reg                in_packet_q;
	reg                c_in_packet_q;
	reg [159:0]        rx_tdata_p;
	reg                rcv_data;
	reg                lock_tag;
	reg                user_wr_ack;
	 
   // State Machine state declaration
	localparam  IDLE           = 'd0,
		    WAIT_FPGA_DATA = 'd1,
		    WAIT_USR_DATA  = 'd2,
		    WAIT_TX_ACK    = 'd3,
		    WAIT_USER_ACK  = 'd4,
		    RX_DATA        = 'd5;
					
   // TLP packet type encoding
	localparam  MEM_RD = 4'b0000,
				MEM_WR = 4'b0001;
					
    assign sop              = !in_packet_q && m_axis_cq_tvalid;   //start of a new packet on completer request interface
    assign c_sop            = !c_in_packet_q && m_axis_rc_tvalid; //start of a new packet on requester complete interface
    assign m_axis_rc_tready = 1'b1;                               //never back-pressure completion interface
    assign pcie_cq_np_req   = 1'b1;                               //always ready to accept non-posted requests

    // Generate a signal that indicates if we are currently receiving a packet.
    // This value is one clock cycle delayed from what is actually on the AXIS
    // data bus.
    always@(posedge clk_i)
    begin
      if (m_axis_cq_tvalid && m_axis_cq_tready && m_axis_cq_tlast)
        in_packet_q <= 1'b0;
      else if (sop && m_axis_cq_tready)
        in_packet_q <= 1'b1;
    end
	
	
    always@(posedge clk_i)
    begin
      if (m_axis_rc_tvalid && m_axis_rc_tready && m_axis_rc_tlast)
        c_in_packet_q <= 1'b0;
      else if (c_sop && m_axis_rc_tready)
        c_in_packet_q <= 1'b1;
    end
	 
	initial
	begin
		m_axis_cq_tready <=  1'b0;
		req_compl_wd_o   <=  1'b0;
		state            <=  IDLE;
		user_rd_req_o    <=  1'b0;
		user_wr_req_o    <=  1'b0;
		rcv_data         <=  1'b0;
		fpga_reg_rd_o    <=  1'b0;
		reg_data_valid_o <=  1'b0;
		in_packet_q      <=  1'b0;
		rcv_state        <=  IDLE;
		c_in_packet_q    <=  1'b0;
	end

   					
	//The receive state machine
    always @ ( posedge clk_i ) 
    begin
        case (state)
            IDLE : begin
                m_axis_cq_tready <=  1'b1;                  // Indicate ready to accept TLPs
                reg_data_valid_o <=  1'b0;
		user_wr_req_o    <=  1'b0;
		addr_type_o      <=  m_axis_cq_tdata[1:0];
		req_addr_o       <=  m_axis_cq_tdata[8:2];
		req_len_o        <=  m_axis_cq_tdata[74:64];  // Place the packet info on the bus for Tx engine
		req_rid_o        <=  m_axis_cq_tdata[95:80];
		req_tag_o        <=  m_axis_cq_tdata[103:96];
		req_tc_o         <=  m_axis_cq_tdata[123:121];
                req_attr_o       <=  m_axis_cq_tdata[126:124];
                reg_addr_o       <=  {m_axis_cq_tdata[9:2],2'b00};
		reg_data_o       <=  m_axis_cq_tdata[159:128];
	        user_data_o      <=  m_axis_cq_tdata[159:128];
               
                if (sop) 
                begin         
                    m_axis_cq_tready   <=  1'b0;             // Valid data on the bus
		    if(m_axis_cq_tdata[78:75] == MEM_RD)    // If memory ready request
		    begin
                        if({m_axis_cq_tdata[11:2],2'b00} != 'h24) // 24 in PIO data reg address
                        begin
                            state         <=  WAIT_FPGA_DATA; 
                            fpga_reg_rd_o <=  1'b1;   
                        end
                        else                    
                        begin
                            state         <=  WAIT_USR_DATA;
                            user_rd_req_o <=  1'b1;
                        end
	            end   
                    else if(m_axis_cq_tdata[78:75] == MEM_WR) // If memory write request
                    begin
		        if({m_axis_cq_tdata[11:2],2'b00} != 'h24)  // If the data is intended for global registers 24 in PIO data reg address
                        begin  
                            reg_data_valid_o <=   1'b1;    
                        end
                        else
                        begin
                            user_wr_req_o    <=   1'b1;
                            state            <=   WAIT_USER_ACK;
                        end					
                    end		
                end
            end

            WAIT_FPGA_DATA:begin
	     		fpga_reg_rd_o    <=  1'b0; 
                if(fpga_reg_rd_ack_i)
                begin 
                    req_compl_wd_o   <=  1'b1;        //Request Tx engine to send data
                    tx_reg_data_o    <=  reg_data_i;
                    state            <=  WAIT_TX_ACK; //Wait for ack from Tx engine for data sent
                end
            end
            WAIT_USR_DATA:begin
                user_rd_req_o  <=  1'b0;
                if(user_rd_ack_i)
                begin
                    req_compl_wd_o <=  1'b1;
                    tx_reg_data_o  <=  user_data_i;
	            state          <=  WAIT_TX_ACK;
                end
            end
            WAIT_USER_ACK:begin
                if(user_wr_ack_i)
                begin
                    user_wr_req_o    <=   1'b0;
                    state            <=   IDLE;
                end
            end
            WAIT_TX_ACK: begin
                if(compl_done_i)
                begin
                    state            <=  IDLE;
                    req_compl_wd_o   <=  1'b0;
		    m_axis_cq_tready <=  1'b1;
                end
            end
        endcase
    end
	
	
    //The receive state machine
    always @ ( posedge clk_i ) 
    begin
        case (rcv_state)
            IDLE : begin
                if (c_sop) 
                begin                       // Valid data on the bus
                    rcv_state  <=  RX_DATA;
					     cpld_tag_o <=  m_axis_rc_tdata[71:64];
						  rcv_data   <=  1'b1;
                end
            end	
            RX_DATA:begin
                if(m_axis_rc_tlast)
                begin
                    rcv_data  <=  1'b0;
                    rcv_state <=  IDLE;
                end
            end
		endcase
    end		

    //Packing data from the received completion packet. Required since the TLP header is 3 DWORDs.
    always @(posedge clk_i)
    begin
        rx_tdata_p <= m_axis_rc_tdata[255:96];
        if(rcv_data & m_axis_rc_tvalid)
        begin
            rcvd_data_valid_o <= 1'b1;   
            rcvd_data_o       <= {m_axis_rc_tdata[95:0],rx_tdata_p};
        end
        else
            rcvd_data_valid_o <= 1'b0;
    end

	 
endmodule 

