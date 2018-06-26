-- Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2017.3 (lin64) Build 2018833 Wed Oct  4 19:58:07 MDT 2017
-- Date        : Tue Mar 20 18:57:17 2018
-- Host        : vipin-ESPRIMO-P756 running 64-bit Ubuntu 16.04.3 LTS
-- Command     : write_vhdl -force -mode synth_stub
--               /home/vipin/workspace/Research/mygit/OpenNoc/App/Vivado/pcieSystem/pcieSystem.srcs/sources_1/bd/system/ip/system_dyract_0_1/system_dyract_0_1_stub.vhdl
-- Design      : system_dyract_0_1
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7vx690tffg1761-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity system_dyract_0_1 is
  Port ( 
    pci_exp_rxp : in STD_LOGIC_VECTOR ( 7 downto 0 );
    pci_exp_rxn : in STD_LOGIC_VECTOR ( 7 downto 0 );
    pci_exp_txp : out STD_LOGIC_VECTOR ( 7 downto 0 );
    pci_exp_txn : out STD_LOGIC_VECTOR ( 7 downto 0 );
    sys_clk_p : in STD_LOGIC;
    sys_clk_n : in STD_LOGIC;
    sys_reset_n : in STD_LOGIC;
    o_wr_data_valid : out STD_LOGIC;
    i_wr_data_ready : in STD_LOGIC;
    o_wr_data : out STD_LOGIC_VECTOR ( 255 downto 0 );
    i_rd_data_valid : in STD_LOGIC;
    o_rd_data_ready : out STD_LOGIC;
    i_rd_data : in STD_LOGIC_VECTOR ( 255 downto 0 );
    o_axi_strm_clk : out STD_LOGIC;
    pcie_link_status : out STD_LOGIC;
    heartbeat : out STD_LOGIC
  );

end system_dyract_0_1;

architecture stub of system_dyract_0_1 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "pci_exp_rxp[7:0],pci_exp_rxn[7:0],pci_exp_txp[7:0],pci_exp_txn[7:0],sys_clk_p,sys_clk_n,sys_reset_n,o_wr_data_valid,i_wr_data_ready,o_wr_data[255:0],i_rd_data_valid,o_rd_data_ready,i_rd_data[255:0],o_axi_strm_clk,pcie_link_status,heartbeat";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "dyract,Vivado 2017.3";
begin
end;
