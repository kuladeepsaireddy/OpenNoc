//--------------------------------------------------------------------------------
// Project    : SWITCH
// File       : tx_engine.v
// Version    : 0.1
// Author     : Vipin.K
//
// Description: 256 bit PCIe transaction layer transmit unit
//
//--------------------------------------------------------------------------------

`timescale 1ns/1ns

module tx_engine    #(
  // TX interface data width
  parameter C_DATA_WIDTH = 256,
  parameter KEEP_WIDTH = C_DATA_WIDTH/32
)(

  input                           clk_i,
  input                           rst_n,

  // AXI-S Completer Competion Interface

  output reg [C_DATA_WIDTH-1:0]  s_axis_cc_tdata,
  output reg   [KEEP_WIDTH-1:0]  s_axis_cc_tkeep,
  output reg                     s_axis_cc_tlast,
  output reg                     s_axis_cc_tvalid,
  output                 [32:0]  s_axis_cc_tuser,
  input                          s_axis_cc_tready,

  // AXI-S Requester Request Interface

  output reg [C_DATA_WIDTH-1:0]  s_axis_rq_tdata,
  output reg   [KEEP_WIDTH-1:0]  s_axis_rq_tkeep,
  output reg                     s_axis_rq_tlast,
  output reg                     s_axis_rq_tvalid,
  output reg             [59:0]  s_axis_rq_tuser,
  input                          s_axis_rq_tready,
  //Rx engine
  input [1:0]                    addr_type_i, 
  input                          req_compl_wd_i,
  output reg                     compl_done_o,
  input [2:0]                    req_tc_i,
  input [2:0]                    req_attr_i,
  input [10:0]                   req_len_i,
  input [15:0]                   req_rid_i,
  input [7:0]                    req_tag_i,
  input [6:0]                    req_addr_i,
  //Register set
  input [31:0]                   reg_data_i,
  input                          config_dma_req_i,
  input [31:0]                   config_dma_rd_addr_i,
  input [12:0]                   config_dma_req_len_i,
  output reg                     config_dma_req_done_o,
  input [7:0]                    config_dma_req_tag_i, 
  //dra
  input                          sys_user_dma_req_i,
  output reg                     sys_user_dma_req_done_o,
  input [12:0]                   sys_user_dma_req_len_i,
  input [31:0]                   sys_user_dma_rd_addr_i,
  input [7:0]                    sys_user_dma_tag_i,
  //User stream i/f
  input                          user_str_data_avail_i,
  output reg                     user_str_dma_done_o,
  input [31:0]                   user_sys_dma_wr_addr_i,
  output reg                     user_str_data_rd_o,
  input [255:0]                  user_str_data_i,
  input [4:0]                    user_str_len_i,
  //interrupt
  input                          intr_req_i,
  output reg                     intr_req_done_o,
  output reg                     cfg_interrupt_o,
  input                          cfg_interrupt_rdy_i
);
	

   // State Machine state declaration
    localparam IDLE         = 'd0,
               SEND_DATA    = 'd1,
               SEND_DMA_REQ = 'd2,
               REQ_INTR     = 'd3,
               WR_USR_HDR   = 'd4,
               WR_USR_DATA  = 'd5,
               SEND_ACK_DMA = 'd6,
               WAIT_CORE    = 'd7;

    reg            state;
    reg [2:0]      dma_state;
    reg [31:0]     rd_data_p;
    reg [255:0]    user_rd_data_p;
    reg [127:0]    user_rd_data_p1;
    reg [4:0]      wr_cntr;
    wire [10:0]    user_wr_len;

    // Unused discontinue
    assign user_wr_len     = user_str_len_i*8;
	assign s_axis_cc_tuser = 33'h000000000;

    //Delay the data read from the transmit fifo for 64byte packing.
    always@(posedge clk_i)
    begin
	     if(user_str_data_rd_o)
            user_rd_data_p    <= user_str_data_i;
    end
    
    always@(posedge clk_i)
    begin
        if(user_str_data_rd_o)
            user_rd_data_p1    <= user_rd_data_p[255:128];
    end
    
    
    initial 
    begin
        s_axis_cc_tlast   <= 1'b0;
        s_axis_cc_tvalid  <= 1'b0;
        s_axis_cc_tkeep   <= {KEEP_WIDTH{1'b0}};
        compl_done_o      <= 1'b0;
        config_dma_req_done_o    <= 1'b0;
        wr_cntr           <= 0;
        intr_req_done_o   <=  1'b0;
        user_str_data_rd_o <= 1'b0;
        state             <= IDLE;
        dma_state         <= IDLE;
        user_str_dma_done_o <= 1'b0;
    end

    //The transmit state machine
    always @ ( posedge clk_i ) 
    begin 
        case (state)
            IDLE : begin
                s_axis_cc_tlast  <= 1'b0;
                s_axis_cc_tvalid <= 1'b0;
                if (req_compl_wd_i)                                 //If completion request from Rx engine
                begin
                    s_axis_cc_tlast  <= 1'b1;
                    s_axis_cc_tvalid <= 1'b1;                       
                    s_axis_cc_tdata  <= {                            // Bits
										    128'b0,                  // Tied to 0 for 3DW completion descriptor
                                            reg_data_i,              // 32- bit read data
                                            1'b0,                    // Force ECRC
                                            req_attr_i,              // 3- bits
                                            req_tc_i,                // 3- bits
                                            1'b0,                    // Completer ID to control selection of Client
                                                                     // Supplied Bus number
                                            8'hAA,                   // Completer Bus number - selected if Compl ID    = 1
                                            8'hBB,                   // Compl Dev / Func no - sel if Compl ID = 1
										    req_tag_i,               // 8 tag number
											req_rid_i,               // 16 Requester id
											1'b0,                    // 1 Reserved
                                            1'b0,                    // 1 No poisoning
                                            3'b000,                  // 3 Successful completion
                                            req_len_i,               // 11
											2'b00,                   // 2 Reserved
                                            1'b0,                    // No locked mem read
                                            13'd4,                   // 13 (Byte length)
											6'd0,                    // 6 Reserved
											addr_type_i,             // 2
											1'b0,                    // 1 Reserved
											req_addr_i               // 7
                                          };
                    s_axis_cc_tkeep   <=  8'h0F;
                    state             <=  SEND_DATA;
                    compl_done_o      <=  1'b1;
                end   
            end            
            SEND_DATA : begin
                compl_done_o     <= 1'b0;
                if (s_axis_cc_tready) 
                begin
                    s_axis_cc_tlast  <= 1'b0;
                    s_axis_cc_tvalid <= 1'b0;
                    state            <= IDLE;
                end 
                else
                    state             <= SEND_DATA;
            end
        endcase
    end



    //The transmit state machine
    always @ ( posedge clk_i ) 
    begin 
        case (dma_state)
            IDLE : begin
                s_axis_rq_tlast  <= 1'b0;
                s_axis_rq_tvalid <= 1'b0;
                intr_req_done_o  <= 1'b0;
                wr_cntr <= 0;
				user_str_dma_done_o <= 1'b0;
                if(config_dma_req_i)                     //If system memory DMA read request for reconfiguration
                begin
                    s_axis_rq_tlast  <= 1'b1;
                    s_axis_rq_tvalid <= 1'b1;
                    s_axis_rq_tdata  <= { 
										128'b0,                                    // 4DW Unused
                                        1'b0,                                      // Force ECRC
                                        3'b000,                                    // Attributes
                                        3'b000,                                    // Traffic Class
                                        1'b0,                                      // RID Enable
                                        16'b0,                                     // Completer -ID
                                        config_dma_req_tag_i,                      // 8 tag
                                        8'h00,                                     // Req Bus No
                                        8'h00,                                     // Req Dev/Func no
                                        1'b0,                                      // Poisoned Req
                                        4'b0000,                                   // Req Type for MRd Req
                                        config_dma_req_len_i[12:2],                // 11 bit request length in DWORDS
                                        {32'h00000000,config_dma_rd_addr_i[31:2]}, // 62-bit address      
                                        2'b00                                      // Address type
                                        };
                  s_axis_rq_tuser   <=  {         
										 32'b0,        // Parity
                                         4'b1010,      // Seq Number
                                         8'h00,        // TPH Steering Tag
                                         1'b0,         // TPH indirect Tag Enable
                                         2'b0,         // TPH Type
                                         1'b0,         // TPH Present
                                         1'b0,         // Discontinue
                                         3'b000,       // Byte Lane number in case of Address Aligned mode
                                         4'hF,         // Last BE of the Read Data
                                         4'hF          // First BE of the Read Data
                                        };
                  s_axis_rq_tkeep       <=  8'h0F;
                  dma_state             <= SEND_DMA_REQ;
                  config_dma_req_done_o <= 1'b1;
                end 
                
                else if(sys_user_dma_req_i)           //If system memory DMA read request for PCIe stream
                begin
                   s_axis_rq_tlast  <= 1'b1;
                   s_axis_rq_tvalid <= 1'b1;
                   s_axis_rq_tdata  <= { 
										128'b0,                                    // 4DW Unused
                                        1'b0,                                      // Force ECRC
                                        3'b000,                                    // Attributes
                                        3'b000,                                    // Traffic Class
                                        1'b0,                                      // RID Enable
                                        16'b0,                                     // Completer -ID
                                        sys_user_dma_tag_i,                        // 8 tag
                                        8'h00,                                     // Req Bus No
                                        8'h00,                                     // Req Dev/Func no
                                        1'b0,                                      // Poisoned Req
                                        4'b0000,                                   // Req Type for MRd Req
                                        sys_user_dma_req_len_i[12:2],              // 11 bit request length in DWORDS
                                        {32'h00000000,sys_user_dma_rd_addr_i[31:2]}, // 62-bit address      
                                        2'b00                                      // Address type
                                        };
                   s_axis_rq_tuser   <=  {         
                                         32'b0,        // Parity
                                         4'b1010,      // Seq Number
                                         8'h00,        // TPH Steering Tag
                                         1'b0,         // TPH indirect Tag Enable
                                         2'b0,         // TPH Type
                                         1'b0,         // TPH Present
                                         1'b0,         // Discontinue
                                         3'b000,       // Byte Lane number in case of Address Aligned mode
                                         4'hF,         // Last BE of the Read Data
                                         4'hF          // First BE of the Read Data
                                        };
                    s_axis_rq_tkeep   <=  8'h0F;
                    dma_state         <= SEND_DMA_REQ;
                    sys_user_dma_req_done_o <= 1'b1; 
                end 
                
                else if(user_str_data_avail_i & s_axis_rq_tready)
                begin
                    dma_state           <=  WR_USR_HDR;
                    user_str_data_rd_o  <=  1'b1;
                    wr_cntr             <=  user_str_len_i;
                end
                
                else if(intr_req_i) //If there is interrupt request and no data in the transmit fifo
                begin
                    dma_state       <=  REQ_INTR;
	                cfg_interrupt_o <=  1'b1;
	                intr_req_done_o <=  1'b1;
                end
				
                else 
                begin
                    s_axis_rq_tlast   <= 1'b0;
                    s_axis_rq_tvalid  <= 1'b0;
                    s_axis_rq_tkeep   <= 8'h00;
                end
            end 

            SEND_DMA_REQ:begin
                config_dma_req_done_o   <= 1'b0;
                sys_user_dma_req_done_o <= 1'b0;
                if (s_axis_rq_tready) 
                begin
                    s_axis_rq_tlast       <= 1'b0;
                    s_axis_rq_tvalid      <= 1'b0; 
                    dma_state             <= IDLE;
                end
            end
				
	        WR_USR_HDR:begin
		        s_axis_rq_tvalid <= 1'b1;
                s_axis_rq_tdata  <= { 
				                     user_str_data_i[127:0],                    // 4DW User data
                                     1'b0,                                      // Force ECRC
                                     3'b000,                                    // Attributes
                                     3'b000,                                    // Traffic Class
                                     1'b0,                                      // RID Enable
                                     16'b0,                                     // Completer -ID
                                     8'h00,                                     // 8 tag
                                     8'h00,                                     // Req Bus No
                                     8'h00,                                     // Req Dev/Func no
                                     1'b0,                                      // Poisoned Req
                                     4'b0001,                                   // Req Type for MWr Req
                                     user_wr_len,                               // 11 bit request length in DWORDS
                                     {32'h00000000,user_sys_dma_wr_addr_i[31:2]}, // 62-bit address      
                                     2'b00                                      // Address type
                                     };
				s_axis_rq_tuser   <=  {         
									  32'b0,        // Parity
                                      4'b1010,      // Seq Number
                                      8'h00,        // TPH Steering Tag
                                      1'b0,         // TPH indirect Tag Enable
                                      2'b0,         // TPH Type
                                      1'b0,         // TPH Present
                                      1'b0,         // Discontinue
                                      3'b000,       // Byte Lane number in case of Address Aligned mode
                                      4'hF,         // Last BE of the Write Data
                                      4'hF          // First BE of the Write Data
                                     };
                s_axis_rq_tkeep     <=  8'hFF;                
				if(wr_cntr == 1)
				begin
                    user_str_data_rd_o    <=    1'b0;
				end	  
                dma_state           <=  WR_USR_DATA;
			end
			
            WR_USR_DATA:begin
                user_str_dma_done_o <= 1'b0;
		        if(s_axis_rq_tready)
		        begin
                    if(wr_cntr == 2)
                        user_str_data_rd_o  <=    1'b0;
                    else if(wr_cntr == 1)
                    begin
                        user_str_data_rd_o  <= 1'b0;
                        s_axis_rq_tlast     <= 1'b1;
                        user_str_dma_done_o <= 1'b1;
                        s_axis_rq_tkeep     <= 8'h0F; 
                    end  
                    else if(wr_cntr == 0) //simply wait for tready to change status.
                    begin
                        dma_state        <=    IDLE;
                        s_axis_rq_tlast  <=    1'b0;
                        s_axis_rq_tvalid <=    1'b0;
                    end
                    wr_cntr             <=    wr_cntr - 1'b1;
                    s_axis_rq_tdata     <=    {user_str_data_i[127:0],user_rd_data_p[255:128]};
                end 
		        else
		        begin
		            user_str_data_rd_o    <=    1'b0;
		            dma_state             <=    WAIT_CORE;
		        end	  
            end
            
            WAIT_CORE:begin
                if(s_axis_rq_tready)
                begin
                    s_axis_rq_tdata     <=     {user_rd_data_p[127:0],user_rd_data_p1};
                    wr_cntr             <=     wr_cntr - 1'b1;
                    if(wr_cntr == 2)
                    begin
                        user_str_data_rd_o  <= 1'b0;
                        dma_state           <= WR_USR_DATA;
                    end    
                    else if(wr_cntr == 1)
                    begin
                        user_str_data_rd_o  <= 1'b0;
                        s_axis_rq_tlast     <= 1'b1;
                        s_axis_rq_tvalid    <= 1'b1;
                        s_axis_rq_tkeep     <= 8'h0F; 
                        user_str_dma_done_o <= 1'b1;
                        dma_state           <= WR_USR_DATA; 
                    end                        
                    else if(wr_cntr == 0) //simply wait for tready to change status.
                    begin
                        dma_state        <=    IDLE;
                        s_axis_rq_tlast  <=    1'b0;
                        s_axis_rq_tvalid <=    1'b0;
                    end
                    else
                    begin
                        s_axis_rq_tvalid   <=    1'b0;
                        s_axis_rq_tlast    <=    1'b0;
                        dma_state          <=    WR_USR_DATA;
                        user_str_data_rd_o <=    1'b1;
                    end
                end
            end
			
            REQ_INTR:begin        //Send interrupt through PCIe interrupt port
                intr_req_done_o <= 1'b0;
                if(cfg_interrupt_rdy_i)
                begin
                    cfg_interrupt_o <= 1'b0;
                    dma_state       <= IDLE;
                end
            end
        endcase
    end
 
 
endmodule
