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


// IP VLNV: Kuladeep:user:imgProc:1.0
// IP Revision: 5

(* X_CORE_INFO = "procTop,Vivado 2017.3" *)
(* CHECK_LICENSE_TYPE = "system_imgProc_0_0,procTop,{}" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module system_imgProc_0_0 (
  clk,
  rstn,
  r_valid_pe,
  r_data_pe,
  r_ready_pe,
  w_valid_pe,
  w_data_pe,
  i_valid_pci,
  i_data_pci,
  o_ready_pci,
  o_data_pci,
  o_valid_pci,
  i_ready_pci
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME clk, ASSOCIATED_RESET rstn, ASSOCIATED_BUSIF imgWr:imgRd:pciM:pciS, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN system_dyract_0_0_o_axi_strm_clk" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *)
input wire clk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME rstn, POLARITY ACTIVE_LOW" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 rstn RST" *)
input wire rstn;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 imgRd TVALID" *)
output wire [15 : 0] r_valid_pe;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 imgRd TDATA" *)
output wire [4159 : 0] r_data_pe;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME imgRd, TDATA_NUM_BYTES 520, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN system_dyract_0_0_o_axi_strm_clk, LAYERED_METADATA undef" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 imgRd TREADY" *)
input wire [15 : 0] r_ready_pe;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 imgWr TVALID" *)
input wire [15 : 0] w_valid_pe;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME imgWr, TDATA_NUM_BYTES 520, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 0, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN system_dyract_0_0_o_axi_strm_clk, LAYERED_METADATA undef" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 imgWr TDATA" *)
input wire [4159 : 0] w_data_pe;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 pciS TVALID" *)
input wire i_valid_pci;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 pciS TDATA" *)
input wire [255 : 0] i_data_pci;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME pciS, TDATA_NUM_BYTES 32, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN system_dyract_0_0_o_axi_strm_clk, LAYERED_METADATA undef" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 pciS TREADY" *)
output wire o_ready_pci;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 pciM TDATA" *)
output wire [255 : 0] o_data_pci;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 pciM TVALID" *)
output wire o_valid_pci;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME pciM, TDATA_NUM_BYTES 32, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN system_dyract_0_0_o_axi_strm_clk, LAYERED_METADATA undef" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 pciM TREADY" *)
input wire i_ready_pci;

  procTop inst (
    .clk(clk),
    .rstn(rstn),
    .r_valid_pe(r_valid_pe),
    .r_data_pe(r_data_pe),
    .r_ready_pe(r_ready_pe),
    .w_valid_pe(w_valid_pe),
    .w_data_pe(w_data_pe),
    .i_valid_pci(i_valid_pci),
    .i_data_pci(i_data_pci),
    .o_ready_pci(o_ready_pci),
    .o_data_pci(o_data_pci),
    .o_valid_pci(o_valid_pci),
    .i_ready_pci(i_ready_pci)
  );
endmodule
