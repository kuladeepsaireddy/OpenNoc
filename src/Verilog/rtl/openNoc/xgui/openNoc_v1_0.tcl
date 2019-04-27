
# Loading additional proc with user specified bodies to compute parameter values.
source [file join [file dirname [file dirname [info script]]] gui/openNoc_v1_0.gtcl]

# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "X" -parent ${Page_0}
  ipgui::add_param $IPINST -name "Y" -parent ${Page_0}
  ipgui::add_param $IPINST -name "data_width" -parent ${Page_0}

  ipgui::add_param $IPINST -name "pkt_no_field_size"

}

proc update_PARAM_VALUE.if_width { PARAM_VALUE.if_width PARAM_VALUE.total_width PARAM_VALUE.X PARAM_VALUE.Y } {
	# Procedure called to update if_width when any of the dependent parameters in the arguments change
	
	set if_width ${PARAM_VALUE.if_width}
	set total_width ${PARAM_VALUE.total_width}
	set X ${PARAM_VALUE.X}
	set Y ${PARAM_VALUE.Y}
	set values(total_width) [get_property value $total_width]
	set values(X) [get_property value $X]
	set values(Y) [get_property value $Y]
	set_property value [gen_USERPARAMETER_if_width_VALUE $values(total_width) $values(X) $values(Y)] $if_width
}

proc validate_PARAM_VALUE.if_width { PARAM_VALUE.if_width } {
	# Procedure called to validate if_width
	return true
}

proc update_PARAM_VALUE.total_width { PARAM_VALUE.total_width PARAM_VALUE.x_size PARAM_VALUE.y_size PARAM_VALUE.data_width PARAM_VALUE.pkt_no_field_size } {
	# Procedure called to update total_width when any of the dependent parameters in the arguments change
	
	set total_width ${PARAM_VALUE.total_width}
	set x_size ${PARAM_VALUE.x_size}
	set y_size ${PARAM_VALUE.y_size}
	set data_width ${PARAM_VALUE.data_width}
	set pkt_no_field_size ${PARAM_VALUE.pkt_no_field_size}
	set values(x_size) [get_property value $x_size]
	set values(y_size) [get_property value $y_size]
	set values(data_width) [get_property value $data_width]
	set values(pkt_no_field_size) [get_property value $pkt_no_field_size]
	set_property value [gen_USERPARAMETER_total_width_VALUE $values(x_size) $values(y_size) $values(data_width) $values(pkt_no_field_size)] $total_width
}

proc validate_PARAM_VALUE.total_width { PARAM_VALUE.total_width } {
	# Procedure called to validate total_width
	return true
}

proc update_PARAM_VALUE.x_size { PARAM_VALUE.x_size PARAM_VALUE.X } {
	# Procedure called to update x_size when any of the dependent parameters in the arguments change
	
	set x_size ${PARAM_VALUE.x_size}
	set X ${PARAM_VALUE.X}
	set values(X) [get_property value $X]
	set_property value [gen_USERPARAMETER_x_size_VALUE $values(X)] $x_size
}

proc validate_PARAM_VALUE.x_size { PARAM_VALUE.x_size } {
	# Procedure called to validate x_size
	return true
}

proc update_PARAM_VALUE.y_size { PARAM_VALUE.y_size PARAM_VALUE.X } {
	# Procedure called to update y_size when any of the dependent parameters in the arguments change
	
	set y_size ${PARAM_VALUE.y_size}
	set X ${PARAM_VALUE.X}
	set values(X) [get_property value $X]
	set_property value [gen_USERPARAMETER_y_size_VALUE $values(X)] $y_size
}

proc validate_PARAM_VALUE.y_size { PARAM_VALUE.y_size } {
	# Procedure called to validate y_size
	return true
}

proc update_PARAM_VALUE.X { PARAM_VALUE.X } {
	# Procedure called to update X when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.X { PARAM_VALUE.X } {
	# Procedure called to validate X
	return true
}

proc update_PARAM_VALUE.Y { PARAM_VALUE.Y } {
	# Procedure called to update Y when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.Y { PARAM_VALUE.Y } {
	# Procedure called to validate Y
	return true
}

proc update_PARAM_VALUE.data_width { PARAM_VALUE.data_width } {
	# Procedure called to update data_width when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.data_width { PARAM_VALUE.data_width } {
	# Procedure called to validate data_width
	return true
}

proc update_PARAM_VALUE.pkt_no_field_size { PARAM_VALUE.pkt_no_field_size } {
	# Procedure called to update pkt_no_field_size when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.pkt_no_field_size { PARAM_VALUE.pkt_no_field_size } {
	# Procedure called to validate pkt_no_field_size
	return true
}


proc update_MODELPARAM_VALUE.X { MODELPARAM_VALUE.X PARAM_VALUE.X } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.X}] ${MODELPARAM_VALUE.X}
}

proc update_MODELPARAM_VALUE.Y { MODELPARAM_VALUE.Y PARAM_VALUE.Y } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.Y}] ${MODELPARAM_VALUE.Y}
}

proc update_MODELPARAM_VALUE.data_width { MODELPARAM_VALUE.data_width PARAM_VALUE.data_width } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.data_width}] ${MODELPARAM_VALUE.data_width}
}

proc update_MODELPARAM_VALUE.x_size { MODELPARAM_VALUE.x_size PARAM_VALUE.x_size } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.x_size}] ${MODELPARAM_VALUE.x_size}
}

proc update_MODELPARAM_VALUE.y_size { MODELPARAM_VALUE.y_size PARAM_VALUE.y_size } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.y_size}] ${MODELPARAM_VALUE.y_size}
}

proc update_MODELPARAM_VALUE.total_width { MODELPARAM_VALUE.total_width PARAM_VALUE.total_width } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.total_width}] ${MODELPARAM_VALUE.total_width}
}

proc update_MODELPARAM_VALUE.pkt_no_field_size { MODELPARAM_VALUE.pkt_no_field_size PARAM_VALUE.pkt_no_field_size } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.pkt_no_field_size}] ${MODELPARAM_VALUE.pkt_no_field_size}
}

proc update_MODELPARAM_VALUE.if_width { MODELPARAM_VALUE.if_width PARAM_VALUE.if_width } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.if_width}] ${MODELPARAM_VALUE.if_width}
}

