## Generated SDC file "switch.sdc"

## Copyright (C) 2017  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel MegaCore Function License Agreement, or other 
## applicable license agreement, including, without limitation, 
## that your use is for the sole purpose of programming logic 
## devices manufactured by Intel and sold by Intel or its 
## authorized distributors.  Please refer to the applicable 
## agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 17.0.0 Build 595 04/25/2017 SJ Lite Edition"

## DATE    "Tue Oct 24 12:36:26 2017"

##
## DEVICE  "EP2AGX45CU17C4"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk} -period 4.000 -waveform { 0.000 2.000 } [get_ports {clk}]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {clk}] -rise_to [get_clocks {clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clk}] -fall_to [get_clocks {clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk}] -rise_to [get_clocks {clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk}] -fall_to [get_clocks {clk}]  0.020  


#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_b[0]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_b[1]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_b[2]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_b[3]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_b[4]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_b[5]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_b[6]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_b[7]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_b[8]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_b[9]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_b[10]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_b[11]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_l[0]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_l[1]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_l[2]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_l[3]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_l[4]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_l[5]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_l[6]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_l[7]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_l[8]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_l[9]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_l[10]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_l[11]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_pe[0]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_pe[1]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_pe[2]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_pe[3]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_pe[4]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_pe[5]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_pe[6]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_pe[7]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_pe[8]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_pe[9]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_pe[10]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_data_pe[11]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_ready_r}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_ready_t}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_valid_b}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_valid_l}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {i_valid_pe}]


#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

