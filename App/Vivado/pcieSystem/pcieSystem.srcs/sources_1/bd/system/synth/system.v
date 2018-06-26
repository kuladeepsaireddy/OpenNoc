//Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2017.3 (lin64) Build 2018833 Wed Oct  4 19:58:07 MDT 2017
//Date        : Tue Mar 20 18:52:18 2018
//Host        : vipin-ESPRIMO-P756 running 64-bit Ubuntu 16.04.3 LTS
//Command     : generate_target system.bd
//Design      : system
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "system,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=system,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=3,numReposBlks=3,numNonXlnxBlks=2,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,da_clkrst_cnt=2,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "system.hwdef" *) 
module system
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
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.SYS_CLK_N_0 CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.SYS_CLK_N_0, CLK_DOMAIN system_sys_clk_p_0, FREQ_HZ 100000000, PHASE 0.000" *) input sys_clk_n_0;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.SYS_CLK_P_0 CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.SYS_CLK_P_0, CLK_DOMAIN system_sys_clk_p_0, FREQ_HZ 100000000, PHASE 0.000" *) input sys_clk_p_0;
  input sys_reset_n_0;

  wire [255:0]dyract_0_Stream_Wr_TDATA;
  wire dyract_0_Stream_Wr_TREADY;
  wire dyract_0_Stream_Wr_TVALID;
  wire dyract_0_heartbeat;
  wire dyract_0_o_axi_strm_clk;
  wire [7:0]dyract_0_pci_exp_txn;
  wire [7:0]dyract_0_pci_exp_txp;
  wire dyract_0_pcie_link_status;
  wire [4159:0]imgProc_0_imgRd_TDATA;
  wire [15:0]imgProc_0_imgRd_TREADY;
  wire [15:0]imgProc_0_imgRd_TVALID;
  wire [255:0]imgProc_0_pciM_TDATA;
  wire imgProc_0_pciM_TREADY;
  wire imgProc_0_pciM_TVALID;
  wire [4159:0]openNoc_0_peWrite_TDATA;
  wire [15:0]openNoc_0_peWrite_TVALID;
  wire [7:0]pci_exp_rxn_0_1;
  wire [7:0]pci_exp_rxp_0_1;
  wire sys_clk_n_0_1;
  wire sys_clk_p_0_1;
  wire sys_reset_n_0_1;

  assign heartbeat_0 = dyract_0_heartbeat;
  assign pci_exp_rxn_0_1 = pci_exp_rxn_0[7:0];
  assign pci_exp_rxp_0_1 = pci_exp_rxp_0[7:0];
  assign pci_exp_txn_0[7:0] = dyract_0_pci_exp_txn;
  assign pci_exp_txp_0[7:0] = dyract_0_pci_exp_txp;
  assign pcie_link_status_0 = dyract_0_pcie_link_status;
  assign sys_clk_n_0_1 = sys_clk_n_0;
  assign sys_clk_p_0_1 = sys_clk_p_0;
  assign sys_reset_n_0_1 = sys_reset_n_0;
  system_dyract_0_1 dyract_0
       (.heartbeat(dyract_0_heartbeat),
        .i_rd_data(imgProc_0_pciM_TDATA),
        .i_rd_data_valid(imgProc_0_pciM_TVALID),
        .i_wr_data_ready(dyract_0_Stream_Wr_TREADY),
        .o_axi_strm_clk(dyract_0_o_axi_strm_clk),
        .o_rd_data_ready(imgProc_0_pciM_TREADY),
        .o_wr_data(dyract_0_Stream_Wr_TDATA),
        .o_wr_data_valid(dyract_0_Stream_Wr_TVALID),
        .pci_exp_rxn(pci_exp_rxn_0_1),
        .pci_exp_rxp(pci_exp_rxp_0_1),
        .pci_exp_txn(dyract_0_pci_exp_txn),
        .pci_exp_txp(dyract_0_pci_exp_txp),
        .pcie_link_status(dyract_0_pcie_link_status),
        .sys_clk_n(sys_clk_n_0_1),
        .sys_clk_p(sys_clk_p_0_1),
        .sys_reset_n(sys_reset_n_0_1));
  system_imgProc_0_0 imgProc_0
       (.clk(dyract_0_o_axi_strm_clk),
        .i_data_pci(dyract_0_Stream_Wr_TDATA),
        .i_ready_pci(imgProc_0_pciM_TREADY),
        .i_valid_pci(dyract_0_Stream_Wr_TVALID),
        .o_data_pci(imgProc_0_pciM_TDATA),
        .o_ready_pci(dyract_0_Stream_Wr_TREADY),
        .o_valid_pci(imgProc_0_pciM_TVALID),
        .r_data_pe(imgProc_0_imgRd_TDATA),
        .r_ready_pe(imgProc_0_imgRd_TREADY),
        .r_valid_pe(imgProc_0_imgRd_TVALID),
        .rstn(sys_reset_n_0_1),
        .w_data_pe(openNoc_0_peWrite_TDATA),
        .w_valid_pe(openNoc_0_peWrite_TVALID));
  system_openNoc_0_0 openNoc_0
       (.clk(dyract_0_o_axi_strm_clk),
        .r_data_pe(imgProc_0_imgRd_TDATA),
        .r_ready_pe(imgProc_0_imgRd_TREADY),
        .r_valid_pe(imgProc_0_imgRd_TVALID),
        .rstn(sys_reset_n_0_1),
        .w_data_pe(openNoc_0_peWrite_TDATA),
        .w_valid_pe(openNoc_0_peWrite_TVALID));
endmodule
