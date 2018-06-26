-- Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2017.3 (lin64) Build 2018833 Wed Oct  4 19:58:07 MDT 2017
-- Date        : Tue Mar 20 18:40:56 2018
-- Host        : vipin-ESPRIMO-P756 running 64-bit Ubuntu 16.04.3 LTS
-- Command     : write_vhdl -force -mode synth_stub
--               /home/vipin/workspace/Research/mygit/OpenNoc/App/Vivado/pcieSystem/pcieSystem.srcs/sources_1/bd/system/ip/system_imgProc_0_0/system_imgProc_0_0_stub.vhdl
-- Design      : system_imgProc_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7vx690tffg1761-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity system_imgProc_0_0 is
  Port ( 
    clk : in STD_LOGIC;
    rstn : in STD_LOGIC;
    r_valid_pe : out STD_LOGIC_VECTOR ( 15 downto 0 );
    r_data_pe : out STD_LOGIC_VECTOR ( 4159 downto 0 );
    r_ready_pe : in STD_LOGIC_VECTOR ( 15 downto 0 );
    w_valid_pe : in STD_LOGIC_VECTOR ( 15 downto 0 );
    w_data_pe : in STD_LOGIC_VECTOR ( 4159 downto 0 );
    i_valid_pci : in STD_LOGIC;
    i_data_pci : in STD_LOGIC_VECTOR ( 255 downto 0 );
    o_ready_pci : out STD_LOGIC;
    o_data_pci : out STD_LOGIC_VECTOR ( 255 downto 0 );
    o_valid_pci : out STD_LOGIC;
    i_ready_pci : in STD_LOGIC
  );

end system_imgProc_0_0;

architecture stub of system_imgProc_0_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,rstn,r_valid_pe[15:0],r_data_pe[4159:0],r_ready_pe[15:0],w_valid_pe[15:0],w_data_pe[4159:0],i_valid_pci,i_data_pci[255:0],o_ready_pci,o_data_pci[255:0],o_valid_pci,i_ready_pci";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "procTop,Vivado 2017.3";
begin
end;
