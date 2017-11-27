//--------------------------------------------------------------------------------
// Project    : SWITCH
// File       : user_pcie_stream_generator.v
// Version    : 0.1
// Author     : Vipin.K
//
// Description: PCIe user stream i/f controller
//
//--------------------------------------------------------------------------------


module user_pcie_stream_generator
#(
  parameter TAG1 = 8'd1,
  parameter TAG2 = 8'd2,
  parameter DATA_WIDTH = 'd256,
  parameter ADDR_WIDTH = 'd32,
  parameter LEN_WIDTH  = 'd32,
  parameter TAG_WIDTH  = 'd8,
  parameter PKT_SIZE   = 'd128
)
(
input                        clk_i,
input                        rst_n,
//Register Set I/f
input                        sys_user_strm_en_i,
input                        user_sys_strm_en_i,
output  reg                  dma_done_o,
input                        dma_done_ack_i,
input       [ADDR_WIDTH-1:0] dma_src_addr_i,
input       [LEN_WIDTH-1:0]  dma_len_i,
input       [LEN_WIDTH-1:0]  stream_len_i,
output reg                   user_sys_strm_done_o,
input                        user_sys_strm_done_ack,
input       [ADDR_WIDTH-1:0] dma_wr_start_addr_i,
input       [ADDR_WIDTH-1:0] sys_user_dma_addr_i,
input	    [ADDR_WIDTH-1:0] user_sys_dma_addr_i,

//To pcie arbitrator
output  reg                  dma_rd_req_o,
input                        dma_req_ack_i,
//Rx engine
input       [TAG_WIDTH-1:0]  dma_tag_i,
input                        dma_data_valid_i,
input       [DATA_WIDTH-1:0] dma_data_i,
//User stream output
output  reg                  stream_data_valid_o,
input                        stream_data_ready_i,
output  reg [DATA_WIDTH-1:0] stream_data_o,
output      [ADDR_WIDTH-1:0] sys_user_dma_addr_o,
output      [LEN_WIDTH-1:0]  sys_user_dma_len_o,

//User stream input
input                        stream_data_valid_i,
output                       stream_data_ready_o,
input       [DATA_WIDTH-1:0] stream_data_i, 
output      [ADDR_WIDTH-1:0] user_sys_dma_addr_o,
output      [LEN_WIDTH-1:0]  user_sys_dma_len_o,

//To Tx engine  
output  reg [12:0]           dma_rd_req_len_o,
output  reg [TAG_WIDTH-1:0]  dma_tag_o,
output  reg [ADDR_WIDTH-1:0] dma_rd_req_addr_o,
output  reg                  user_stream_data_avail_o, 
input                        user_stream_data_rd_i,
output      [DATA_WIDTH-1:0] user_stream_data_o,
output  reg [4:0]            user_stream_data_len_o,
output      [ADDR_WIDTH-1:0] user_stream_wr_addr_o,
input                        user_stream_wr_ack_i
);

localparam IDLE          = 'd0,
           WAIT_ACK      = 'd1,
           START         = 'd2,
           WAIT_DEASSRT  = 'd3;
           
localparam REQ_BUF1        = 'd1,
           WAIT_BUF1_ACK   = 'd2,
           REQ_BUF2        = 'd3,
           WAIT_BUF2_ACK   = 'd4,
           REQ_BUF3        = 'd5,
           WAIT_BUF3_ACK   = 'd6,
           REQ_BUF4        = 'd7,
           WAIT_BUF4_ACK   = 'd8,
           INT_RESET       = 'd9,
           CLR_CNTR        = 'd10;           
          
reg [3:0]            state;
reg [1:0]            wr_state;
reg                  last_flag;
reg [LEN_WIDTH-1:0]  rd_len;
reg [LEN_WIDTH-1:0]  wr_len;
reg [LEN_WIDTH-1:0]  rcvd_data_cnt;
reg [LEN_WIDTH-1:0]  expected_data_cnt;
wire[LEN_WIDTH-1:0]  rd_data_count;
reg                  clr_rcv_data_cntr;
reg [ADDR_WIDTH-1:0] dma_wr_addr;
reg [DATA_WIDTH-1:0] dma_data_p;
wire [DATA_WIDTH-1:0] fifo1_rd_data;
wire [DATA_WIDTH-1:0] fifo2_rd_data;
reg [7:0]             fifo_1_expt_cnt;
reg [7:0]             fifo_2_expt_cnt;
reg [7:0]             fifo_1_rcv_cnt;
reg [7:0]             fifo_2_rcv_cnt;
reg [6:0]             fifo_rd_cnt;
reg                   current_read_fifo;
reg                   clr_fifo1_data_cntr;
reg                   clr_fifo2_data_cntr;

reg        fifo1_wr_en;
reg        fifo2_wr_en;
wire       all_fifos_empty;
wire       rd_data_transfer;
reg        fifo1_rdy;
reg        fifo2_rdy;


//Enabling the FIFO write enable signals based on the tag number of the received data
always @(posedge clk_i)
begin
    if(dma_data_valid_i & (dma_tag_i == TAG1))
        fifo1_wr_en <= 1'b1;
    else  
        fifo1_wr_en <= 1'b0;
  
    if(dma_data_valid_i & (dma_tag_i == TAG2)) 
       fifo2_wr_en <= 1'b1;
    else
       fifo2_wr_en <= 1'b0;
      
    dma_data_p  <= dma_data_i;
end

assign all_fifos_empty        = !(fifo1_valid|fifo2_valid);
assign user_stream_wr_addr_o  = dma_wr_addr;
assign rd_data_transfer       = stream_data_valid_o & stream_data_ready_i;
assign sys_user_dma_addr_o    = sys_user_dma_addr_i;
assign user_sys_dma_addr_o    = user_sys_dma_addr_i;
assign sys_user_dma_len_o     = dma_len_i;
assign user_sys_dma_len_o     = stream_len_i;


//Selecting output stream based on the FIFO from where data is being read
always @(*)
begin
    case(current_read_fifo)
        1'b0:begin
            stream_data_o          <=    fifo1_rd_data;
            fifo1_rdy              <=    stream_data_ready_i;
            fifo2_rdy              <=    1'b0;
            stream_data_valid_o    <=    fifo1_valid;
      end
        1'b1:begin
            stream_data_o          <=    fifo2_rd_data;
            fifo1_rdy              <=    1'b0;
            fifo2_rdy              <=    stream_data_ready_i;
            stream_data_valid_o    <=    fifo2_valid;
      end
    endcase
end

initial
begin
      wr_state                   <=  IDLE;
      user_stream_data_avail_o   <=  1'b0;
      user_sys_strm_done_o       <=  1'b0;
      current_read_fifo          <=  1'b0;
      fifo_rd_cnt                <=  7'd0;
end

//Switch between FIFOs when each one is exhausted. Required since PCIe data comes out of order and we are making 2 simultaneous requests to the host.
//So two separate FIFOs are used to store the received data based on the tag number.
//But they need to be read sequentially from the FIFOs
always@(posedge clk_i)
begin
    if(clr_rcv_data_cntr)
       current_read_fifo  <=  1'b0;
    else if((fifo_rd_cnt == 'd127) & rd_data_transfer)
       current_read_fifo  <=  current_read_fifo + 1'b1;
end

always @(posedge clk_i)
begin
    if(clr_rcv_data_cntr)
        fifo_rd_cnt   <=  7'd0;
    else if(rd_data_transfer)
        fifo_rd_cnt   <=  fifo_rd_cnt + 1'b1;    
end

//State machine for user logic to system data transfer
always @(posedge clk_i)
begin
    if(~rst_n)
	 begin
	     wr_state    <=    IDLE;
	 end
	 else
	 begin
		case(wr_state)
         IDLE:begin
             user_sys_strm_done_o    <=    1'b0;
             if(user_sys_strm_en_i)                       //If the controller is enabled
             begin
                 dma_wr_addr    <=  dma_wr_start_addr_i;  //Latch the destination address and transfer size
                 wr_len         <=  stream_len_i[31:5];   //Write length interms of 32 bytes
                 if(stream_len_i >= 32)                   //If forgot to set the transfer size, do not hang!!
                     wr_state  <=  START;
                 else
                     wr_state  <=  WAIT_DEASSRT;                     
             end
         end
         START:begin
            if((rd_data_count >= 'd4) & (wr_len >= 4 )) //For efficient transfer, if more than 128 bytes to data is still remaining, wait.
            begin
                user_stream_data_avail_o   <=  1'b1;    //Once data is available, request to the arbitrator.
                user_stream_data_len_o     <=  5'd4;
                wr_state                   <=  WAIT_ACK;
                wr_len                     <=  wr_len - 4'd4;
            end
            else if(rd_data_count >= wr_len)
            begin
                wr_state                   <=  WAIT_ACK;
                wr_len                     <=  0;
                user_stream_data_avail_o   <=  1'b1;                  //Once data is in the FIFO, request the arbitrator    
                user_stream_data_len_o     <=  wr_len[4:0];     
            end
         end
         WAIT_ACK:begin
            if(user_stream_wr_ack_i)                                  //Once the arbitrator acks, remove the request and increment sys mem address
            begin
                user_stream_data_avail_o   <=  1'b0;
                dma_wr_addr                <=  dma_wr_addr + PKT_SIZE;
                if(wr_len == 0)
                    wr_state               <=  WAIT_DEASSRT;      //If all data is transferred, wait until it is updated in the status reg.
                else if((rd_data_count >= 'd4) & (wr_len >= 4))
                begin
                   user_stream_data_avail_o   <=  1'b1;    //Once data is available, request to the arbitrator.
                   user_stream_data_len_o     <=  5'd4;
                   wr_state                   <=  WAIT_ACK;
                   wr_len                     <=  wr_len - 4'd4;
                end
                else
                    wr_state             <=  START;    
            end
         end
         WAIT_DEASSRT:begin
             user_sys_strm_done_o    <=    1'b1;
             if(~user_sys_strm_en_i & user_sys_strm_done_ack)
                 wr_state    <=    IDLE;
         end
		endcase
	end	
end 


initial
begin
    state                 <= IDLE;
    dma_rd_req_o          <= 1'b0;
    dma_done_o            <= 1'b0;
    last_flag             <= 1'b0; 
    clr_fifo1_data_cntr   <= 1'b0;
    clr_fifo2_data_cntr   <= 1'b0;
    rcvd_data_cnt         <=  0;
    fifo_1_rcv_cnt        <=  0;
    fifo_2_rcv_cnt        <=  0;
end

//State machine for system to user logic data transfer

always @(posedge clk_i)
begin
    if(~rst_n)
	 begin
	   state  <=  IDLE;
	 end
	 else
	 begin
		case(state)
        IDLE:begin
            dma_done_o          <= 1'b0;
            last_flag           <= 1'b0; 
            clr_fifo1_data_cntr <= 1'b0;
            clr_fifo2_data_cntr <= 1'b0;
            clr_rcv_data_cntr   <= 1'b1;
            dma_rd_req_addr_o   <= dma_src_addr_i;
            rd_len              <= dma_len_i;
            expected_data_cnt   <= dma_len_i;
            fifo_1_expt_cnt     <= 8'd0;
            fifo_2_expt_cnt     <= 8'd0;
            dma_rd_req_o        <= 1'b0;
            if(sys_user_strm_en_i)                      //If system to user dma is enabled
            begin
                state           <= REQ_BUF1;
            end
        end
        REQ_BUF1:begin    
            clr_rcv_data_cntr <= 1'b0;
            if((fifo_1_rcv_cnt >= fifo_1_expt_cnt) & !fifo1_valid) //If there is space in receive fifo make a request
            begin
                state         <= WAIT_BUF1_ACK;
                dma_rd_req_o  <= 1'b1;
                dma_tag_o     <= TAG1;
                clr_fifo1_data_cntr <= 1'b1;//Clear received cntr for FIFO1 since new request starting
                if(rd_len <= 'd4096)
                begin
                    dma_rd_req_len_o          <= rd_len[12:0];  
                    last_flag                 <= 1'b1;                     
                end
                else
                begin
                    dma_rd_req_len_o         <= 4096;
                    fifo_1_expt_cnt          <= 8'd128;
                end
            end
        end
        WAIT_BUF1_ACK:begin
            clr_fifo1_data_cntr <= 1'b0;
            if(dma_req_ack_i)
            begin
                dma_rd_req_o <= 1'b0;
                if(last_flag)    //If all data is read, wait until complete data is received
                begin
                    state             <= INT_RESET;      
                end
                else
                begin
                    state               <= REQ_BUF2;
                    rd_len              <= rd_len - 'd4096;
                    dma_rd_req_addr_o   <= dma_rd_req_addr_o + 'd4096;
                end
				end	 
        end
        REQ_BUF2:begin
            if((fifo_2_rcv_cnt >= fifo_2_expt_cnt) & !fifo2_valid)  //If all data for the FIFO has arrived and written into DDR
            begin
                state           <= WAIT_BUF2_ACK;
                dma_rd_req_o    <= 1'b1;
                dma_tag_o       <= TAG2;
                clr_fifo2_data_cntr <= 1'b1;                          //Clear received cntr for FIFO1 since new request starting
                if(rd_len <= 'd4096)
                begin
                    dma_rd_req_len_o          <= rd_len[12:0];
                    last_flag                 <= 1'b1;                     
                end
                else
                begin
                    dma_rd_req_len_o         <= 4096;
                    fifo_2_expt_cnt          <= 8'd128;
                end
            end
        end
        WAIT_BUF2_ACK:begin
            clr_fifo2_data_cntr <= 1'b0;
            if(dma_req_ack_i)
            begin
                dma_rd_req_o <= 1'b0;
                if(last_flag)    //If all data is read, wait until complete data is received
                begin
                    state               <= INT_RESET;     
                end
                else
                begin
                    state               <= REQ_BUF1;//REQ_BUF3;
                    rd_len              <= rd_len - 'd4096;
                    dma_rd_req_addr_o   <= dma_rd_req_addr_o + 'd4096;
                end
           end
        end 
        INT_RESET:begin
            if(rcvd_data_cnt >= expected_data_cnt[31:5])    //When both FIFOs are empty, go to idle
            begin
               dma_done_o        <= 1'b1;
            end
            if(~sys_user_strm_en_i & dma_done_ack_i)
            begin
                state               <= CLR_CNTR;
                dma_done_o          <= 1'b0;
            end 
        end
        CLR_CNTR:begin
            if(all_fifos_empty)
            begin
                clr_rcv_data_cntr   <= 1'b1;
                clr_fifo1_data_cntr <= 1'b1;
                clr_fifo2_data_cntr <= 1'b1;
                state               <= IDLE;
            end
        end
		endcase
	end	
end


always @(posedge clk_i)
begin
    if(clr_rcv_data_cntr)
        rcvd_data_cnt   <=    0;
    else if(fifo1_wr_en|fifo2_wr_en)
        rcvd_data_cnt   <=    rcvd_data_cnt + 1'd1; 
end

always @(posedge clk_i)
begin
   if(clr_fifo1_data_cntr)
       fifo_1_rcv_cnt   <=    0;
   else if(fifo1_wr_en)
       fifo_1_rcv_cnt   <=    fifo_1_rcv_cnt + 1'd1; 
end
always @(posedge clk_i)
begin
   if(clr_fifo2_data_cntr)
       fifo_2_rcv_cnt   <=    0;
   else if(fifo2_wr_en)
       fifo_2_rcv_cnt   <=    fifo_2_rcv_cnt + 1'd1; 
end

//user_logic_stream_wr_fifo
user_fifo user_wr_fifo_1 (
  .s_axis_aresetn(rst_n),          // input wire s_axis_aresetn
  .s_axis_aclk(clk_i),                // input wire s_axis_aclk
  .s_axis_tvalid(fifo1_wr_en),            // input wire s_axis_tvalid
  .s_axis_tready(),            // output wire s_axis_tready
  .s_axis_tdata(dma_data_p),              // input wire [511 : 0] s_axis_tdata
  .m_axis_tvalid(fifo1_valid),            // output wire m_axis_tvalid
  .m_axis_tready(fifo1_rdy),            // input wire m_axis_tready
  .m_axis_tdata(fifo1_rd_data),              // output wire [63: 0] m_axis_tdata
  .axis_data_count(),        // output wire [31 : 0] axis_data_count
  .axis_wr_data_count(),  // output wire [31 : 0] axis_wr_data_count
  .axis_rd_data_count()  // output wire [31 : 0] axis_rd_data_count
);



//user_logic_stream_wr_fifo
user_fifo user_wr_fifo_2 (
  .s_axis_aresetn(rst_n),          // input wire s_axis_aresetn
  .s_axis_aclk(clk_i),                // input wire s_axis_aclk
  .s_axis_tvalid(fifo2_wr_en),            // input wire s_axis_tvalid
  .s_axis_tready(),            // output wire s_axis_tready
  .s_axis_tdata(dma_data_p),              // input wire [511 : 0] s_axis_tdata
  .m_axis_tvalid(fifo2_valid),            // output wire m_axis_tvalid
  .m_axis_tready(fifo2_rdy),            // input wire m_axis_tready
  .m_axis_tdata(fifo2_rd_data),              // output wire [63 : 0] m_axis_tdata
  .axis_data_count(),        // output wire [31 : 0] axis_data_count
  .axis_wr_data_count(),  // output wire [31 : 0] axis_wr_data_count
  .axis_rd_data_count()  // output wire [31 : 0] axis_rd_data_count
);



//user_logic_stream_rd_fifo
user_fifo user_rd_fifo (
  .s_axis_aresetn(rst_n),          // input wire s_axis_aresetn
  .s_axis_aclk(clk_i),                // input wire s_axis_aclk
  .s_axis_tvalid(stream_data_valid_i),            // input wire s_axis_tvalid
  .s_axis_tready(stream_data_ready_o),            // output wire s_axis_tready
  .s_axis_tdata(stream_data_i),              // input wire [63 : 0] s_axis_tdata
  .m_axis_tvalid(),            // output wire m_axis_tvalid
  .m_axis_tready(user_stream_data_rd_i),            // input wire m_axis_tready
  .m_axis_tdata(user_stream_data_o),              // output wire [511 : 0] m_axis_tdata
  .axis_data_count(),        // output wire [31 : 0] axis_data_count
  .axis_wr_data_count(),  // output wire [31 : 0] axis_wr_data_count
  .axis_rd_data_count(rd_data_count)  // output wire [31 : 0] axis_rd_data_count
);



endmodule