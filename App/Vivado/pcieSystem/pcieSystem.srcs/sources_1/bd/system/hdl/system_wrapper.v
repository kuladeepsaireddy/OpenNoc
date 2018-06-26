//Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2017.3 (lin64) Build 2018833 Wed Oct  4 19:58:07 MDT 2017
//Date        : Tue Mar 20 18:52:18 2018
//Host        : vipin-ESPRIMO-P756 running 64-bit Ubuntu 16.04.3 LTS
//Command     : generate_target system_wrapper.bd
//Design      : system_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module system_wrapper
   (heartbeat_0,
    pci_exp_rxn_0,
    pci_exp_rxp_0,
    pci_exp_txn_0,
    pci_exp_txp_0,
    pcie_link_status_0,
    sys_clk_n_0,
    sys_clk_p_0,
    sys_reset_n_0);
  output heartbeat_0;
  input [7:0]pci_exp_rxn_0;
  input [7:0]pci_exp_rxp_0;
  output [7:0]pci_exp_txn_0;
  output [7:0]pci_exp_txp_0;
  output pcie_link_status_0;
  input sys_clk_n_0;
  input sys_clk_p_0;
  input sys_reset_n_0;

  wire heartbeat_0;
  wire [7:0]pci_exp_rxn_0;
  wire [7:0]pci_exp_rxp_0;
  wire [7:0]pci_exp_txn_0;
  wire [7:0]pci_exp_txp_0;
  wire pcie_link_status_0;
  wire sys_clk_n_0;
  wire sys_clk_p_0;
  wire sys_reset_n_0;

  system system_i
       (.heartbeat_0(heartbeat_0),
        .pci_exp_rxn_0(pci_exp_rxn_0),
        .pci_exp_rxp_0(pci_exp_rxp_0),
        .pci_exp_txn_0(pci_exp_txn_0),
        .pci_exp_txp_0(pci_exp_txp_0),
        .pcie_link_status_0(pcie_link_status_0),
        .sys_clk_n_0(sys_clk_n_0),
        .sys_clk_p_0(sys_clk_p_0),
        .sys_reset_n_0(sys_reset_n_0));
endmodule
