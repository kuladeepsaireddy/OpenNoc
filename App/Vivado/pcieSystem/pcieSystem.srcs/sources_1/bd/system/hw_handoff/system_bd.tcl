
################################################################
# This is a generated script based on design: system
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2017.3
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source system_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7vx690tffg1761-2
   set_property BOARD_PART xilinx.com:vc709:part0:1.8 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name system

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports

  # Create ports
  set heartbeat_0 [ create_bd_port -dir O heartbeat_0 ]
  set pci_exp_rxn_0 [ create_bd_port -dir I -from 7 -to 0 pci_exp_rxn_0 ]
  set pci_exp_rxp_0 [ create_bd_port -dir I -from 7 -to 0 pci_exp_rxp_0 ]
  set pci_exp_txn_0 [ create_bd_port -dir O -from 7 -to 0 pci_exp_txn_0 ]
  set pci_exp_txp_0 [ create_bd_port -dir O -from 7 -to 0 pci_exp_txp_0 ]
  set pcie_link_status_0 [ create_bd_port -dir O pcie_link_status_0 ]
  set sys_clk_n_0 [ create_bd_port -dir I -type clk sys_clk_n_0 ]
  set_property -dict [ list \
   CONFIG.CLK_DOMAIN {system_sys_clk_p_0} \
 ] $sys_clk_n_0
  set sys_clk_p_0 [ create_bd_port -dir I -type clk sys_clk_p_0 ]
  set_property -dict [ list \
   CONFIG.CLK_DOMAIN {system_sys_clk_p_0} \
 ] $sys_clk_p_0
  set sys_reset_n_0 [ create_bd_port -dir I sys_reset_n_0 ]

  # Create instance: dyract_0, and set properties
  set dyract_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:dyract:1.0 dyract_0 ]

  # Create instance: imgProc_0, and set properties
  set imgProc_0 [ create_bd_cell -type ip -vlnv Kuladeep:user:imgProc:1.0 imgProc_0 ]

  # Create instance: openNoc_0, and set properties
  set openNoc_0 [ create_bd_cell -type ip -vlnv Kuladeep:user:openNoc:1.0 openNoc_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net dyract_0_Stream_Wr [get_bd_intf_pins dyract_0/Stream_Wr] [get_bd_intf_pins imgProc_0/pciS]
  connect_bd_intf_net -intf_net imgProc_0_imgRd [get_bd_intf_pins imgProc_0/imgRd] [get_bd_intf_pins openNoc_0/peRead]
  connect_bd_intf_net -intf_net imgProc_0_pciM [get_bd_intf_pins dyract_0/Stream_Rd] [get_bd_intf_pins imgProc_0/pciM]
  connect_bd_intf_net -intf_net openNoc_0_peWrite [get_bd_intf_pins imgProc_0/imgWr] [get_bd_intf_pins openNoc_0/peWrite]

  # Create port connections
  connect_bd_net -net dyract_0_heartbeat [get_bd_ports heartbeat_0] [get_bd_pins dyract_0/heartbeat]
  connect_bd_net -net dyract_0_o_axi_strm_clk [get_bd_pins dyract_0/o_axi_strm_clk] [get_bd_pins imgProc_0/clk] [get_bd_pins openNoc_0/clk]
  connect_bd_net -net dyract_0_pci_exp_txn [get_bd_ports pci_exp_txn_0] [get_bd_pins dyract_0/pci_exp_txn]
  connect_bd_net -net dyract_0_pci_exp_txp [get_bd_ports pci_exp_txp_0] [get_bd_pins dyract_0/pci_exp_txp]
  connect_bd_net -net dyract_0_pcie_link_status [get_bd_ports pcie_link_status_0] [get_bd_pins dyract_0/pcie_link_status]
  connect_bd_net -net pci_exp_rxn_0_1 [get_bd_ports pci_exp_rxn_0] [get_bd_pins dyract_0/pci_exp_rxn]
  connect_bd_net -net pci_exp_rxp_0_1 [get_bd_ports pci_exp_rxp_0] [get_bd_pins dyract_0/pci_exp_rxp]
  connect_bd_net -net sys_clk_n_0_1 [get_bd_ports sys_clk_n_0] [get_bd_pins dyract_0/sys_clk_n]
  connect_bd_net -net sys_clk_p_0_1 [get_bd_ports sys_clk_p_0] [get_bd_pins dyract_0/sys_clk_p]
  connect_bd_net -net sys_reset_n_0_1 [get_bd_ports sys_reset_n_0] [get_bd_pins dyract_0/sys_reset_n] [get_bd_pins imgProc_0/rstn] [get_bd_pins openNoc_0/rstn]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


