
module dyract #(parameter RECONFIG_ENABLE  = 0
  )
  (
  input   [7:0]        pci_exp_rxp,
  input   [7:0]        pci_exp_rxn, 
  output  [7:0]        pci_exp_txp,
  output  [7:0]        pci_exp_txn,  
  input                sys_clk_p,
  input                sys_clk_n,
  input                sys_reset_n,
  //stream i/f
  output               o_wr_data_valid,
  input                i_wr_data_ready,
  output [255:0]       o_wr_data,
  input                i_rd_data_valid,
  output               o_rd_data_ready,
  input [255:0]        i_rd_data,
  //
  output               o_axi_strm_clk,
  output               pcie_link_status,
  output               heartbeat
);


wire [255:0] user_str1_wr_data;
wire [255:0] user_str1_rd_data;
wire [31:0]  sys_user_dma_addr;
wire [31:0]  user_sys_dma_addr;
wire [31:0]  sys_user_dma_len;
wire [31:0]  user_sys_dma_len; 
wire [31:0]  user_wr_data;
wire [31:0]  user_addr;
wire [31:0]  user_rd_data;

//assign o_axi_clk = pcie_clk;
assign o_axi_strm_clk = user_clk;

// Instantiate the module
(*KEEP_HIERARCHY = "SOFT"*)
pcie_top #(
     .RECONFIG_ENABLE(RECONFIG_ENABLE) 
     )
     pcie (
    .pci_exp_txp(pci_exp_txp), 
    .pci_exp_txn(pci_exp_txn), 
    .pci_exp_rxp(pci_exp_rxp), 
    .pci_exp_rxn(pci_exp_rxn), 
    .sys_clk_p(sys_clk_p), 
    .sys_clk_n(sys_clk_n), 
    .sys_reset_n(sys_reset_n), 
    .user_clk_o(user_clk), 
    .pcie_clk_o(pcie_clk),
    .user_reset_o(user_reset),
    //user stream interface 
    .user_intr_req_i(1'b0), 
    .user_intr_ack_o(), 
    .user_str_data_valid_o(o_wr_data_valid),
    .user_str_ack_i(i_wr_data_ready),
    .user_str_data_o(o_wr_data),
    .user_str_data_valid_i(i_rd_data_valid),
    .user_str_ack_o(o_rd_data_ready),
    .user_str_data_i(i_rd_data),
    .sys_user_dma_addr_o(),
    .user_sys_dma_addr_o(),
    .sys_user_dma_len_o(), 
    .user_sys_dma_len_o(), 
    .user_sys_dma_en_o(),
    .sys_user_dma_en_o(),
    //
    .user_data_o(), 
    .user_addr_o(),
    .user_wr_req_o(),
    .user_wr_ack_i(1'b0),
    .user_data_i(1'b0),
    .user_rd_ack_i(1'b0), 
    .user_rd_req_o(),   
    //
    .pcie_link_status(pcie_link_status)
);

reg   [28:0] led_counter;

always @( posedge user_clk)
begin
    led_counter <= led_counter + 1;
end

assign heartbeat = led_counter[27];
	 
endmodule
	 
