// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.3 (lin64) Build 2018833 Wed Oct  4 19:58:07 MDT 2017
// Date        : Tue Mar 20 18:40:56 2018
// Host        : vipin-ESPRIMO-P756 running 64-bit Ubuntu 16.04.3 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/vipin/workspace/Research/mygit/OpenNoc/App/Vivado/pcieSystem/pcieSystem.srcs/sources_1/bd/system/ip/system_imgProc_0_0/system_imgProc_0_0_stub.v
// Design      : system_imgProc_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1761-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "procTop,Vivado 2017.3" *)
module system_imgProc_0_0(clk, rstn, r_valid_pe, r_data_pe, r_ready_pe, 
  w_valid_pe, w_data_pe, i_valid_pci, i_data_pci, o_ready_pci, o_data_pci, o_valid_pci, 
  i_ready_pci)
/* synthesis syn_black_box black_box_pad_pin="clk,rstn,r_valid_pe[15:0],r_data_pe[4159:0],r_ready_pe[15:0],w_valid_pe[15:0],w_data_pe[4159:0],i_valid_pci,i_data_pci[255:0],o_ready_pci,o_data_pci[255:0],o_valid_pci,i_ready_pci" */;
  input clk;
  input rstn;
  output [15:0]r_valid_pe;
  output [4159:0]r_data_pe;
  input [15:0]r_ready_pe;
  input [15:0]w_valid_pe;
  input [4159:0]w_data_pe;
  input i_valid_pci;
  input [255:0]i_data_pci;
  output o_ready_pci;
  output [255:0]o_data_pci;
  output o_valid_pci;
  input i_ready_pci;
endmodule
