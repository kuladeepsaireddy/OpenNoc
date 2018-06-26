create_clock -period 5.000 [get_ports sys_clk_p_0]

set_property PACKAGE_PIN AV35 [get_ports sys_reset_n_0]
set_property IOSTANDARD LVCMOS18 [get_ports sys_reset_n_0]
set_property PACKAGE_PIN AM39 [get_ports heartbeat_0]
set_property IOSTANDARD LVCMOS18 [get_ports heartbeat_0]
set_property PACKAGE_PIN AR37 [get_ports pcie_link_status_0]
set_property IOSTANDARD LVCMOS18 [get_ports pcie_link_status_0]