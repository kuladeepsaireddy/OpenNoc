// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.3 (lin64) Build 2018833 Wed Oct  4 19:58:07 MDT 2017
// Date        : Tue Mar 20 18:57:17 2018
// Host        : vipin-ESPRIMO-P756 running 64-bit Ubuntu 16.04.3 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/vipin/workspace/Research/mygit/OpenNoc/App/Vivado/pcieSystem/pcieSystem.srcs/sources_1/bd/system/ip/system_dyract_0_1/system_dyract_0_1_stub.v
// Design      : system_dyract_0_1
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1761-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "dyract,Vivado 2017.3" *)
module system_dyract_0_1(pci_exp_rxp, pci_exp_rxn, pci_exp_txp, 
  pci_exp_txn, sys_clk_p, sys_clk_n, sys_reset_n, o_wr_data_valid, i_wr_data_ready, o_wr_data, 
  i_rd_data_valid, o_rd_data_ready, i_rd_data, o_axi_strm_clk, pcie_link_status, heartbeat)
/* synthesis syn_black_box black_box_pad_pin="pci_exp_rxp[7:0],pci_exp_rxn[7:0],pci_exp_txp[7:0],pci_exp_txn[7:0],sys_clk_p,sys_clk_n,sys_reset_n,o_wr_data_valid,i_wr_data_ready,o_wr_data[255:0],i_rd_data_valid,o_rd_data_ready,i_rd_data[255:0],o_axi_strm_clk,pcie_link_status,heartbeat" */;
  input [7:0]pci_exp_rxp;
  input [7:0]pci_exp_rxn;
  output [7:0]pci_exp_txp;
  output [7:0]pci_exp_txn;
  input sys_clk_p;
  input sys_clk_n;
  input sys_reset_n;
  output o_wr_data_valid;
  input i_wr_data_ready;
  output [255:0]o_wr_data;
  input i_rd_data_valid;
  output o_rd_data_ready;
  input [255:0]i_rd_data;
  output o_axi_strm_clk;
  output pcie_link_status;
  output heartbeat;
endmodule
