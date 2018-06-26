// (c) Copyright 1995-2018 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:user:dyract:1.0
// IP Revision: 5

(* X_CORE_INFO = "dyract,Vivado 2017.3" *)
(* CHECK_LICENSE_TYPE = "system_dyract_0_1,dyract,{}" *)
(* CORE_GENERATION_INFO = "system_dyract_0_1,dyract,{x_ipProduct=Vivado 2017.3,x_ipVendor=xilinx.com,x_ipLibrary=user,x_ipName=dyract,x_ipVersion=1.0,x_ipCoreRevision=5,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,RECONFIG_ENABLE=0}" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module system_dyract_0_1 (
  pci_exp_rxp,
  pci_exp_rxn,
  pci_exp_txp,
  pci_exp_txn,
  sys_clk_p,
  sys_clk_n,
  sys_reset_n,
  o_wr_data_valid,
  i_wr_data_ready,
  o_wr_data,
  i_rd_data_valid,
  o_rd_data_ready,
  i_rd_data,
  o_axi_strm_clk,
  pcie_link_status,
  heartbeat
);

input wire [7 : 0] pci_exp_rxp;
input wire [7 : 0] pci_exp_rxn;
output wire [7 : 0] pci_exp_txp;
output wire [7 : 0] pci_exp_txn;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME sys_clk_p, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN system_sys_clk_p_0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 sys_clk_p CLK" *)
input wire sys_clk_p;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME sys_clk_n, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN system_sys_clk_p_0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 sys_clk_n CLK" *)
input wire sys_clk_n;
input wire sys_reset_n;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 Stream_Wr TVALID" *)
output wire o_wr_data_valid;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 Stream_Wr TREADY" *)
input wire i_wr_data_ready;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME Stream_Wr, TDATA_NUM_BYTES 32, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN system_dyract_0_1_o_axi_strm_clk, LAYERED_METADATA undef" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 Stream_Wr TDATA" *)
output wire [255 : 0] o_wr_data;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 Stream_Rd TVALID" *)
input wire i_rd_data_valid;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 Stream_Rd TREADY" *)
output wire o_rd_data_ready;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME Stream_Rd, TDATA_NUM_BYTES 32, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN system_dyract_0_1_o_axi_strm_clk, LAYERED_METADATA undef" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 Stream_Rd TDATA" *)
input wire [255 : 0] i_rd_data;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME o_axi_strm_clk, ASSOCIATED_BUSIF Stream_Wr:Stream_Rd, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN system_dyract_0_1_o_axi_strm_clk" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 o_axi_strm_clk CLK" *)
output wire o_axi_strm_clk;
output wire pcie_link_status;
output wire heartbeat;

  dyract #(
    .RECONFIG_ENABLE(0)
  ) inst (
    .pci_exp_rxp(pci_exp_rxp),
    .pci_exp_rxn(pci_exp_rxn),
    .pci_exp_txp(pci_exp_txp),
    .pci_exp_txn(pci_exp_txn),
    .sys_clk_p(sys_clk_p),
    .sys_clk_n(sys_clk_n),
    .sys_reset_n(sys_reset_n),
    .o_wr_data_valid(o_wr_data_valid),
    .i_wr_data_ready(i_wr_data_ready),
    .o_wr_data(o_wr_data),
    .i_rd_data_valid(i_rd_data_valid),
    .o_rd_data_ready(o_rd_data_ready),
    .i_rd_data(i_rd_data),
    .o_axi_strm_clk(o_axi_strm_clk),
    .pcie_link_status(pcie_link_status),
    .heartbeat(heartbeat)
  );
endmodule
