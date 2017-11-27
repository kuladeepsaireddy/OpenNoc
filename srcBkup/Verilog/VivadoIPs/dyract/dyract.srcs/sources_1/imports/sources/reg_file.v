//--------------------------------------------------------------------------------
// Project    : SWITCH
// File       : reg_file.v
// Version    : 0.1
// Author     : Vipin.K
//
// Description: Global register set
//
//--------------------------------------------------------------------------------

//Register address definition
`define VER                'h00      // Version
`define SCR                'h04      // Scratch pad
`define CTRL               'h08      // Control
//0C reserved
`define STA                'h10      // Status
`define EER_STAT           'h14      // Error Status register
`define UCTR               'h18      // User control register
`define USER_ADDR_REG      'h20      // Address register for indirect access
`define USER_DATA_REG      'h24      // Address register for indirect access
//50-5C Reserved
`define CONF_ADDR          'h50
`define CONF_LEN           'h54
`define PC_USER1_DMA_SYS   'h60      // System to user stream i/f 1 DMA, system memory address
`define PC_USER1_DMA_LEN   'h64      // System to user stream i/f 1 DMA, length (bytes)
`define USER1_PC_DMA_SYS   'h68      // User stream i/f 1 to system DMA, system memory address
`define USER1_PC_DMA_LEN   'h6C      // User stream i/f 1 to system DMA, length (bytes)
`define PC_USER1_DMA_USR   'h70
`define USER1_PC_DMA_USR   'h74


module reg_file(
 input                clk_i,                     // 250Mhz clock from PCIe core
 input                rst_n,                     // Active low reset
 //Rx engine
 input      [9:0]     addr_i,                    // Register address
 input      [31:0]    data_i,                    // Register write data
 input                data_valid_i,              // Register write data valid
 output               fpga_reg_wr_ack_o,         // Register write ack
 input                fpga_reg_rd_i,             // Register read request
 output reg           fpga_reg_rd_ack_o,         // Register read ack
 output reg [31:0]    data_o,                    // Register read data
 //To user pcie stream controllers
 //PSG-1
 output               o_user_str1_en,            // Enable signal to the system to user stream i/f 1 controller
 input                i_user_str1_done,          // Stream done signal
 output               o_user_str1_done_ack,      // Ack the done signal. Needed since status register is accessed by both PC and FPGA. So should not miss the done.
 output [31:0]        o_user_str1_dma_addr,      // System memory start address for streaming data
 output [31:0]        o_user_str1_dma_len,       // Length of streaming operation (bytes)
 output               user1_sys_strm_en_o,       // Enable signal to the user stream i/f 1 to system controller
 output [31:0]        user1_sys_dma_wr_addr_o,   // System memory address for DMA operation
 output [31:0]        user1_sys_stream_len_o,    // Stream length for DMA
 input                user1_sys_strm_done_i,     // Stream done signal
 output               user1_sys_strm_done_ack_o, // Ack the done due to multiple STAT reg access.
 output [31:0]        o_sys_user1_dma_addr,
 output [31:0]        o_user1_sys_dma_addr,

 //config control
 input                i_icap_clk,
 output [31:0]        o_conf_addr,
 output [31:0]        o_conf_len,
 output               o_conf_req,
 input                i_config_done,
 output               o_conf_done_ack,
 //clock control
 output reg           user_clk_swch_o,
 output [1:0]         user_clk_sel_o,
 //interrupt
 output reg           intr_req_o,                // Interrupt request to Tx engine
 input                intr_req_done_i,           // Interrupt done ack from Tx engine
 input                user_intr_req_i,           // User interrupt request
 output reg           user_intr_ack_o,           // Interrupt ack to user logic
 //Misc
 output               user_reset_o,              // User soft reset
 output [31:0]        user_addr_o,               // User address for indirect access
 output               system_soft_reset_o,       // Complete system soft reset
 //link status
 input                i_pcie_link_stat
 
 );
 
 parameter  VER = 32'h00000005;                   // Present Version Number. 16 bit major version and 16 bit minor version

 //Interrupt state machine state variables.
 localparam INTR_IDLE =  'd0,
            WAIT_ACK  =  'd1;

//The global register set in the address of address
reg [31:0] SCR_PAD;                              
reg [31:0] CTRL_REG;
reg [31:0] STAT_REG;
reg [31:0] USR_CTRL_REG;  
reg [31:0] PC_USER1_DMA_SYS;
reg [31:0] PC_USER1_DMA_LEN;
reg [31:0] USER1_PC_DMA_SYS;
reg [31:0] USER1_PC_DMA_LEN;
reg [31:0] PC_USER1_DMA_USR;
reg [31:0] USER1_PC_DMA_USR;
reg [31:0] CONF_ADDR;
reg [31:0] CONF_LEN;
reg [31:0] USER_ADDR_REG;
  

//local registers

reg        fpga_reg_wr_ack;
reg        intr_state;
reg        processor_clr_intr;
wire       intr_pending;
reg        data_valid_p;
wire       data_valid_r;
reg  [1:0] prev_user_clk; 
reg        user_clk_swtch_done; 
reg        user_clk_swch_p; 
reg        user_swtch_clk; 
reg        user_swtch_clk_p; 
reg        user_intr_req;
reg        user_intr_req_p;
reg        user_intr_req_p1;
reg        user_intr_req_p2;

assign  system_soft_reset_o       = CTRL_REG[0];

assign  o_user_str1_en            = CTRL_REG[4];
assign  o_user_str1_done_ack      = STAT_REG[4];
assign  o_user_str1_dma_addr      = PC_USER1_DMA_SYS;
assign  o_user_str1_dma_len       = PC_USER1_DMA_LEN;
assign  user1_sys_strm_en_o       = CTRL_REG[5];
assign  user1_sys_strm_done_ack_o = STAT_REG[5];
assign  user1_sys_dma_wr_addr_o   = USER1_PC_DMA_SYS;
assign  user1_sys_stream_len_o    = USER1_PC_DMA_LEN;
assign  o_sys_user1_dma_addr      = PC_USER1_DMA_USR;
assign  o_user1_sys_dma_addr      = USER1_PC_DMA_USR;

assign  user_clk_sel_o           = USR_CTRL_REG[2:1];

assign  o_conf_addr              = CONF_ADDR;
assign  o_conf_len               = CONF_LEN;
assign  o_conf_req               = CTRL_REG[20];
assign  o_conf_done_ack          = STAT_REG[20];
assign  user_reset_o             = USR_CTRL_REG[0];
assign  fpga_reg_wr_ack_o        = fpga_reg_wr_ack;
assign  intr_pending             = |STAT_REG[20:0];
assign  data_valid_r             = data_valid_i & ~data_valid_p;

assign  user_addr_o              = USER_ADDR_REG;


always @(posedge clk_i)
begin
    data_valid_p <= data_valid_i;
end	 

// Read register data based on address. Registers for user stream interface are kept as write only so that
// when unused those are automatically optimised by the tool
always @(*)
begin
    case(addr_i)
        `VER:begin
            data_o  <=    VER;
        end
        `SCR:begin
            data_o  <=    SCR_PAD;
        end
        `CTRL:begin
            data_o  <=    CTRL_REG;
        end  
        `STA:begin
            data_o  <=    STAT_REG;
        end
        `UCTR:begin
            data_o  <=    USR_CTRL_REG;
        end   
        default:begin
            data_o  <=    0;
        end
    endcase
end

// Write to global registers based on address and data valid and ack
always @(posedge clk_i)
begin
    fpga_reg_wr_ack              <=   1'b0;  
    if(data_valid_r)
    begin
        fpga_reg_wr_ack   <=   1'b1;
        case(addr_i)
            `SCR:begin
                SCR_PAD  <=   data_i;
            end
            `UCTR:begin
                USR_CTRL_REG      <=   data_i;
            end
            `USER_ADDR_REG:begin
                USER_ADDR_REG    <=    data_i;
            end
            `PC_USER1_DMA_SYS:begin
                PC_USER1_DMA_SYS   <=   data_i;
            end
            `PC_USER1_DMA_LEN:begin
                PC_USER1_DMA_LEN  <=   data_i;
            end
            `USER1_PC_DMA_SYS:begin
                USER1_PC_DMA_SYS  <= data_i;
            end
            `USER1_PC_DMA_LEN:begin
                USER1_PC_DMA_LEN  <= data_i;
            end
	    `PC_USER1_DMA_USR:begin
		PC_USER1_DMA_USR <= data_i;
	    end
            `USER1_PC_DMA_USR:begin			 
                 USER1_PC_DMA_USR  <=  data_i;
	    end	  					
            `CONF_ADDR:begin
                CONF_ADDR  <=  data_i;
            end    
            `CONF_LEN:begin
                CONF_LEN  <=  data_i;
            end
            default:begin
                fpga_reg_wr_ack   <=   1'b1;				
            end				
        endcase
    end
end

//Synchronizer
always @(posedge clk_i)
begin
   user_intr_req_p <= user_intr_req_i;
   user_intr_req_p1 <= user_intr_req_p;
   user_intr_req_p2 <= user_intr_req_p1;
   user_intr_req    <= user_intr_req_p1 & !user_intr_req_p2;
end


//If the read register is not PIO register, ack immediately, else wait until data arrives from DDR
//Address bit 9 is to partiall decode the System monitor address. Be careful when modify the address
//due to this
always @(posedge clk_i)
begin
    if(fpga_reg_rd_i)
        fpga_reg_rd_ack_o    <=   1'b1;
    else 
        fpga_reg_rd_ack_o    <=   1'b0;
end

//control register updates
always @(posedge clk_i)
begin
    if(!system_soft_reset_o)
	 begin
	   CTRL_REG[31:1]  <=  31'b0;
	 end
	 else
	 begin
		if(data_valid_r & (addr_i == `CTRL))
		begin
        CTRL_REG[31:1] <=    CTRL_REG[31:1]|data_i[31:1];   //Internall ored to keep the previously set bits  
		end
		else
		begin            
        if(i_user_str1_done)
            CTRL_REG[4] <=    1'b0; 
        if(user1_sys_strm_done_i) 
            CTRL_REG[5] <=    1'b0;  
        if(i_config_done)
            CTRL_REG[20] <=    1'b0;            
		end 
	 end	
end

always @(posedge clk_i)
begin
    if(!rst_n)
    begin
       CTRL_REG[0]          <= 1'b1;    
    end
    if(data_valid_r & (addr_i == `CTRL))
    begin
	   CTRL_REG[0]    <=    data_i[0];
	 end
end


initial
begin
    STAT_REG             <= 32'd0;
    processor_clr_intr   <= 1'b0;
end


//status register updates
always @(posedge clk_i)
begin
    if(!system_soft_reset_o)
	 begin
	   STAT_REG  <=  32'h0;
	 end
	 else
	 begin
		processor_clr_intr   <= 1'b0;
		STAT_REG[29]         <= i_pcie_link_stat;
		if(data_valid_r & (addr_i == `STA))
		begin
            STAT_REG[31:0]     <=   STAT_REG[31:0]^data_i[31:0];
            processor_clr_intr <=   1'b1;
		end
		else
		begin
            if(user_intr_req)
                STAT_REG[3] <=    1'b1;
            if(i_user_str1_done)
                STAT_REG[4] <=    1'b1; 
            if(user1_sys_strm_done_i) 
                STAT_REG[5] <=    1'b1; 
            if(i_config_done)
                STAT_REG[20] <=    1'b1;             
		end
	 end	
end

always @(posedge clk_i)
begin
    if(!user_intr_req_p2)
        user_intr_ack_o    <=    1'b0;
    else if(user_intr_req_p2 & processor_clr_intr)
        user_intr_ack_o    <=    1'b1;
end

always @(posedge clk_i)
begin
    if(prev_user_clk != USR_CTRL_REG[2:1])
	     user_swtch_clk  <=  1'b1;
	 else if(user_clk_swtch_done)
	     user_swtch_clk  <=  1'b0;
  
	prev_user_clk   <=  USR_CTRL_REG[2:1];
	
	user_clk_swch_p <=  user_clk_swch_o;
	user_clk_swtch_done <=  user_clk_swch_p;
end

//Interrupt control state machine. This is to make sure that the host PC doesn't miss any interrupt signal
//Once an interrupt is issued, the state machine waits until the host write into the status register indicating
//that it has received the interrupt.

initial
begin
    intr_state  <=  INTR_IDLE;
    intr_req_o  <=  1'b0;
end

always @(posedge clk_i)
begin
    if(!system_soft_reset_o)
    begin
        intr_state  <=  INTR_IDLE;
        intr_req_o  <=  1'b0;
    end
    else
    begin
	   case(intr_state)
	        INTR_IDLE:begin
		       if(intr_pending)
			   begin
			      intr_req_o   <=   1'b1;
				  intr_state   <=  WAIT_ACK;
			   end
		    end
		    WAIT_ACK:begin
		       if(intr_req_done_i)
			       intr_req_o   <=   1'b0;
			   if(processor_clr_intr)
                    intr_state    <=    INTR_IDLE;					 
		    end
	   endcase
	end   
end

endmodule
