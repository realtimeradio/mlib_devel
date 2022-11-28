
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
set scripts_vivado_version 2021.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

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
   create_project project_1 myproj -part xczu11eg-ffvc1760-1-i
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
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

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

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:smartconnect:1.0\
analog.com:user:axi_dmac:1.0\
analog.com:user:axi_adxcvr:1.0\
peralex.com:user:axi_slave_wishbone_classic_master:1.0\
analog.com:user:axi_sysid:1.0\
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:util_reduced_logic:2.0\
xilinx.com:ip:util_vector_logic:2.0\
analog.com:user:sysid_rom:1.0\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:zynq_ultra_ps_e:3.3\
analog.com:user:util_cpack2:1.0\
analog.com:user:util_upack2:1.0\
analog.com:user:util_adxcvr:1.0\
analog.com:user:jesd204_rx:1.0\
analog.com:user:axi_jesd204_rx:1.0\
analog.com:user:jesd204_tx:1.0\
analog.com:user:axi_jesd204_tx:1.0\
analog.com:user:data_offload:1.0\
analog.com:user:util_do_ram:1.0\
analog.com:user:ad_ip_jesd204_tpl_adc:1.0\
xilinx.com:ip:xlslice:1.0\
analog.com:user:ad_ip_jesd204_tpl_dac:1.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: tx_mxfe_tpl_core
proc create_hier_cell_tx_mxfe_tpl_core { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_tx_mxfe_tpl_core() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 link

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi


  # Create pins
  create_bd_pin -dir I -from 255 -to 0 dac_data_0
  create_bd_pin -dir I -from 255 -to 0 dac_data_1
  create_bd_pin -dir I dac_dunf
  create_bd_pin -dir O -from 0 -to 0 dac_enable_0
  create_bd_pin -dir O -from 0 -to 0 dac_enable_1
  create_bd_pin -dir O dac_rst
  create_bd_pin -dir I dac_sync_manual_req_in
  create_bd_pin -dir O dac_sync_manual_req_out
  create_bd_pin -dir O -from 0 -to 0 dac_valid_0
  create_bd_pin -dir O -from 0 -to 0 dac_valid_1
  create_bd_pin -dir I ext_sync_in
  create_bd_pin -dir I -type clk link_clk
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type rst s_axi_aresetn

  # Create instance: dac_tpl_core, and set properties
  set dac_tpl_core [ create_bd_cell -type ip -vlnv analog.com:user:ad_ip_jesd204_tpl_dac:1.0 dac_tpl_core ]
  set_property -dict [ list \
   CONFIG.BITS_PER_SAMPLE {16} \
   CONFIG.CONVERTER_RESOLUTION {16} \
   CONFIG.DMA_BITS_PER_SAMPLE {16} \
   CONFIG.EXT_SYNC {1} \
   CONFIG.IQCORRECTION_DISABLE {0} \
   CONFIG.NUM_CHANNELS {2} \
   CONFIG.NUM_LANES {8} \
   CONFIG.OCTETS_PER_BEAT {8} \
   CONFIG.SAMPLES_PER_FRAME {2} \
 ] $dac_tpl_core

  # Create instance: data_concat0, and set properties
  set data_concat0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 data_concat0 ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {2} \
 ] $data_concat0

  # Create instance: enable_slice_0, and set properties
  set enable_slice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 enable_slice_0 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {0} \
   CONFIG.DIN_TO {0} \
   CONFIG.DIN_WIDTH {2} \
 ] $enable_slice_0

  # Create instance: enable_slice_1, and set properties
  set enable_slice_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 enable_slice_1 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {1} \
   CONFIG.DIN_TO {1} \
   CONFIG.DIN_WIDTH {2} \
 ] $enable_slice_1

  # Create instance: valid_slice_0, and set properties
  set valid_slice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 valid_slice_0 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {0} \
   CONFIG.DIN_TO {0} \
   CONFIG.DIN_WIDTH {2} \
 ] $valid_slice_0

  # Create instance: valid_slice_1, and set properties
  set valid_slice_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 valid_slice_1 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {1} \
   CONFIG.DIN_TO {1} \
   CONFIG.DIN_WIDTH {2} \
 ] $valid_slice_1

  # Create interface connections
  connect_bd_intf_net -intf_net dac_tpl_core_link [get_bd_intf_pins link] [get_bd_intf_pins dac_tpl_core/link]
  connect_bd_intf_net -intf_net s_axi_1 [get_bd_intf_pins s_axi] [get_bd_intf_pins dac_tpl_core/s_axi]

  # Create port connections
  connect_bd_net -net dac_data_0_1 [get_bd_pins dac_data_0] [get_bd_pins data_concat0/In0]
  connect_bd_net -net dac_data_1_1 [get_bd_pins dac_data_1] [get_bd_pins data_concat0/In1]
  connect_bd_net -net dac_dunf_1 [get_bd_pins dac_dunf] [get_bd_pins dac_tpl_core/dac_dunf]
  connect_bd_net -net dac_sync_manual_req_in_1 [get_bd_pins dac_sync_manual_req_in] [get_bd_pins dac_tpl_core/dac_sync_manual_req_in]
  connect_bd_net -net dac_tpl_core_dac_rst [get_bd_pins dac_rst] [get_bd_pins dac_tpl_core/dac_rst]
  connect_bd_net -net dac_tpl_core_dac_sync_manual_req_out [get_bd_pins dac_sync_manual_req_out] [get_bd_pins dac_tpl_core/dac_sync_manual_req_out]
  connect_bd_net -net dac_tpl_core_dac_valid [get_bd_pins dac_tpl_core/dac_valid] [get_bd_pins valid_slice_0/Din] [get_bd_pins valid_slice_1/Din]
  connect_bd_net -net dac_tpl_core_enable [get_bd_pins dac_tpl_core/enable] [get_bd_pins enable_slice_0/Din] [get_bd_pins enable_slice_1/Din]
  connect_bd_net -net data_concat0_dout [get_bd_pins dac_tpl_core/dac_ddata] [get_bd_pins data_concat0/dout]
  connect_bd_net -net enable_slice_0_Dout [get_bd_pins dac_enable_0] [get_bd_pins enable_slice_0/Dout]
  connect_bd_net -net enable_slice_1_Dout [get_bd_pins dac_enable_1] [get_bd_pins enable_slice_1/Dout]
  connect_bd_net -net ext_sync_in_1 [get_bd_pins ext_sync_in] [get_bd_pins dac_tpl_core/dac_sync_in]
  connect_bd_net -net link_clk_1 [get_bd_pins link_clk] [get_bd_pins dac_tpl_core/link_clk]
  connect_bd_net -net s_axi_aclk_1 [get_bd_pins s_axi_aclk] [get_bd_pins dac_tpl_core/s_axi_aclk]
  connect_bd_net -net s_axi_aresetn_1 [get_bd_pins s_axi_aresetn] [get_bd_pins dac_tpl_core/s_axi_aresetn]
  connect_bd_net -net valid_slice_0_Dout [get_bd_pins dac_valid_0] [get_bd_pins valid_slice_0/Dout]
  connect_bd_net -net valid_slice_1_Dout [get_bd_pins dac_valid_1] [get_bd_pins valid_slice_1/Dout]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: rx_mxfe_tpl_core
proc create_hier_cell_rx_mxfe_tpl_core { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_rx_mxfe_tpl_core() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi


  # Create pins
  create_bd_pin -dir O -from 255 -to 0 adc_data_0
  create_bd_pin -dir O -from 255 -to 0 adc_data_1
  create_bd_pin -dir I adc_dovf
  create_bd_pin -dir O -from 0 -to 0 adc_enable_0
  create_bd_pin -dir O -from 0 -to 0 adc_enable_1
  create_bd_pin -dir O adc_rst
  create_bd_pin -dir I adc_sync_manual_req_in
  create_bd_pin -dir O adc_sync_manual_req_out
  create_bd_pin -dir O -from 0 -to 0 adc_valid_0
  create_bd_pin -dir O -from 0 -to 0 adc_valid_1
  create_bd_pin -dir I ext_sync_in
  create_bd_pin -dir I -type clk link_clk
  create_bd_pin -dir I -from 511 -to 0 link_data
  create_bd_pin -dir I -from 7 -to 0 link_sof
  create_bd_pin -dir I link_valid
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type rst s_axi_aresetn

  # Create instance: adc_tpl_core, and set properties
  set adc_tpl_core [ create_bd_cell -type ip -vlnv analog.com:user:ad_ip_jesd204_tpl_adc:1.0 adc_tpl_core ]
  set_property -dict [ list \
   CONFIG.BITS_PER_SAMPLE {16} \
   CONFIG.CONVERTER_RESOLUTION {16} \
   CONFIG.DMA_BITS_PER_SAMPLE {16} \
   CONFIG.EXT_SYNC {1} \
   CONFIG.NUM_CHANNELS {2} \
   CONFIG.NUM_LANES {8} \
   CONFIG.OCTETS_PER_BEAT {8} \
   CONFIG.SAMPLES_PER_FRAME {2} \
 ] $adc_tpl_core

  # Create instance: data_slice_0, and set properties
  set data_slice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 data_slice_0 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {255} \
   CONFIG.DIN_TO {0} \
   CONFIG.DIN_WIDTH {512} \
 ] $data_slice_0

  # Create instance: data_slice_1, and set properties
  set data_slice_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 data_slice_1 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {511} \
   CONFIG.DIN_TO {256} \
   CONFIG.DIN_WIDTH {512} \
 ] $data_slice_1

  # Create instance: enable_slice_0, and set properties
  set enable_slice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 enable_slice_0 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {0} \
   CONFIG.DIN_TO {0} \
   CONFIG.DIN_WIDTH {2} \
 ] $enable_slice_0

  # Create instance: enable_slice_1, and set properties
  set enable_slice_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 enable_slice_1 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {1} \
   CONFIG.DIN_TO {1} \
   CONFIG.DIN_WIDTH {2} \
 ] $enable_slice_1

  # Create instance: valid_slice_0, and set properties
  set valid_slice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 valid_slice_0 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {0} \
   CONFIG.DIN_TO {0} \
   CONFIG.DIN_WIDTH {2} \
 ] $valid_slice_0

  # Create instance: valid_slice_1, and set properties
  set valid_slice_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 valid_slice_1 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {1} \
   CONFIG.DIN_TO {1} \
   CONFIG.DIN_WIDTH {2} \
 ] $valid_slice_1

  # Create interface connections
  connect_bd_intf_net -intf_net s_axi_1 [get_bd_intf_pins s_axi] [get_bd_intf_pins adc_tpl_core/s_axi]

  # Create port connections
  connect_bd_net -net adc_dovf_1 [get_bd_pins adc_dovf] [get_bd_pins adc_tpl_core/adc_dovf]
  connect_bd_net -net adc_sync_manual_req_in_1 [get_bd_pins adc_sync_manual_req_in] [get_bd_pins adc_tpl_core/adc_sync_manual_req_in]
  connect_bd_net -net adc_tpl_core_adc_data [get_bd_pins adc_tpl_core/adc_data] [get_bd_pins data_slice_0/Din] [get_bd_pins data_slice_1/Din]
  connect_bd_net -net adc_tpl_core_adc_rst [get_bd_pins adc_rst] [get_bd_pins adc_tpl_core/adc_rst]
  connect_bd_net -net adc_tpl_core_adc_sync_manual_req_out [get_bd_pins adc_sync_manual_req_out] [get_bd_pins adc_tpl_core/adc_sync_manual_req_out]
  connect_bd_net -net adc_tpl_core_adc_valid [get_bd_pins adc_tpl_core/adc_valid] [get_bd_pins valid_slice_0/Din] [get_bd_pins valid_slice_1/Din]
  connect_bd_net -net adc_tpl_core_enable [get_bd_pins adc_tpl_core/enable] [get_bd_pins enable_slice_0/Din] [get_bd_pins enable_slice_1/Din]
  connect_bd_net -net data_slice_0_Dout [get_bd_pins adc_data_0] [get_bd_pins data_slice_0/Dout]
  connect_bd_net -net data_slice_1_Dout [get_bd_pins adc_data_1] [get_bd_pins data_slice_1/Dout]
  connect_bd_net -net enable_slice_0_Dout [get_bd_pins adc_enable_0] [get_bd_pins enable_slice_0/Dout]
  connect_bd_net -net enable_slice_1_Dout [get_bd_pins adc_enable_1] [get_bd_pins enable_slice_1/Dout]
  connect_bd_net -net ext_sync_in_1 [get_bd_pins ext_sync_in] [get_bd_pins adc_tpl_core/adc_sync_in]
  connect_bd_net -net link_clk_1 [get_bd_pins link_clk] [get_bd_pins adc_tpl_core/link_clk]
  connect_bd_net -net link_data_1 [get_bd_pins link_data] [get_bd_pins adc_tpl_core/link_data]
  connect_bd_net -net link_sof_1 [get_bd_pins link_sof] [get_bd_pins adc_tpl_core/link_sof]
  connect_bd_net -net link_valid_1 [get_bd_pins link_valid] [get_bd_pins adc_tpl_core/link_valid]
  connect_bd_net -net s_axi_aclk_1 [get_bd_pins s_axi_aclk] [get_bd_pins adc_tpl_core/s_axi_aclk]
  connect_bd_net -net s_axi_aresetn_1 [get_bd_pins s_axi_aresetn] [get_bd_pins adc_tpl_core/s_axi_aresetn]
  connect_bd_net -net valid_slice_0_Dout [get_bd_pins adc_valid_0] [get_bd_pins valid_slice_0/Dout]
  connect_bd_net -net valid_slice_1_Dout [get_bd_pins adc_valid_1] [get_bd_pins valid_slice_1/Dout]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: mxfe_tx_data_offload
proc create_hier_cell_mxfe_tx_data_offload { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_mxfe_tx_data_offload() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis


  # Create pins
  create_bd_pin -dir I init_req
  create_bd_pin -dir I -type clk m_axis_aclk
  create_bd_pin -dir I -type rst m_axis_aresetn
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type rst s_axi_aresetn
  create_bd_pin -dir I -type clk s_axis_aclk
  create_bd_pin -dir I -type rst s_axis_aresetn
  create_bd_pin -dir I sync_ext

  # Create instance: i_data_offload, and set properties
  set i_data_offload [ create_bd_cell -type ip -vlnv analog.com:user:data_offload:1.0 i_data_offload ]
  set_property -dict [ list \
   CONFIG.DST_CYCLIC_EN {true} \
   CONFIG.DST_DATA_WIDTH {512} \
   CONFIG.MEM_SIZE_LOG2 {18} \
   CONFIG.MEM_TYPE {0} \
   CONFIG.SRC_DATA_WIDTH {512} \
   CONFIG.SYNC_EXT_ADD_INTERNAL_CDC {true} \
   CONFIG.TX_OR_RXN_PATH {1} \
 ] $i_data_offload

  # Create instance: storage_unit, and set properties
  set storage_unit [ create_bd_cell -type ip -vlnv analog.com:user:util_do_ram:1.0 storage_unit ]
  set_property -dict [ list \
   CONFIG.DST_DATA_WIDTH {512} \
   CONFIG.LENGTH_WIDTH {18} \
   CONFIG.SRC_DATA_WIDTH {512} \
 ] $storage_unit

  # Create interface connections
  connect_bd_intf_net -intf_net i_data_offload_m_axis [get_bd_intf_pins m_axis] [get_bd_intf_pins i_data_offload/m_axis]
  connect_bd_intf_net -intf_net i_data_offload_m_storage_axis [get_bd_intf_pins i_data_offload/m_storage_axis] [get_bd_intf_pins storage_unit/s_axis]
  connect_bd_intf_net -intf_net i_data_offload_rd_ctrl [get_bd_intf_pins i_data_offload/rd_ctrl] [get_bd_intf_pins storage_unit/rd_ctrl]
  connect_bd_intf_net -intf_net i_data_offload_wr_ctrl [get_bd_intf_pins i_data_offload/wr_ctrl] [get_bd_intf_pins storage_unit/wr_ctrl]
  connect_bd_intf_net -intf_net s_axi_1 [get_bd_intf_pins s_axi] [get_bd_intf_pins i_data_offload/s_axi]
  connect_bd_intf_net -intf_net s_axis_1 [get_bd_intf_pins s_axis] [get_bd_intf_pins i_data_offload/s_axis]
  connect_bd_intf_net -intf_net storage_unit_m_axis [get_bd_intf_pins i_data_offload/s_storage_axis] [get_bd_intf_pins storage_unit/m_axis]

  # Create port connections
  connect_bd_net -net init_req_1 [get_bd_pins init_req] [get_bd_pins i_data_offload/init_req]
  connect_bd_net -net m_axis_aclk_1 [get_bd_pins m_axis_aclk] [get_bd_pins i_data_offload/m_axis_aclk] [get_bd_pins storage_unit/m_axis_aclk]
  connect_bd_net -net m_axis_aresetn_1 [get_bd_pins m_axis_aresetn] [get_bd_pins i_data_offload/m_axis_aresetn] [get_bd_pins storage_unit/m_axis_aresetn]
  connect_bd_net -net s_axi_aclk_1 [get_bd_pins s_axi_aclk] [get_bd_pins i_data_offload/s_axi_aclk]
  connect_bd_net -net s_axi_aresetn_1 [get_bd_pins s_axi_aresetn] [get_bd_pins i_data_offload/s_axi_aresetn]
  connect_bd_net -net s_axis_aclk_1 [get_bd_pins s_axis_aclk] [get_bd_pins i_data_offload/s_axis_aclk] [get_bd_pins storage_unit/s_axis_aclk]
  connect_bd_net -net s_axis_aresetn_1 [get_bd_pins s_axis_aresetn] [get_bd_pins i_data_offload/s_axis_aresetn] [get_bd_pins storage_unit/s_axis_aresetn]
  connect_bd_net -net sync_ext_1 [get_bd_pins sync_ext] [get_bd_pins i_data_offload/sync_ext]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: mxfe_rx_data_offload
proc create_hier_cell_mxfe_rx_data_offload { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_mxfe_rx_data_offload() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis


  # Create pins
  create_bd_pin -dir I init_req
  create_bd_pin -dir I -type clk m_axis_aclk
  create_bd_pin -dir I -type rst m_axis_aresetn
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type rst s_axi_aresetn
  create_bd_pin -dir I -type clk s_axis_aclk
  create_bd_pin -dir I -type rst s_axis_aresetn
  create_bd_pin -dir I sync_ext

  # Create instance: i_data_offload, and set properties
  set i_data_offload [ create_bd_cell -type ip -vlnv analog.com:user:data_offload:1.0 i_data_offload ]
  set_property -dict [ list \
   CONFIG.DST_CYCLIC_EN {true} \
   CONFIG.DST_DATA_WIDTH {512} \
   CONFIG.MEM_SIZE_LOG2 {18} \
   CONFIG.MEM_TYPE {0} \
   CONFIG.SRC_DATA_WIDTH {512} \
   CONFIG.SYNC_EXT_ADD_INTERNAL_CDC {true} \
   CONFIG.TX_OR_RXN_PATH {0} \
 ] $i_data_offload

  # Create instance: storage_unit, and set properties
  set storage_unit [ create_bd_cell -type ip -vlnv analog.com:user:util_do_ram:1.0 storage_unit ]
  set_property -dict [ list \
   CONFIG.DST_DATA_WIDTH {512} \
   CONFIG.LENGTH_WIDTH {18} \
   CONFIG.SRC_DATA_WIDTH {512} \
 ] $storage_unit

  # Create interface connections
  connect_bd_intf_net -intf_net i_data_offload_m_axis [get_bd_intf_pins m_axis] [get_bd_intf_pins i_data_offload/m_axis]
  connect_bd_intf_net -intf_net i_data_offload_m_storage_axis [get_bd_intf_pins i_data_offload/m_storage_axis] [get_bd_intf_pins storage_unit/s_axis]
  connect_bd_intf_net -intf_net i_data_offload_rd_ctrl [get_bd_intf_pins i_data_offload/rd_ctrl] [get_bd_intf_pins storage_unit/rd_ctrl]
  connect_bd_intf_net -intf_net i_data_offload_wr_ctrl [get_bd_intf_pins i_data_offload/wr_ctrl] [get_bd_intf_pins storage_unit/wr_ctrl]
  connect_bd_intf_net -intf_net s_axi_1 [get_bd_intf_pins s_axi] [get_bd_intf_pins i_data_offload/s_axi]
  connect_bd_intf_net -intf_net s_axis_1 [get_bd_intf_pins s_axis] [get_bd_intf_pins i_data_offload/s_axis]
  connect_bd_intf_net -intf_net storage_unit_m_axis [get_bd_intf_pins i_data_offload/s_storage_axis] [get_bd_intf_pins storage_unit/m_axis]

  # Create port connections
  connect_bd_net -net init_req_1 [get_bd_pins init_req] [get_bd_pins i_data_offload/init_req]
  connect_bd_net -net m_axis_aclk_1 [get_bd_pins m_axis_aclk] [get_bd_pins i_data_offload/m_axis_aclk] [get_bd_pins storage_unit/m_axis_aclk]
  connect_bd_net -net m_axis_aresetn_1 [get_bd_pins m_axis_aresetn] [get_bd_pins i_data_offload/m_axis_aresetn] [get_bd_pins storage_unit/m_axis_aresetn]
  connect_bd_net -net s_axi_aclk_1 [get_bd_pins s_axi_aclk] [get_bd_pins i_data_offload/s_axi_aclk]
  connect_bd_net -net s_axi_aresetn_1 [get_bd_pins s_axi_aresetn] [get_bd_pins i_data_offload/s_axi_aresetn]
  connect_bd_net -net s_axis_aclk_1 [get_bd_pins s_axis_aclk] [get_bd_pins i_data_offload/s_axis_aclk] [get_bd_pins storage_unit/s_axis_aclk]
  connect_bd_net -net s_axis_aresetn_1 [get_bd_pins s_axis_aresetn] [get_bd_pins i_data_offload/s_axis_aresetn] [get_bd_pins storage_unit/s_axis_aresetn]
  connect_bd_net -net sync_ext_1 [get_bd_pins sync_ext] [get_bd_pins i_data_offload/sync_ext]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: axi_mxfe_tx_jesd
proc create_hier_cell_axi_mxfe_tx_jesd { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_axi_mxfe_tx_jesd() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 tx_data

  create_bd_intf_pin -mode Master -vlnv xilinx.com:display_jesd204:jesd204_tx_bus_rtl:1.0 tx_phy0

  create_bd_intf_pin -mode Master -vlnv xilinx.com:display_jesd204:jesd204_tx_bus_rtl:1.0 tx_phy1

  create_bd_intf_pin -mode Master -vlnv xilinx.com:display_jesd204:jesd204_tx_bus_rtl:1.0 tx_phy2

  create_bd_intf_pin -mode Master -vlnv xilinx.com:display_jesd204:jesd204_tx_bus_rtl:1.0 tx_phy3

  create_bd_intf_pin -mode Master -vlnv xilinx.com:display_jesd204:jesd204_tx_bus_rtl:1.0 tx_phy4

  create_bd_intf_pin -mode Master -vlnv xilinx.com:display_jesd204:jesd204_tx_bus_rtl:1.0 tx_phy5

  create_bd_intf_pin -mode Master -vlnv xilinx.com:display_jesd204:jesd204_tx_bus_rtl:1.0 tx_phy6

  create_bd_intf_pin -mode Master -vlnv xilinx.com:display_jesd204:jesd204_tx_bus_rtl:1.0 tx_phy7


  # Create pins
  create_bd_pin -dir I -type clk device_clk
  create_bd_pin -dir O -type intr irq
  create_bd_pin -dir I -type clk link_clk
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type rst s_axi_aresetn
  create_bd_pin -dir I sysref

  # Create instance: tx, and set properties
  set tx [ create_bd_cell -type ip -vlnv analog.com:user:jesd204_tx:1.0 tx ]
  set_property -dict [ list \
   CONFIG.LINK_MODE {2} \
   CONFIG.NUM_LANES {8} \
   CONFIG.NUM_LINKS {1} \
   CONFIG.SYSREF_IOB {false} \
   CONFIG.TPL_DATA_PATH_WIDTH {8} \
 ] $tx

  # Create instance: tx_axi, and set properties
  set tx_axi [ create_bd_cell -type ip -vlnv analog.com:user:axi_jesd204_tx:1.0 tx_axi ]
  set_property -dict [ list \
   CONFIG.DATA_PATH_WIDTH {8} \
   CONFIG.LINK_MODE {2} \
   CONFIG.NUM_LANES {8} \
   CONFIG.NUM_LINKS {1} \
 ] $tx_axi

  # Create interface connections
  connect_bd_intf_net -intf_net s_axi_1 [get_bd_intf_pins s_axi] [get_bd_intf_pins tx_axi/s_axi]
  connect_bd_intf_net -intf_net tx_axi_tx_cfg [get_bd_intf_pins tx/tx_cfg] [get_bd_intf_pins tx_axi/tx_cfg]
  connect_bd_intf_net -intf_net tx_data_1 [get_bd_intf_pins tx_data] [get_bd_intf_pins tx/tx_data]
  connect_bd_intf_net -intf_net tx_tx_event [get_bd_intf_pins tx/tx_event] [get_bd_intf_pins tx_axi/tx_event]
  connect_bd_intf_net -intf_net tx_tx_phy0 [get_bd_intf_pins tx_phy0] [get_bd_intf_pins tx/tx_phy0]
  connect_bd_intf_net -intf_net tx_tx_phy1 [get_bd_intf_pins tx_phy1] [get_bd_intf_pins tx/tx_phy1]
  connect_bd_intf_net -intf_net tx_tx_phy2 [get_bd_intf_pins tx_phy2] [get_bd_intf_pins tx/tx_phy2]
  connect_bd_intf_net -intf_net tx_tx_phy3 [get_bd_intf_pins tx_phy3] [get_bd_intf_pins tx/tx_phy3]
  connect_bd_intf_net -intf_net tx_tx_phy4 [get_bd_intf_pins tx_phy4] [get_bd_intf_pins tx/tx_phy4]
  connect_bd_intf_net -intf_net tx_tx_phy5 [get_bd_intf_pins tx_phy5] [get_bd_intf_pins tx/tx_phy5]
  connect_bd_intf_net -intf_net tx_tx_phy6 [get_bd_intf_pins tx_phy6] [get_bd_intf_pins tx/tx_phy6]
  connect_bd_intf_net -intf_net tx_tx_phy7 [get_bd_intf_pins tx_phy7] [get_bd_intf_pins tx/tx_phy7]
  connect_bd_intf_net -intf_net tx_tx_status [get_bd_intf_pins tx/tx_status] [get_bd_intf_pins tx_axi/tx_status]

  # Create port connections
  connect_bd_net -net device_clk_1 [get_bd_pins device_clk] [get_bd_pins tx/device_clk] [get_bd_pins tx_axi/device_clk]
  connect_bd_net -net link_clk_1 [get_bd_pins link_clk] [get_bd_pins tx/clk] [get_bd_pins tx_axi/core_clk]
  connect_bd_net -net s_axi_aclk_1 [get_bd_pins s_axi_aclk] [get_bd_pins tx_axi/s_axi_aclk]
  connect_bd_net -net s_axi_aresetn_1 [get_bd_pins s_axi_aresetn] [get_bd_pins tx_axi/s_axi_aresetn]
  connect_bd_net -net sysref_1 [get_bd_pins sysref] [get_bd_pins tx/sysref]
  connect_bd_net -net tx_axi_core_reset [get_bd_pins tx/reset] [get_bd_pins tx_axi/core_reset]
  connect_bd_net -net tx_axi_device_reset [get_bd_pins tx/device_reset] [get_bd_pins tx_axi/device_reset]
  connect_bd_net -net tx_axi_irq [get_bd_pins irq] [get_bd_pins tx_axi/irq]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: axi_mxfe_rx_jesd
proc create_hier_cell_axi_mxfe_rx_jesd { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_axi_mxfe_rx_jesd() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:display_jesd204:jesd204_rx_bus_rtl:1.0 rx_phy0

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:display_jesd204:jesd204_rx_bus_rtl:1.0 rx_phy1

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:display_jesd204:jesd204_rx_bus_rtl:1.0 rx_phy2

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:display_jesd204:jesd204_rx_bus_rtl:1.0 rx_phy3

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:display_jesd204:jesd204_rx_bus_rtl:1.0 rx_phy4

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:display_jesd204:jesd204_rx_bus_rtl:1.0 rx_phy5

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:display_jesd204:jesd204_rx_bus_rtl:1.0 rx_phy6

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:display_jesd204:jesd204_rx_bus_rtl:1.0 rx_phy7

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi


  # Create pins
  create_bd_pin -dir O -type rst core_reset
  create_bd_pin -dir I -type clk device_clk
  create_bd_pin -dir O device_reset
  create_bd_pin -dir O -type intr irq
  create_bd_pin -dir I -type clk link_clk
  create_bd_pin -dir O -from 511 -to 0 rx_data_tdata
  create_bd_pin -dir O rx_data_tvalid
  create_bd_pin -dir O -from 7 -to 0 rx_eof
  create_bd_pin -dir O -from 7 -to 0 rx_sof
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type rst s_axi_aresetn
  create_bd_pin -dir I sysref

  # Create instance: rx, and set properties
  set rx [ create_bd_cell -type ip -vlnv analog.com:user:jesd204_rx:1.0 rx ]
  set_property -dict [ list \
   CONFIG.LINK_MODE {2} \
   CONFIG.NUM_INPUT_PIPELINE {1} \
   CONFIG.NUM_LANES {8} \
   CONFIG.NUM_LINKS {1} \
   CONFIG.SYSREF_IOB {false} \
   CONFIG.TPL_DATA_PATH_WIDTH {8} \
 ] $rx

  # Create instance: rx_axi, and set properties
  set rx_axi [ create_bd_cell -type ip -vlnv analog.com:user:axi_jesd204_rx:1.0 rx_axi ]
  set_property -dict [ list \
   CONFIG.DATA_PATH_WIDTH {8} \
   CONFIG.LINK_MODE {2} \
   CONFIG.NUM_LANES {8} \
   CONFIG.NUM_LINKS {1} \
 ] $rx_axi

  # Create interface connections
  connect_bd_intf_net -intf_net rx_axi_rx_cfg [get_bd_intf_pins rx/rx_cfg] [get_bd_intf_pins rx_axi/rx_cfg]
  connect_bd_intf_net -intf_net rx_phy0_1 [get_bd_intf_pins rx_phy0] [get_bd_intf_pins rx/rx_phy0]
  connect_bd_intf_net -intf_net rx_phy1_1 [get_bd_intf_pins rx_phy1] [get_bd_intf_pins rx/rx_phy1]
  connect_bd_intf_net -intf_net rx_phy2_1 [get_bd_intf_pins rx_phy2] [get_bd_intf_pins rx/rx_phy2]
  connect_bd_intf_net -intf_net rx_phy3_1 [get_bd_intf_pins rx_phy3] [get_bd_intf_pins rx/rx_phy3]
  connect_bd_intf_net -intf_net rx_phy4_1 [get_bd_intf_pins rx_phy4] [get_bd_intf_pins rx/rx_phy4]
  connect_bd_intf_net -intf_net rx_phy5_1 [get_bd_intf_pins rx_phy5] [get_bd_intf_pins rx/rx_phy5]
  connect_bd_intf_net -intf_net rx_phy6_1 [get_bd_intf_pins rx_phy6] [get_bd_intf_pins rx/rx_phy6]
  connect_bd_intf_net -intf_net rx_phy7_1 [get_bd_intf_pins rx_phy7] [get_bd_intf_pins rx/rx_phy7]
  connect_bd_intf_net -intf_net rx_rx_event [get_bd_intf_pins rx/rx_event] [get_bd_intf_pins rx_axi/rx_event]
  connect_bd_intf_net -intf_net rx_rx_status [get_bd_intf_pins rx/rx_status] [get_bd_intf_pins rx_axi/rx_status]
  connect_bd_intf_net -intf_net s_axi_1 [get_bd_intf_pins s_axi] [get_bd_intf_pins rx_axi/s_axi]

  # Create port connections
  connect_bd_net -net device_clk_1 [get_bd_pins device_clk] [get_bd_pins rx/device_clk] [get_bd_pins rx_axi/device_clk]
  connect_bd_net -net link_clk_1 [get_bd_pins link_clk] [get_bd_pins rx/clk] [get_bd_pins rx_axi/core_clk]
  connect_bd_net -net rx_axi_core_reset [get_bd_pins core_reset] [get_bd_pins rx/reset] [get_bd_pins rx_axi/core_reset]
  connect_bd_net -net rx_axi_device_reset [get_bd_pins device_reset] [get_bd_pins rx/device_reset] [get_bd_pins rx_axi/device_reset]
  connect_bd_net -net rx_axi_irq [get_bd_pins irq] [get_bd_pins rx_axi/irq]
  connect_bd_net -net rx_rx_data [get_bd_pins rx_data_tdata] [get_bd_pins rx/rx_data]
  connect_bd_net -net rx_rx_eof [get_bd_pins rx_eof] [get_bd_pins rx/rx_eof]
  connect_bd_net -net rx_rx_sof [get_bd_pins rx_sof] [get_bd_pins rx/rx_sof]
  connect_bd_net -net rx_rx_valid [get_bd_pins rx_data_tvalid] [get_bd_pins rx/rx_valid]
  connect_bd_net -net s_axi_aclk_1 [get_bd_pins s_axi_aclk] [get_bd_pins rx_axi/s_axi_aclk]
  connect_bd_net -net s_axi_aresetn_1 [get_bd_pins s_axi_aresetn] [get_bd_pins rx_axi/s_axi_aresetn]
  connect_bd_net -net sysref_1 [get_bd_pins sysref] [get_bd_pins rx/sysref]

  # Restore current instance
  current_bd_instance $oldCurInst
}


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
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports

  # Create ports
  set ACK_I [ create_bd_port -dir I ACK_I ]
  set ADR_O [ create_bd_port -dir O -from 31 -to 0 ADR_O ]
  set CYC_O [ create_bd_port -dir O CYC_O ]
  set DAT_I [ create_bd_port -dir I -from 31 -to 0 DAT_I ]
  set DAT_O [ create_bd_port -dir O -from 31 -to 0 DAT_O ]
  set RST_O [ create_bd_port -dir O RST_O ]
  set SEL_O [ create_bd_port -dir O -from 3 -to 0 SEL_O ]
  set STB_O [ create_bd_port -dir O STB_O ]
  set WE_O [ create_bd_port -dir O WE_O ]
  set axi_aclk [ create_bd_port -dir O -type clk axi_aclk ]
  set axi_aclk90 [ create_bd_port -dir O -type clk axi_aclk90 ]
  set axi_aclk180 [ create_bd_port -dir O -type clk axi_aclk180 ]
  set axi_aclk270 [ create_bd_port -dir O -type clk axi_aclk270 ]
  set clk300mhz [ create_bd_port -dir O -type clk clk300mhz ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {300000000} \
 ] $clk300mhz
  set ext_sync_in [ create_bd_port -dir I ext_sync_in ]
  set gpio_i [ create_bd_port -dir I -from 94 -to 0 gpio_i ]
  set gpio_o [ create_bd_port -dir O -from 94 -to 0 gpio_o ]
  set gpio_t [ create_bd_port -dir O -from 94 -to 0 gpio_t ]
  set link_clk_out [ create_bd_port -dir O link_clk_out ]
  set ref_clk_q0 [ create_bd_port -dir I ref_clk_q0 ]
  set ref_clk_q1 [ create_bd_port -dir I ref_clk_q1 ]
  set rx_data_0_n [ create_bd_port -dir I rx_data_0_n ]
  set rx_data_0_p [ create_bd_port -dir I rx_data_0_p ]
  set rx_data_1_n [ create_bd_port -dir I rx_data_1_n ]
  set rx_data_1_p [ create_bd_port -dir I rx_data_1_p ]
  set rx_data_2_n [ create_bd_port -dir I rx_data_2_n ]
  set rx_data_2_p [ create_bd_port -dir I rx_data_2_p ]
  set rx_data_3_n [ create_bd_port -dir I rx_data_3_n ]
  set rx_data_3_p [ create_bd_port -dir I rx_data_3_p ]
  set rx_data_4_n [ create_bd_port -dir I rx_data_4_n ]
  set rx_data_4_p [ create_bd_port -dir I rx_data_4_p ]
  set rx_data_5_n [ create_bd_port -dir I rx_data_5_n ]
  set rx_data_5_p [ create_bd_port -dir I rx_data_5_p ]
  set rx_data_6_n [ create_bd_port -dir I rx_data_6_n ]
  set rx_data_6_p [ create_bd_port -dir I rx_data_6_p ]
  set rx_data_7_n [ create_bd_port -dir I rx_data_7_n ]
  set rx_data_7_p [ create_bd_port -dir I rx_data_7_p ]
  set rx_device_clk [ create_bd_port -dir I rx_device_clk ]
  set rx_sync_0 [ create_bd_port -dir O -from 0 -to 0 rx_sync_0 ]
  set rx_sysref_0 [ create_bd_port -dir I rx_sysref_0 ]
  set spi0_csn [ create_bd_port -dir O -from 2 -to 0 spi0_csn ]
  set spi0_miso [ create_bd_port -dir I spi0_miso ]
  set spi0_mosi [ create_bd_port -dir O spi0_mosi ]
  set spi0_sclk [ create_bd_port -dir O spi0_sclk ]
  set spi1_csn [ create_bd_port -dir O -from 2 -to 0 spi1_csn ]
  set spi1_miso [ create_bd_port -dir I spi1_miso ]
  set spi1_mosi [ create_bd_port -dir O spi1_mosi ]
  set spi1_sclk [ create_bd_port -dir O spi1_sclk ]
  set tx_data_0_n [ create_bd_port -dir O tx_data_0_n ]
  set tx_data_0_p [ create_bd_port -dir O tx_data_0_p ]
  set tx_data_1_n [ create_bd_port -dir O tx_data_1_n ]
  set tx_data_1_p [ create_bd_port -dir O tx_data_1_p ]
  set tx_data_2_n [ create_bd_port -dir O tx_data_2_n ]
  set tx_data_2_p [ create_bd_port -dir O tx_data_2_p ]
  set tx_data_3_n [ create_bd_port -dir O tx_data_3_n ]
  set tx_data_3_p [ create_bd_port -dir O tx_data_3_p ]
  set tx_data_4_n [ create_bd_port -dir O tx_data_4_n ]
  set tx_data_4_p [ create_bd_port -dir O tx_data_4_p ]
  set tx_data_5_n [ create_bd_port -dir O tx_data_5_n ]
  set tx_data_5_p [ create_bd_port -dir O tx_data_5_p ]
  set tx_data_6_n [ create_bd_port -dir O tx_data_6_n ]
  set tx_data_6_p [ create_bd_port -dir O tx_data_6_p ]
  set tx_data_7_n [ create_bd_port -dir O tx_data_7_n ]
  set tx_data_7_p [ create_bd_port -dir O tx_data_7_p ]
  set tx_device_clk [ create_bd_port -dir I tx_device_clk ]
  set tx_sync_0 [ create_bd_port -dir I -from 0 -to 0 tx_sync_0 ]
  set tx_sysref_0 [ create_bd_port -dir I tx_sysref_0 ]

  # Create instance: GND_1, and set properties
  set GND_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 GND_1 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {1} \
 ] $GND_1

  # Create instance: VCC_1, and set properties
  set VCC_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 VCC_1 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {1} \
   CONFIG.CONST_WIDTH {1} \
 ] $VCC_1

  # Create instance: axi_cpu_interconnect, and set properties
  set axi_cpu_interconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_cpu_interconnect ]
  set_property -dict [ list \
   CONFIG.NUM_MI {12} \
   CONFIG.NUM_SI {1} \
 ] $axi_cpu_interconnect

  # Create instance: axi_hp0_interconnect, and set properties
  set axi_hp0_interconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_hp0_interconnect ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
   CONFIG.NUM_SI {1} \
 ] $axi_hp0_interconnect

  # Create instance: axi_hp1_interconnect, and set properties
  set axi_hp1_interconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_hp1_interconnect ]
  set_property -dict [ list \
   CONFIG.NUM_CLKS {2} \
   CONFIG.NUM_MI {1} \
   CONFIG.NUM_SI {1} \
 ] $axi_hp1_interconnect

  # Create instance: axi_hp2_interconnect, and set properties
  set axi_hp2_interconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_hp2_interconnect ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
   CONFIG.NUM_SI {1} \
 ] $axi_hp2_interconnect

  # Create instance: axi_mxfe_rx_dma, and set properties
  set axi_mxfe_rx_dma [ create_bd_cell -type ip -vlnv analog.com:user:axi_dmac:1.0 axi_mxfe_rx_dma ]
  set_property -dict [ list \
   CONFIG.AXI_SLICE_DEST {true} \
   CONFIG.AXI_SLICE_SRC {true} \
   CONFIG.CYCLIC {false} \
   CONFIG.DMA_2D_TRANSFER {false} \
   CONFIG.DMA_DATA_WIDTH_DEST {512} \
   CONFIG.DMA_DATA_WIDTH_SRC {512} \
   CONFIG.DMA_LENGTH_WIDTH {24} \
   CONFIG.DMA_TYPE_DEST {0} \
   CONFIG.DMA_TYPE_SRC {1} \
   CONFIG.ID {0} \
   CONFIG.MAX_BYTES_PER_BURST {4096} \
   CONFIG.SYNC_TRANSFER_START {false} \
 ] $axi_mxfe_rx_dma

  # Create instance: axi_mxfe_rx_jesd
  create_hier_cell_axi_mxfe_rx_jesd [current_bd_instance .] axi_mxfe_rx_jesd

  # Create instance: axi_mxfe_rx_xcvr, and set properties
  set axi_mxfe_rx_xcvr [ create_bd_cell -type ip -vlnv analog.com:user:axi_adxcvr:1.0 axi_mxfe_rx_xcvr ]
  set_property -dict [ list \
   CONFIG.ID {0} \
   CONFIG.LINK_MODE {2} \
   CONFIG.LPM_OR_DFE_N {1} \
   CONFIG.NUM_OF_LANES {8} \
   CONFIG.OUT_CLK_SEL {"011"} \
   CONFIG.QPLL_ENABLE {1} \
   CONFIG.RATE {"000"} \
   CONFIG.SYS_CLK_SEL {0x2} \
   CONFIG.TX_OR_RX_N {0} \
 ] $axi_mxfe_rx_xcvr

  # Create instance: axi_mxfe_tx_dma, and set properties
  set axi_mxfe_tx_dma [ create_bd_cell -type ip -vlnv analog.com:user:axi_dmac:1.0 axi_mxfe_tx_dma ]
  set_property -dict [ list \
   CONFIG.AXI_SLICE_DEST {true} \
   CONFIG.AXI_SLICE_SRC {true} \
   CONFIG.CYCLIC {true} \
   CONFIG.DMA_2D_TRANSFER {false} \
   CONFIG.DMA_DATA_WIDTH_DEST {512} \
   CONFIG.DMA_DATA_WIDTH_SRC {512} \
   CONFIG.DMA_LENGTH_WIDTH {24} \
   CONFIG.DMA_TYPE_DEST {1} \
   CONFIG.DMA_TYPE_SRC {0} \
   CONFIG.ID {0} \
   CONFIG.MAX_BYTES_PER_BURST {4096} \
 ] $axi_mxfe_tx_dma

  # Create instance: axi_mxfe_tx_jesd
  create_hier_cell_axi_mxfe_tx_jesd [current_bd_instance .] axi_mxfe_tx_jesd

  # Create instance: axi_mxfe_tx_xcvr, and set properties
  set axi_mxfe_tx_xcvr [ create_bd_cell -type ip -vlnv analog.com:user:axi_adxcvr:1.0 axi_mxfe_tx_xcvr ]
  set_property -dict [ list \
   CONFIG.ID {0} \
   CONFIG.LINK_MODE {2} \
   CONFIG.NUM_OF_LANES {8} \
   CONFIG.OUT_CLK_SEL {"011"} \
   CONFIG.QPLL_ENABLE {0} \
   CONFIG.RATE {"000"} \
   CONFIG.SYS_CLK_SEL {0x2} \
   CONFIG.TX_DIFFCTRL {0x0C} \
   CONFIG.TX_OR_RX_N {1} \
 ] $axi_mxfe_tx_xcvr

  # Create instance: axi_slave_wishbone_c_0, and set properties
  set axi_slave_wishbone_c_0 [ create_bd_cell -type ip -vlnv peralex.com:user:axi_slave_wishbone_classic_master:1.0 axi_slave_wishbone_c_0 ]
  set_property -dict [ list \
   CONFIG.C_S_AXI_ADDR_WIDTH {32} \
 ] $axi_slave_wishbone_c_0

  # Create instance: axi_sysid_0, and set properties
  set axi_sysid_0 [ create_bd_cell -type ip -vlnv analog.com:user:axi_sysid:1.0 axi_sysid_0 ]
  set_property -dict [ list \
   CONFIG.ROM_ADDR_BITS {9} \
 ] $axi_sysid_0

  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0 ]
  set_property -dict [ list \
   CONFIG.CLKOUT1_DRIVES {BUFGCE} \
   CONFIG.CLKOUT2_DRIVES {BUFGCE} \
   CONFIG.CLKOUT2_JITTER {115.831} \
   CONFIG.CLKOUT2_PHASE_ERROR {87.180} \
   CONFIG.CLKOUT2_REQUESTED_PHASE {90} \
   CONFIG.CLKOUT2_USED {true} \
   CONFIG.CLKOUT3_DRIVES {BUFGCE} \
   CONFIG.CLKOUT3_JITTER {115.831} \
   CONFIG.CLKOUT3_PHASE_ERROR {87.180} \
   CONFIG.CLKOUT3_REQUESTED_PHASE {180} \
   CONFIG.CLKOUT3_USED {true} \
   CONFIG.CLKOUT4_DRIVES {BUFGCE} \
   CONFIG.CLKOUT4_JITTER {115.831} \
   CONFIG.CLKOUT4_PHASE_ERROR {87.180} \
   CONFIG.CLKOUT4_REQUESTED_PHASE {270} \
   CONFIG.CLKOUT4_USED {true} \
   CONFIG.CLKOUT5_DRIVES {BUFGCE} \
   CONFIG.CLKOUT5_JITTER {94.862} \
   CONFIG.CLKOUT5_PHASE_ERROR {87.180} \
   CONFIG.CLKOUT5_REQUESTED_OUT_FREQ {300} \
   CONFIG.CLKOUT5_USED {true} \
   CONFIG.CLKOUT6_DRIVES {BUFGCE} \
   CONFIG.CLKOUT7_DRIVES {BUFGCE} \
   CONFIG.CLK_OUT1_PORT {clkout0} \
   CONFIG.CLK_OUT2_PORT {clkout90} \
   CONFIG.CLK_OUT3_PORT {clkout180} \
   CONFIG.CLK_OUT4_PORT {clkout270} \
   CONFIG.CLK_OUT5_PORT {clk300mhz} \
   CONFIG.FEEDBACK_SOURCE {FDBK_AUTO} \
   CONFIG.MMCM_CLKOUT1_DIVIDE {12} \
   CONFIG.MMCM_CLKOUT1_PHASE {90.000} \
   CONFIG.MMCM_CLKOUT2_DIVIDE {12} \
   CONFIG.MMCM_CLKOUT2_PHASE {180.000} \
   CONFIG.MMCM_CLKOUT3_DIVIDE {12} \
   CONFIG.MMCM_CLKOUT3_PHASE {270.000} \
   CONFIG.MMCM_CLKOUT4_DIVIDE {4} \
   CONFIG.NUM_OUT_CLKS {5} \
   CONFIG.OPTIMIZE_CLOCKING_STRUCTURE_EN {true} \
   CONFIG.SECONDARY_SOURCE {Single_ended_clock_capable_pin} \
   CONFIG.USE_PHASE_ALIGNMENT {true} \
   CONFIG.USE_RESET {false} \
   CONFIG.USE_SAFE_CLOCK_STARTUP {true} \
 ] $clk_wiz_0

  # Create instance: cpack_reset_sources, and set properties
  set cpack_reset_sources [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 cpack_reset_sources ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {3} \
 ] $cpack_reset_sources

  # Create instance: cpack_rst_logic, and set properties
  set cpack_rst_logic [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_reduced_logic:2.0 cpack_rst_logic ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {or} \
   CONFIG.C_SIZE {3} \
 ] $cpack_rst_logic

  # Create instance: manual_sync_or, and set properties
  set manual_sync_or [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 manual_sync_or ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {or} \
   CONFIG.C_SIZE {1} \
 ] $manual_sync_or

  # Create instance: mxfe_rx_data_offload
  create_hier_cell_mxfe_rx_data_offload [current_bd_instance .] mxfe_rx_data_offload

  # Create instance: mxfe_tx_data_offload
  create_hier_cell_mxfe_tx_data_offload [current_bd_instance .] mxfe_tx_data_offload

  # Create instance: rom_sys_0, and set properties
  set rom_sys_0 [ create_bd_cell -type ip -vlnv analog.com:user:sysid_rom:1.0 rom_sys_0 ]
  set_property -dict [ list \
   CONFIG.PATH_TO_FILE {/home/jackh/src/adi/hdl/projects/ad9082_fmca_ebz/iwave_zu11_m2d1_i_4500/mem_init_sys.txt} \
   CONFIG.ROM_ADDR_BITS {9} \
 ] $rom_sys_0

  # Create instance: rx_device_clk_rstgen, and set properties
  set rx_device_clk_rstgen [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rx_device_clk_rstgen ]

  # Create instance: rx_do_rstout_logic, and set properties
  set rx_do_rstout_logic [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 rx_do_rstout_logic ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
 ] $rx_do_rstout_logic

  # Create instance: rx_mxfe_tpl_core
  create_hier_cell_rx_mxfe_tpl_core [current_bd_instance .] rx_mxfe_tpl_core

  # Create instance: spi0_csn_concat, and set properties
  set spi0_csn_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 spi0_csn_concat ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {3} \
 ] $spi0_csn_concat

  # Create instance: spi1_csn_concat, and set properties
  set spi1_csn_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 spi1_csn_concat ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {3} \
 ] $spi1_csn_concat

  # Create instance: sys_250m_rstgen, and set properties
  set sys_250m_rstgen [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 sys_250m_rstgen ]
  set_property -dict [ list \
   CONFIG.C_EXT_RST_WIDTH {1} \
 ] $sys_250m_rstgen

  # Create instance: sys_concat_intc_0, and set properties
  set sys_concat_intc_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 sys_concat_intc_0 ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {8} \
 ] $sys_concat_intc_0

  # Create instance: sys_concat_intc_1, and set properties
  set sys_concat_intc_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 sys_concat_intc_1 ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {8} \
 ] $sys_concat_intc_1

  # Create instance: sys_ps8, and set properties
  set sys_ps8 [ create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.3 sys_ps8 ]
  set_property -dict [ list \
   CONFIG.CAN0_BOARD_INTERFACE {custom} \
   CONFIG.CAN1_BOARD_INTERFACE {custom} \
   CONFIG.CSU_BOARD_INTERFACE {custom} \
   CONFIG.DP_BOARD_INTERFACE {custom} \
   CONFIG.GEM0_BOARD_INTERFACE {custom} \
   CONFIG.GEM1_BOARD_INTERFACE {custom} \
   CONFIG.GEM2_BOARD_INTERFACE {custom} \
   CONFIG.GEM3_BOARD_INTERFACE {custom} \
   CONFIG.GPIO_BOARD_INTERFACE {custom} \
   CONFIG.IIC0_BOARD_INTERFACE {custom} \
   CONFIG.IIC1_BOARD_INTERFACE {custom} \
   CONFIG.NAND_BOARD_INTERFACE {custom} \
   CONFIG.PCIE_BOARD_INTERFACE {custom} \
   CONFIG.PJTAG_BOARD_INTERFACE {custom} \
   CONFIG.PMU_BOARD_INTERFACE {custom} \
   CONFIG.PSU_BANK_0_IO_STANDARD {LVCMOS18} \
   CONFIG.PSU_BANK_1_IO_STANDARD {LVCMOS18} \
   CONFIG.PSU_BANK_2_IO_STANDARD {LVCMOS18} \
   CONFIG.PSU_BANK_3_IO_STANDARD {LVCMOS18} \
   CONFIG.PSU_DDR_RAM_HIGHADDR {0xFFFFFFFF} \
   CONFIG.PSU_DDR_RAM_HIGHADDR_OFFSET {0x800000000} \
   CONFIG.PSU_DDR_RAM_LOWADDR_OFFSET {0x80000000} \
   CONFIG.PSU_DYNAMIC_DDR_CONFIG_EN {0} \
   CONFIG.PSU_IMPORT_BOARD_PRESET {} \
   CONFIG.PSU_MIO_0_DIRECTION {inout} \
   CONFIG.PSU_MIO_0_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_0_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_0_POLARITY {Default} \
   CONFIG.PSU_MIO_0_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_0_SLEW {fast} \
   CONFIG.PSU_MIO_10_DIRECTION {inout} \
   CONFIG.PSU_MIO_10_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_10_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_10_POLARITY {Default} \
   CONFIG.PSU_MIO_10_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_10_SLEW {fast} \
   CONFIG.PSU_MIO_11_DIRECTION {inout} \
   CONFIG.PSU_MIO_11_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_11_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_11_POLARITY {Default} \
   CONFIG.PSU_MIO_11_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_11_SLEW {fast} \
   CONFIG.PSU_MIO_12_DIRECTION {inout} \
   CONFIG.PSU_MIO_12_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_12_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_12_POLARITY {Default} \
   CONFIG.PSU_MIO_12_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_12_SLEW {fast} \
   CONFIG.PSU_MIO_13_DIRECTION {inout} \
   CONFIG.PSU_MIO_13_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_13_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_13_POLARITY {Default} \
   CONFIG.PSU_MIO_13_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_13_SLEW {slow} \
   CONFIG.PSU_MIO_14_DIRECTION {inout} \
   CONFIG.PSU_MIO_14_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_14_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_14_POLARITY {Default} \
   CONFIG.PSU_MIO_14_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_14_SLEW {slow} \
   CONFIG.PSU_MIO_15_DIRECTION {inout} \
   CONFIG.PSU_MIO_15_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_15_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_15_POLARITY {Default} \
   CONFIG.PSU_MIO_15_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_15_SLEW {slow} \
   CONFIG.PSU_MIO_16_DIRECTION {inout} \
   CONFIG.PSU_MIO_16_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_16_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_16_POLARITY {Default} \
   CONFIG.PSU_MIO_16_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_16_SLEW {slow} \
   CONFIG.PSU_MIO_17_DIRECTION {inout} \
   CONFIG.PSU_MIO_17_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_17_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_17_POLARITY {Default} \
   CONFIG.PSU_MIO_17_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_17_SLEW {slow} \
   CONFIG.PSU_MIO_18_DIRECTION {inout} \
   CONFIG.PSU_MIO_18_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_18_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_18_POLARITY {Default} \
   CONFIG.PSU_MIO_18_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_18_SLEW {slow} \
   CONFIG.PSU_MIO_19_DIRECTION {inout} \
   CONFIG.PSU_MIO_19_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_19_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_19_POLARITY {Default} \
   CONFIG.PSU_MIO_19_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_19_SLEW {slow} \
   CONFIG.PSU_MIO_1_DIRECTION {inout} \
   CONFIG.PSU_MIO_1_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_1_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_1_POLARITY {Default} \
   CONFIG.PSU_MIO_1_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_1_SLEW {fast} \
   CONFIG.PSU_MIO_20_DIRECTION {inout} \
   CONFIG.PSU_MIO_20_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_20_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_20_POLARITY {Default} \
   CONFIG.PSU_MIO_20_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_20_SLEW {slow} \
   CONFIG.PSU_MIO_21_DIRECTION {inout} \
   CONFIG.PSU_MIO_21_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_21_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_21_POLARITY {Default} \
   CONFIG.PSU_MIO_21_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_21_SLEW {slow} \
   CONFIG.PSU_MIO_22_DIRECTION {out} \
   CONFIG.PSU_MIO_22_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_22_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_22_POLARITY {Default} \
   CONFIG.PSU_MIO_22_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_22_SLEW {slow} \
   CONFIG.PSU_MIO_23_DIRECTION {out} \
   CONFIG.PSU_MIO_23_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_23_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_23_POLARITY {Default} \
   CONFIG.PSU_MIO_23_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_23_SLEW {slow} \
   CONFIG.PSU_MIO_24_DIRECTION {inout} \
   CONFIG.PSU_MIO_24_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_24_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_24_POLARITY {Default} \
   CONFIG.PSU_MIO_24_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_24_SLEW {fast} \
   CONFIG.PSU_MIO_25_DIRECTION {inout} \
   CONFIG.PSU_MIO_25_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_25_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_25_POLARITY {Default} \
   CONFIG.PSU_MIO_25_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_25_SLEW {fast} \
   CONFIG.PSU_MIO_26_DIRECTION {out} \
   CONFIG.PSU_MIO_26_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_26_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_26_POLARITY {Default} \
   CONFIG.PSU_MIO_26_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_26_SLEW {fast} \
   CONFIG.PSU_MIO_27_DIRECTION {out} \
   CONFIG.PSU_MIO_27_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_27_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_27_POLARITY {Default} \
   CONFIG.PSU_MIO_27_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_27_SLEW {fast} \
   CONFIG.PSU_MIO_28_DIRECTION {out} \
   CONFIG.PSU_MIO_28_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_28_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_28_POLARITY {Default} \
   CONFIG.PSU_MIO_28_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_28_SLEW {fast} \
   CONFIG.PSU_MIO_29_DIRECTION {out} \
   CONFIG.PSU_MIO_29_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_29_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_29_POLARITY {Default} \
   CONFIG.PSU_MIO_29_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_29_SLEW {fast} \
   CONFIG.PSU_MIO_2_DIRECTION {inout} \
   CONFIG.PSU_MIO_2_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_2_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_2_POLARITY {Default} \
   CONFIG.PSU_MIO_2_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_2_SLEW {fast} \
   CONFIG.PSU_MIO_30_DIRECTION {out} \
   CONFIG.PSU_MIO_30_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_30_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_30_POLARITY {Default} \
   CONFIG.PSU_MIO_30_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_30_SLEW {fast} \
   CONFIG.PSU_MIO_31_DIRECTION {out} \
   CONFIG.PSU_MIO_31_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_31_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_31_POLARITY {Default} \
   CONFIG.PSU_MIO_31_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_31_SLEW {fast} \
   CONFIG.PSU_MIO_32_DIRECTION {in} \
   CONFIG.PSU_MIO_32_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_32_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_32_POLARITY {Default} \
   CONFIG.PSU_MIO_32_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_32_SLEW {fast} \
   CONFIG.PSU_MIO_33_DIRECTION {in} \
   CONFIG.PSU_MIO_33_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_33_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_33_POLARITY {Default} \
   CONFIG.PSU_MIO_33_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_33_SLEW {fast} \
   CONFIG.PSU_MIO_34_DIRECTION {in} \
   CONFIG.PSU_MIO_34_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_34_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_34_POLARITY {Default} \
   CONFIG.PSU_MIO_34_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_34_SLEW {fast} \
   CONFIG.PSU_MIO_35_DIRECTION {in} \
   CONFIG.PSU_MIO_35_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_35_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_35_POLARITY {Default} \
   CONFIG.PSU_MIO_35_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_35_SLEW {fast} \
   CONFIG.PSU_MIO_36_DIRECTION {in} \
   CONFIG.PSU_MIO_36_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_36_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_36_POLARITY {Default} \
   CONFIG.PSU_MIO_36_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_36_SLEW {fast} \
   CONFIG.PSU_MIO_37_DIRECTION {in} \
   CONFIG.PSU_MIO_37_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_37_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_37_POLARITY {Default} \
   CONFIG.PSU_MIO_37_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_37_SLEW {fast} \
   CONFIG.PSU_MIO_38_DIRECTION {in} \
   CONFIG.PSU_MIO_38_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_38_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_38_POLARITY {Default} \
   CONFIG.PSU_MIO_38_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_38_SLEW {fast} \
   CONFIG.PSU_MIO_39_DIRECTION {out} \
   CONFIG.PSU_MIO_39_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_39_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_39_POLARITY {Default} \
   CONFIG.PSU_MIO_39_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_39_SLEW {fast} \
   CONFIG.PSU_MIO_3_DIRECTION {inout} \
   CONFIG.PSU_MIO_3_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_3_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_3_POLARITY {Default} \
   CONFIG.PSU_MIO_3_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_3_SLEW {fast} \
   CONFIG.PSU_MIO_40_DIRECTION {inout} \
   CONFIG.PSU_MIO_40_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_40_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_40_POLARITY {Default} \
   CONFIG.PSU_MIO_40_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_40_SLEW {fast} \
   CONFIG.PSU_MIO_41_DIRECTION {inout} \
   CONFIG.PSU_MIO_41_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_41_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_41_POLARITY {Default} \
   CONFIG.PSU_MIO_41_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_41_SLEW {fast} \
   CONFIG.PSU_MIO_42_DIRECTION {out} \
   CONFIG.PSU_MIO_42_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_42_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_42_POLARITY {Default} \
   CONFIG.PSU_MIO_42_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_42_SLEW {fast} \
   CONFIG.PSU_MIO_43_DIRECTION {inout} \
   CONFIG.PSU_MIO_43_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_43_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_43_POLARITY {Default} \
   CONFIG.PSU_MIO_43_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_43_SLEW {fast} \
   CONFIG.PSU_MIO_44_DIRECTION {in} \
   CONFIG.PSU_MIO_44_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_44_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_44_POLARITY {Default} \
   CONFIG.PSU_MIO_44_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_44_SLEW {fast} \
   CONFIG.PSU_MIO_45_DIRECTION {in} \
   CONFIG.PSU_MIO_45_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_45_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_45_POLARITY {Default} \
   CONFIG.PSU_MIO_45_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_45_SLEW {fast} \
   CONFIG.PSU_MIO_46_DIRECTION {inout} \
   CONFIG.PSU_MIO_46_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_46_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_46_POLARITY {Default} \
   CONFIG.PSU_MIO_46_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_46_SLEW {slow} \
   CONFIG.PSU_MIO_47_DIRECTION {inout} \
   CONFIG.PSU_MIO_47_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_47_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_47_POLARITY {Default} \
   CONFIG.PSU_MIO_47_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_47_SLEW {slow} \
   CONFIG.PSU_MIO_48_DIRECTION {inout} \
   CONFIG.PSU_MIO_48_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_48_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_48_POLARITY {Default} \
   CONFIG.PSU_MIO_48_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_48_SLEW {slow} \
   CONFIG.PSU_MIO_49_DIRECTION {inout} \
   CONFIG.PSU_MIO_49_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_49_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_49_POLARITY {Default} \
   CONFIG.PSU_MIO_49_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_49_SLEW {slow} \
   CONFIG.PSU_MIO_4_DIRECTION {inout} \
   CONFIG.PSU_MIO_4_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_4_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_4_POLARITY {Default} \
   CONFIG.PSU_MIO_4_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_4_SLEW {fast} \
   CONFIG.PSU_MIO_50_DIRECTION {inout} \
   CONFIG.PSU_MIO_50_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_50_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_50_POLARITY {Default} \
   CONFIG.PSU_MIO_50_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_50_SLEW {slow} \
   CONFIG.PSU_MIO_51_DIRECTION {out} \
   CONFIG.PSU_MIO_51_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_51_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_51_POLARITY {Default} \
   CONFIG.PSU_MIO_51_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_51_SLEW {slow} \
   CONFIG.PSU_MIO_52_DIRECTION {in} \
   CONFIG.PSU_MIO_52_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_52_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_52_POLARITY {Default} \
   CONFIG.PSU_MIO_52_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_52_SLEW {fast} \
   CONFIG.PSU_MIO_53_DIRECTION {in} \
   CONFIG.PSU_MIO_53_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_53_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_53_POLARITY {Default} \
   CONFIG.PSU_MIO_53_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_53_SLEW {fast} \
   CONFIG.PSU_MIO_54_DIRECTION {inout} \
   CONFIG.PSU_MIO_54_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_54_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_54_POLARITY {Default} \
   CONFIG.PSU_MIO_54_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_54_SLEW {fast} \
   CONFIG.PSU_MIO_55_DIRECTION {in} \
   CONFIG.PSU_MIO_55_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_55_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_55_POLARITY {Default} \
   CONFIG.PSU_MIO_55_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_55_SLEW {fast} \
   CONFIG.PSU_MIO_56_DIRECTION {inout} \
   CONFIG.PSU_MIO_56_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_56_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_56_POLARITY {Default} \
   CONFIG.PSU_MIO_56_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_56_SLEW {fast} \
   CONFIG.PSU_MIO_57_DIRECTION {inout} \
   CONFIG.PSU_MIO_57_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_57_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_57_POLARITY {Default} \
   CONFIG.PSU_MIO_57_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_57_SLEW {fast} \
   CONFIG.PSU_MIO_58_DIRECTION {out} \
   CONFIG.PSU_MIO_58_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_58_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_58_POLARITY {Default} \
   CONFIG.PSU_MIO_58_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_58_SLEW {fast} \
   CONFIG.PSU_MIO_59_DIRECTION {inout} \
   CONFIG.PSU_MIO_59_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_59_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_59_POLARITY {Default} \
   CONFIG.PSU_MIO_59_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_59_SLEW {fast} \
   CONFIG.PSU_MIO_5_DIRECTION {inout} \
   CONFIG.PSU_MIO_5_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_5_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_5_POLARITY {Default} \
   CONFIG.PSU_MIO_5_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_5_SLEW {fast} \
   CONFIG.PSU_MIO_60_DIRECTION {inout} \
   CONFIG.PSU_MIO_60_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_60_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_60_POLARITY {Default} \
   CONFIG.PSU_MIO_60_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_60_SLEW {fast} \
   CONFIG.PSU_MIO_61_DIRECTION {inout} \
   CONFIG.PSU_MIO_61_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_61_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_61_POLARITY {Default} \
   CONFIG.PSU_MIO_61_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_61_SLEW {fast} \
   CONFIG.PSU_MIO_62_DIRECTION {inout} \
   CONFIG.PSU_MIO_62_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_62_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_62_POLARITY {Default} \
   CONFIG.PSU_MIO_62_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_62_SLEW {fast} \
   CONFIG.PSU_MIO_63_DIRECTION {inout} \
   CONFIG.PSU_MIO_63_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_63_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_63_POLARITY {Default} \
   CONFIG.PSU_MIO_63_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_63_SLEW {fast} \
   CONFIG.PSU_MIO_64_DIRECTION {out} \
   CONFIG.PSU_MIO_64_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_64_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_64_POLARITY {Default} \
   CONFIG.PSU_MIO_64_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_64_SLEW {fast} \
   CONFIG.PSU_MIO_65_DIRECTION {out} \
   CONFIG.PSU_MIO_65_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_65_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_65_POLARITY {Default} \
   CONFIG.PSU_MIO_65_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_65_SLEW {fast} \
   CONFIG.PSU_MIO_66_DIRECTION {out} \
   CONFIG.PSU_MIO_66_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_66_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_66_POLARITY {Default} \
   CONFIG.PSU_MIO_66_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_66_SLEW {fast} \
   CONFIG.PSU_MIO_67_DIRECTION {out} \
   CONFIG.PSU_MIO_67_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_67_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_67_POLARITY {Default} \
   CONFIG.PSU_MIO_67_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_67_SLEW {fast} \
   CONFIG.PSU_MIO_68_DIRECTION {out} \
   CONFIG.PSU_MIO_68_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_68_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_68_POLARITY {Default} \
   CONFIG.PSU_MIO_68_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_68_SLEW {fast} \
   CONFIG.PSU_MIO_69_DIRECTION {out} \
   CONFIG.PSU_MIO_69_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_69_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_69_POLARITY {Default} \
   CONFIG.PSU_MIO_69_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_69_SLEW {fast} \
   CONFIG.PSU_MIO_6_DIRECTION {in} \
   CONFIG.PSU_MIO_6_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_6_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_6_POLARITY {Default} \
   CONFIG.PSU_MIO_6_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_6_SLEW {fast} \
   CONFIG.PSU_MIO_70_DIRECTION {in} \
   CONFIG.PSU_MIO_70_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_70_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_70_POLARITY {Default} \
   CONFIG.PSU_MIO_70_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_70_SLEW {fast} \
   CONFIG.PSU_MIO_71_DIRECTION {in} \
   CONFIG.PSU_MIO_71_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_71_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_71_POLARITY {Default} \
   CONFIG.PSU_MIO_71_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_71_SLEW {fast} \
   CONFIG.PSU_MIO_72_DIRECTION {in} \
   CONFIG.PSU_MIO_72_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_72_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_72_POLARITY {Default} \
   CONFIG.PSU_MIO_72_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_72_SLEW {fast} \
   CONFIG.PSU_MIO_73_DIRECTION {in} \
   CONFIG.PSU_MIO_73_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_73_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_73_POLARITY {Default} \
   CONFIG.PSU_MIO_73_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_73_SLEW {fast} \
   CONFIG.PSU_MIO_74_DIRECTION {in} \
   CONFIG.PSU_MIO_74_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_74_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_74_POLARITY {Default} \
   CONFIG.PSU_MIO_74_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_74_SLEW {fast} \
   CONFIG.PSU_MIO_75_DIRECTION {in} \
   CONFIG.PSU_MIO_75_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_75_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_75_POLARITY {Default} \
   CONFIG.PSU_MIO_75_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_75_SLEW {fast} \
   CONFIG.PSU_MIO_76_DIRECTION {out} \
   CONFIG.PSU_MIO_76_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_76_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_76_POLARITY {Default} \
   CONFIG.PSU_MIO_76_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_76_SLEW {fast} \
   CONFIG.PSU_MIO_77_DIRECTION {inout} \
   CONFIG.PSU_MIO_77_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_77_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_77_POLARITY {Default} \
   CONFIG.PSU_MIO_77_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_77_SLEW {fast} \
   CONFIG.PSU_MIO_7_DIRECTION {out} \
   CONFIG.PSU_MIO_7_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_7_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_7_POLARITY {Default} \
   CONFIG.PSU_MIO_7_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_7_SLEW {fast} \
   CONFIG.PSU_MIO_8_DIRECTION {out} \
   CONFIG.PSU_MIO_8_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_8_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_8_POLARITY {Default} \
   CONFIG.PSU_MIO_8_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_8_SLEW {fast} \
   CONFIG.PSU_MIO_9_DIRECTION {in} \
   CONFIG.PSU_MIO_9_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_9_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_9_POLARITY {Default} \
   CONFIG.PSU_MIO_9_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_9_SLEW {fast} \
   CONFIG.PSU_MIO_TREE_PERIPHERALS {\
GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#UART 0#UART 0#UART\
1#UART 1#I2C 0#I2C 0#GPIO0 MIO#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD\
0#SD 0#GPIO0 MIO#GPIO0 MIO#Gem 0#Gem 0#Gem 0#Gem 0#Gem 0#Gem 0#Gem 0#Gem 0#Gem\
0#Gem 0#Gem 0#Gem 0#CAN 0#CAN 0#GPIO1 MIO#GPIO1 MIO#USB0 Reset#GPIO1 MIO#SD\
1#SD 1#SD 1#SD 1#SD 1#SD 1#SD 1#SD 1#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB\
0#USB 0#USB 0#USB 0#USB 0#USB 0#############MDIO 0#MDIO 0} \
   CONFIG.PSU_MIO_TREE_SIGNALS {\
gpio0[0]#gpio0[1]#gpio0[2]#gpio0[3]#gpio0[4]#gpio0[5]#rxd#txd#txd#rxd#scl_out#sda_out#gpio0[12]#sdio0_data_out[0]#sdio0_data_out[1]#sdio0_data_out[2]#sdio0_data_out[3]#sdio0_data_out[4]#sdio0_data_out[5]#sdio0_data_out[6]#sdio0_data_out[7]#sdio0_cmd_out#sdio0_clk_out#sdio0_bus_pow#gpio0[24]#gpio0[25]#rgmii_tx_clk#rgmii_txd[0]#rgmii_txd[1]#rgmii_txd[2]#rgmii_txd[3]#rgmii_tx_ctl#rgmii_rx_clk#rgmii_rxd[0]#rgmii_rxd[1]#rgmii_rxd[2]#rgmii_rxd[3]#rgmii_rx_ctl#phy_rx#phy_tx#gpio1[40]#gpio1[41]#reset#gpio1[43]#sdio1_wp#sdio1_cd_n#sdio1_data_out[0]#sdio1_data_out[1]#sdio1_data_out[2]#sdio1_data_out[3]#sdio1_cmd_out#sdio1_clk_out#ulpi_clk_in#ulpi_dir#ulpi_tx_data[2]#ulpi_nxt#ulpi_tx_data[0]#ulpi_tx_data[1]#ulpi_stp#ulpi_tx_data[3]#ulpi_tx_data[4]#ulpi_tx_data[5]#ulpi_tx_data[6]#ulpi_tx_data[7]#############gem0_mdc#gem0_mdio_out} \
   CONFIG.PSU_PERIPHERAL_BOARD_PRESET {} \
   CONFIG.PSU_SD0_INTERNAL_BUS_WIDTH {8} \
   CONFIG.PSU_SD1_INTERNAL_BUS_WIDTH {4} \
   CONFIG.PSU_SMC_CYCLE_T0 {NA} \
   CONFIG.PSU_SMC_CYCLE_T1 {NA} \
   CONFIG.PSU_SMC_CYCLE_T2 {NA} \
   CONFIG.PSU_SMC_CYCLE_T3 {NA} \
   CONFIG.PSU_SMC_CYCLE_T4 {NA} \
   CONFIG.PSU_SMC_CYCLE_T5 {NA} \
   CONFIG.PSU_SMC_CYCLE_T6 {NA} \
   CONFIG.PSU_USB3__DUAL_CLOCK_ENABLE {1} \
   CONFIG.PSU_VALUE_SILVERSION {3} \
   CONFIG.PSU__ACPU0__POWER__ON {1} \
   CONFIG.PSU__ACPU1__POWER__ON {1} \
   CONFIG.PSU__ACPU2__POWER__ON {1} \
   CONFIG.PSU__ACPU3__POWER__ON {1} \
   CONFIG.PSU__ACTUAL__IP {1} \
   CONFIG.PSU__ACT_DDR_FREQ_MHZ {1200.000000} \
   CONFIG.PSU__AFI0_COHERENCY {0} \
   CONFIG.PSU__AFI1_COHERENCY {0} \
   CONFIG.PSU__AUX_REF_CLK__FREQMHZ {33.333} \
   CONFIG.PSU__CAN0_LOOP_CAN1__ENABLE {0} \
   CONFIG.PSU__CAN0__GRP_CLK__ENABLE {0} \
   CONFIG.PSU__CAN0__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__CAN0__PERIPHERAL__IO {MIO 38 .. 39} \
   CONFIG.PSU__CAN1__GRP_CLK__ENABLE {0} \
   CONFIG.PSU__CAN1__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__CAN1__PERIPHERAL__IO {<Select>} \
   CONFIG.PSU__CRF_APB__ACPU_CTRL__ACT_FREQMHZ {1200.000000} \
   CONFIG.PSU__CRF_APB__ACPU_CTRL__DIVISOR0 {1} \
   CONFIG.PSU__CRF_APB__ACPU_CTRL__FREQMHZ {1200} \
   CONFIG.PSU__CRF_APB__ACPU_CTRL__SRCSEL {DPLL} \
   CONFIG.PSU__CRF_APB__ACPU__FRAC_ENABLED {0} \
   CONFIG.PSU__CRF_APB__AFI0_REF_CTRL__ACT_FREQMHZ {667} \
   CONFIG.PSU__CRF_APB__AFI0_REF_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__AFI0_REF_CTRL__FREQMHZ {667} \
   CONFIG.PSU__CRF_APB__AFI0_REF_CTRL__SRCSEL {DPLL} \
   CONFIG.PSU__CRF_APB__AFI0_REF__ENABLE {0} \
   CONFIG.PSU__CRF_APB__AFI1_REF_CTRL__ACT_FREQMHZ {667} \
   CONFIG.PSU__CRF_APB__AFI1_REF_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__AFI1_REF_CTRL__FREQMHZ {667} \
   CONFIG.PSU__CRF_APB__AFI1_REF_CTRL__SRCSEL {DPLL} \
   CONFIG.PSU__CRF_APB__AFI1_REF__ENABLE {0} \
   CONFIG.PSU__CRF_APB__AFI2_REF_CTRL__ACT_FREQMHZ {667} \
   CONFIG.PSU__CRF_APB__AFI2_REF_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__AFI2_REF_CTRL__FREQMHZ {667} \
   CONFIG.PSU__CRF_APB__AFI2_REF_CTRL__SRCSEL {DPLL} \
   CONFIG.PSU__CRF_APB__AFI2_REF__ENABLE {0} \
   CONFIG.PSU__CRF_APB__AFI3_REF_CTRL__ACT_FREQMHZ {667} \
   CONFIG.PSU__CRF_APB__AFI3_REF_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__AFI3_REF_CTRL__FREQMHZ {667} \
   CONFIG.PSU__CRF_APB__AFI3_REF_CTRL__SRCSEL {DPLL} \
   CONFIG.PSU__CRF_APB__AFI3_REF__ENABLE {0} \
   CONFIG.PSU__CRF_APB__AFI4_REF_CTRL__ACT_FREQMHZ {667} \
   CONFIG.PSU__CRF_APB__AFI4_REF_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__AFI4_REF_CTRL__FREQMHZ {667} \
   CONFIG.PSU__CRF_APB__AFI4_REF_CTRL__SRCSEL {DPLL} \
   CONFIG.PSU__CRF_APB__AFI4_REF__ENABLE {0} \
   CONFIG.PSU__CRF_APB__AFI5_REF_CTRL__ACT_FREQMHZ {667} \
   CONFIG.PSU__CRF_APB__AFI5_REF_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__AFI5_REF_CTRL__FREQMHZ {667} \
   CONFIG.PSU__CRF_APB__AFI5_REF_CTRL__SRCSEL {DPLL} \
   CONFIG.PSU__CRF_APB__AFI5_REF__ENABLE {0} \
   CONFIG.PSU__CRF_APB__APLL_CTRL__DIV2 {1} \
   CONFIG.PSU__CRF_APB__APLL_CTRL__FBDIV {72} \
   CONFIG.PSU__CRF_APB__APLL_CTRL__FRACDATA {0.000000} \
   CONFIG.PSU__CRF_APB__APLL_CTRL__FRACFREQ {27.138} \
   CONFIG.PSU__CRF_APB__APLL_CTRL__SRCSEL {PSS_REF_CLK} \
   CONFIG.PSU__CRF_APB__APLL_FRAC_CFG__ENABLED {0} \
   CONFIG.PSU__CRF_APB__APLL_TO_LPD_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRF_APB__APM_CTRL__ACT_FREQMHZ {1} \
   CONFIG.PSU__CRF_APB__APM_CTRL__DIVISOR0 {1} \
   CONFIG.PSU__CRF_APB__APM_CTRL__FREQMHZ {1} \
   CONFIG.PSU__CRF_APB__DBG_FPD_CTRL__ACT_FREQMHZ {250.000000} \
   CONFIG.PSU__CRF_APB__DBG_FPD_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__DBG_FPD_CTRL__FREQMHZ {250} \
   CONFIG.PSU__CRF_APB__DBG_FPD_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRF_APB__DBG_TRACE_CTRL__ACT_FREQMHZ {250} \
   CONFIG.PSU__CRF_APB__DBG_TRACE_CTRL__DIVISOR0 {5} \
   CONFIG.PSU__CRF_APB__DBG_TRACE_CTRL__FREQMHZ {250} \
   CONFIG.PSU__CRF_APB__DBG_TRACE_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRF_APB__DBG_TSTMP_CTRL__ACT_FREQMHZ {250.000000} \
   CONFIG.PSU__CRF_APB__DBG_TSTMP_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__DBG_TSTMP_CTRL__FREQMHZ {250} \
   CONFIG.PSU__CRF_APB__DBG_TSTMP_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRF_APB__DDR_CTRL__ACT_FREQMHZ {600.000000} \
   CONFIG.PSU__CRF_APB__DDR_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__DDR_CTRL__FREQMHZ {1200} \
   CONFIG.PSU__CRF_APB__DDR_CTRL__SRCSEL {DPLL} \
   CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__ACT_FREQMHZ {600.000000} \
   CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__FREQMHZ {600} \
   CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__SRCSEL {APLL} \
   CONFIG.PSU__CRF_APB__DPLL_CTRL__DIV2 {1} \
   CONFIG.PSU__CRF_APB__DPLL_CTRL__FBDIV {72} \
   CONFIG.PSU__CRF_APB__DPLL_CTRL__FRACDATA {0.000000} \
   CONFIG.PSU__CRF_APB__DPLL_CTRL__FRACFREQ {27.138} \
   CONFIG.PSU__CRF_APB__DPLL_CTRL__SRCSEL {PSS_REF_CLK} \
   CONFIG.PSU__CRF_APB__DPLL_FRAC_CFG__ENABLED {0} \
   CONFIG.PSU__CRF_APB__DPLL_TO_LPD_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRF_APB__DP_AUDIO_REF_CTRL__ACT_FREQMHZ {25.000000} \
   CONFIG.PSU__CRF_APB__DP_AUDIO_REF_CTRL__DIVISOR0 {63} \
   CONFIG.PSU__CRF_APB__DP_AUDIO_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRF_APB__DP_AUDIO_REF_CTRL__FREQMHZ {25} \
   CONFIG.PSU__CRF_APB__DP_AUDIO_REF_CTRL__SRCSEL {RPLL} \
   CONFIG.PSU__CRF_APB__DP_AUDIO__FRAC_ENABLED {0} \
   CONFIG.PSU__CRF_APB__DP_STC_REF_CTRL__ACT_FREQMHZ {26.666666} \
   CONFIG.PSU__CRF_APB__DP_STC_REF_CTRL__DIVISOR0 {6} \
   CONFIG.PSU__CRF_APB__DP_STC_REF_CTRL__DIVISOR1 {10} \
   CONFIG.PSU__CRF_APB__DP_STC_REF_CTRL__FREQMHZ {27} \
   CONFIG.PSU__CRF_APB__DP_STC_REF_CTRL__SRCSEL {RPLL} \
   CONFIG.PSU__CRF_APB__DP_VIDEO_REF_CTRL__ACT_FREQMHZ {300.000000} \
   CONFIG.PSU__CRF_APB__DP_VIDEO_REF_CTRL__DIVISOR0 {5} \
   CONFIG.PSU__CRF_APB__DP_VIDEO_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRF_APB__DP_VIDEO_REF_CTRL__FREQMHZ {300} \
   CONFIG.PSU__CRF_APB__DP_VIDEO_REF_CTRL__SRCSEL {VPLL} \
   CONFIG.PSU__CRF_APB__DP_VIDEO__FRAC_ENABLED {0} \
   CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__ACT_FREQMHZ {600.000000} \
   CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__FREQMHZ {600} \
   CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__SRCSEL {APLL} \
   CONFIG.PSU__CRF_APB__GPU_REF_CTRL__ACT_FREQMHZ {600.000000} \
   CONFIG.PSU__CRF_APB__GPU_REF_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__GPU_REF_CTRL__FREQMHZ {600} \
   CONFIG.PSU__CRF_APB__GPU_REF_CTRL__SRCSEL {DPLL} \
   CONFIG.PSU__CRF_APB__GTGREF0_REF_CTRL__ACT_FREQMHZ {-1} \
   CONFIG.PSU__CRF_APB__GTGREF0_REF_CTRL__DIVISOR0 {-1} \
   CONFIG.PSU__CRF_APB__GTGREF0_REF_CTRL__FREQMHZ {-1} \
   CONFIG.PSU__CRF_APB__GTGREF0_REF_CTRL__SRCSEL {NA} \
   CONFIG.PSU__CRF_APB__GTGREF0__ENABLE {NA} \
   CONFIG.PSU__CRF_APB__PCIE_REF_CTRL__ACT_FREQMHZ {250.000000} \
   CONFIG.PSU__CRF_APB__PCIE_REF_CTRL__DIVISOR0 {6} \
   CONFIG.PSU__CRF_APB__PCIE_REF_CTRL__FREQMHZ {250} \
   CONFIG.PSU__CRF_APB__PCIE_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRF_APB__SATA_REF_CTRL__ACT_FREQMHZ {250.000000} \
   CONFIG.PSU__CRF_APB__SATA_REF_CTRL__DIVISOR0 {5} \
   CONFIG.PSU__CRF_APB__SATA_REF_CTRL__FREQMHZ {250} \
   CONFIG.PSU__CRF_APB__SATA_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRF_APB__TOPSW_LSBUS_CTRL__ACT_FREQMHZ {100.000000} \
   CONFIG.PSU__CRF_APB__TOPSW_LSBUS_CTRL__DIVISOR0 {5} \
   CONFIG.PSU__CRF_APB__TOPSW_LSBUS_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRF_APB__TOPSW_LSBUS_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__ACT_FREQMHZ {400.000000} \
   CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__FREQMHZ {533.33} \
   CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__SRCSEL {DPLL} \
   CONFIG.PSU__CRF_APB__VPLL_CTRL__DIV2 {1} \
   CONFIG.PSU__CRF_APB__VPLL_CTRL__FBDIV {90} \
   CONFIG.PSU__CRF_APB__VPLL_CTRL__FRACDATA {0.000000} \
   CONFIG.PSU__CRF_APB__VPLL_CTRL__FRACFREQ {27.138} \
   CONFIG.PSU__CRF_APB__VPLL_CTRL__SRCSEL {PSS_REF_CLK} \
   CONFIG.PSU__CRF_APB__VPLL_FRAC_CFG__ENABLED {0} \
   CONFIG.PSU__CRF_APB__VPLL_TO_LPD_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__ACT_FREQMHZ {500.000000} \
   CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__FREQMHZ {500} \
   CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__AFI6_REF_CTRL__ACT_FREQMHZ {500} \
   CONFIG.PSU__CRL_APB__AFI6_REF_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRL_APB__AFI6_REF_CTRL__FREQMHZ {500} \
   CONFIG.PSU__CRL_APB__AFI6_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__AFI6__ENABLE {0} \
   CONFIG.PSU__CRL_APB__AMS_REF_CTRL__ACT_FREQMHZ {50.000000} \
   CONFIG.PSU__CRL_APB__AMS_REF_CTRL__DIVISOR0 {30} \
   CONFIG.PSU__CRL_APB__AMS_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__AMS_REF_CTRL__FREQMHZ {50} \
   CONFIG.PSU__CRL_APB__AMS_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__CAN0_REF_CTRL__ACT_FREQMHZ {100.000000} \
   CONFIG.PSU__CRL_APB__CAN0_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__CAN0_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__CAN0_REF_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__CAN0_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__ACT_FREQMHZ {100.000000} \
   CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__CPU_R5_CTRL__ACT_FREQMHZ {500.000000} \
   CONFIG.PSU__CRL_APB__CPU_R5_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRL_APB__CPU_R5_CTRL__FREQMHZ {500} \
   CONFIG.PSU__CRL_APB__CPU_R5_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__CSU_PLL_CTRL__ACT_FREQMHZ {180} \
   CONFIG.PSU__CRL_APB__CSU_PLL_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRL_APB__CSU_PLL_CTRL__FREQMHZ {180} \
   CONFIG.PSU__CRL_APB__CSU_PLL_CTRL__SRCSEL {SysOsc} \
   CONFIG.PSU__CRL_APB__DBG_LPD_CTRL__ACT_FREQMHZ {250.000000} \
   CONFIG.PSU__CRL_APB__DBG_LPD_CTRL__DIVISOR0 {6} \
   CONFIG.PSU__CRL_APB__DBG_LPD_CTRL__FREQMHZ {250} \
   CONFIG.PSU__CRL_APB__DBG_LPD_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__DEBUG_R5_ATCLK_CTRL__ACT_FREQMHZ {1000} \
   CONFIG.PSU__CRL_APB__DEBUG_R5_ATCLK_CTRL__DIVISOR0 {6} \
   CONFIG.PSU__CRL_APB__DEBUG_R5_ATCLK_CTRL__FREQMHZ {1000} \
   CONFIG.PSU__CRL_APB__DEBUG_R5_ATCLK_CTRL__SRCSEL {RPLL} \
   CONFIG.PSU__CRL_APB__DLL_REF_CTRL__ACT_FREQMHZ {1500.000000} \
   CONFIG.PSU__CRL_APB__DLL_REF_CTRL__FREQMHZ {1500} \
   CONFIG.PSU__CRL_APB__DLL_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__GEM0_REF_CTRL__ACT_FREQMHZ {125.000000} \
   CONFIG.PSU__CRL_APB__GEM0_REF_CTRL__DIVISOR0 {12} \
   CONFIG.PSU__CRL_APB__GEM0_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__GEM0_REF_CTRL__FREQMHZ {125} \
   CONFIG.PSU__CRL_APB__GEM0_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__GEM1_REF_CTRL__ACT_FREQMHZ {125} \
   CONFIG.PSU__CRL_APB__GEM1_REF_CTRL__DIVISOR0 {12} \
   CONFIG.PSU__CRL_APB__GEM1_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__GEM1_REF_CTRL__FREQMHZ {125} \
   CONFIG.PSU__CRL_APB__GEM1_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__GEM2_REF_CTRL__ACT_FREQMHZ {125} \
   CONFIG.PSU__CRL_APB__GEM2_REF_CTRL__DIVISOR0 {12} \
   CONFIG.PSU__CRL_APB__GEM2_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__GEM2_REF_CTRL__FREQMHZ {125} \
   CONFIG.PSU__CRL_APB__GEM2_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__GEM3_REF_CTRL__ACT_FREQMHZ {125.000000} \
   CONFIG.PSU__CRL_APB__GEM3_REF_CTRL__DIVISOR0 {12} \
   CONFIG.PSU__CRL_APB__GEM3_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__GEM3_REF_CTRL__FREQMHZ {125} \
   CONFIG.PSU__CRL_APB__GEM3_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__GEM_TSU_REF_CTRL__ACT_FREQMHZ {250.000000} \
   CONFIG.PSU__CRL_APB__GEM_TSU_REF_CTRL__DIVISOR0 {6} \
   CONFIG.PSU__CRL_APB__GEM_TSU_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__GEM_TSU_REF_CTRL__FREQMHZ {250} \
   CONFIG.PSU__CRL_APB__GEM_TSU_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__I2C0_REF_CTRL__ACT_FREQMHZ {100.000000} \
   CONFIG.PSU__CRL_APB__I2C0_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__I2C0_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__I2C0_REF_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__I2C0_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__ACT_FREQMHZ {100.000000} \
   CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__IOPLL_CTRL__DIV2 {1} \
   CONFIG.PSU__CRL_APB__IOPLL_CTRL__FBDIV {90} \
   CONFIG.PSU__CRL_APB__IOPLL_CTRL__FRACDATA {0.000000} \
   CONFIG.PSU__CRL_APB__IOPLL_CTRL__FRACFREQ {27.138} \
   CONFIG.PSU__CRL_APB__IOPLL_CTRL__SRCSEL {PSS_REF_CLK} \
   CONFIG.PSU__CRL_APB__IOPLL_FRAC_CFG__ENABLED {0} \
   CONFIG.PSU__CRL_APB__IOPLL_TO_FPD_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__ACT_FREQMHZ {250.000000} \
   CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__DIVISOR0 {6} \
   CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__FREQMHZ {250} \
   CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__LPD_LSBUS_CTRL__ACT_FREQMHZ {100.000000} \
   CONFIG.PSU__CRL_APB__LPD_LSBUS_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__LPD_LSBUS_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__LPD_LSBUS_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__ACT_FREQMHZ {500.000000} \
   CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__FREQMHZ {500} \
   CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__NAND_REF_CTRL__ACT_FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__NAND_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__NAND_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__NAND_REF_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__NAND_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__OCM_MAIN_CTRL__ACT_FREQMHZ {500} \
   CONFIG.PSU__CRL_APB__OCM_MAIN_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRL_APB__OCM_MAIN_CTRL__FREQMHZ {500} \
   CONFIG.PSU__CRL_APB__OCM_MAIN_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__PCAP_CTRL__ACT_FREQMHZ {187.500000} \
   CONFIG.PSU__CRL_APB__PCAP_CTRL__DIVISOR0 {8} \
   CONFIG.PSU__CRL_APB__PCAP_CTRL__FREQMHZ {200} \
   CONFIG.PSU__CRL_APB__PCAP_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__PL0_REF_CTRL__ACT_FREQMHZ {100.000000} \
   CONFIG.PSU__CRL_APB__PL0_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__PL0_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__PL0_REF_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__PL0_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__PL1_REF_CTRL__ACT_FREQMHZ {250.000000} \
   CONFIG.PSU__CRL_APB__PL1_REF_CTRL__DIVISOR0 {6} \
   CONFIG.PSU__CRL_APB__PL1_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__PL1_REF_CTRL__FREQMHZ {250} \
   CONFIG.PSU__CRL_APB__PL1_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__PL2_REF_CTRL__ACT_FREQMHZ {500.000000} \
   CONFIG.PSU__CRL_APB__PL2_REF_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRL_APB__PL2_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__PL2_REF_CTRL__FREQMHZ {500} \
   CONFIG.PSU__CRL_APB__PL2_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__PL3_REF_CTRL__ACT_FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__PL3_REF_CTRL__DIVISOR0 {4} \
   CONFIG.PSU__CRL_APB__PL3_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__PL3_REF_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__PL3_REF_CTRL__SRCSEL {RPLL} \
   CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__ACT_FREQMHZ {125.000000} \
   CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__DIVISOR0 {5} \
   CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__FREQMHZ {125} \
   CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__RPLL_CTRL__DIV2 {1} \
   CONFIG.PSU__CRL_APB__RPLL_CTRL__FBDIV {84} \
   CONFIG.PSU__CRL_APB__RPLL_CTRL__FRACDATA {0.000000} \
   CONFIG.PSU__CRL_APB__RPLL_CTRL__FRACFREQ {27.138} \
   CONFIG.PSU__CRL_APB__RPLL_CTRL__SRCSEL {PSS_REF_CLK} \
   CONFIG.PSU__CRL_APB__RPLL_FRAC_CFG__ENABLED {0} \
   CONFIG.PSU__CRL_APB__RPLL_TO_FPD_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRL_APB__SDIO0_REF_CTRL__ACT_FREQMHZ {187.500000} \
   CONFIG.PSU__CRL_APB__SDIO0_REF_CTRL__DIVISOR0 {8} \
   CONFIG.PSU__CRL_APB__SDIO0_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__SDIO0_REF_CTRL__FREQMHZ {200} \
   CONFIG.PSU__CRL_APB__SDIO0_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__ACT_FREQMHZ {187.500000} \
   CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__DIVISOR0 {8} \
   CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__FREQMHZ {200} \
   CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__SPI0_REF_CTRL__ACT_FREQMHZ {187.500000} \
   CONFIG.PSU__CRL_APB__SPI0_REF_CTRL__DIVISOR0 {8} \
   CONFIG.PSU__CRL_APB__SPI0_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__SPI0_REF_CTRL__FREQMHZ {200} \
   CONFIG.PSU__CRL_APB__SPI0_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__SPI1_REF_CTRL__ACT_FREQMHZ {200.000000} \
   CONFIG.PSU__CRL_APB__SPI1_REF_CTRL__DIVISOR0 {7} \
   CONFIG.PSU__CRL_APB__SPI1_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__SPI1_REF_CTRL__FREQMHZ {200} \
   CONFIG.PSU__CRL_APB__SPI1_REF_CTRL__SRCSEL {RPLL} \
   CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__ACT_FREQMHZ {100.000000} \
   CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__UART0_REF_CTRL__ACT_FREQMHZ {100.000000} \
   CONFIG.PSU__CRL_APB__UART0_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__UART0_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__UART0_REF_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__UART0_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__UART1_REF_CTRL__ACT_FREQMHZ {100.000000} \
   CONFIG.PSU__CRL_APB__UART1_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__UART1_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__UART1_REF_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__UART1_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__USB0_BUS_REF_CTRL__ACT_FREQMHZ {250.000000} \
   CONFIG.PSU__CRL_APB__USB0_BUS_REF_CTRL__DIVISOR0 {6} \
   CONFIG.PSU__CRL_APB__USB0_BUS_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__USB0_BUS_REF_CTRL__FREQMHZ {250} \
   CONFIG.PSU__CRL_APB__USB0_BUS_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__USB1_BUS_REF_CTRL__ACT_FREQMHZ {250} \
   CONFIG.PSU__CRL_APB__USB1_BUS_REF_CTRL__DIVISOR0 {6} \
   CONFIG.PSU__CRL_APB__USB1_BUS_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__USB1_BUS_REF_CTRL__FREQMHZ {250} \
   CONFIG.PSU__CRL_APB__USB1_BUS_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__USB3_DUAL_REF_CTRL__ACT_FREQMHZ {20.000000} \
   CONFIG.PSU__CRL_APB__USB3_DUAL_REF_CTRL__DIVISOR0 {25} \
   CONFIG.PSU__CRL_APB__USB3_DUAL_REF_CTRL__DIVISOR1 {3} \
   CONFIG.PSU__CRL_APB__USB3_DUAL_REF_CTRL__FREQMHZ {20} \
   CONFIG.PSU__CRL_APB__USB3_DUAL_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__USB3__ENABLE {1} \
   CONFIG.PSU__CSUPMU__PERIPHERAL__VALID {0} \
   CONFIG.PSU__CSU_COHERENCY {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_0__ENABLE {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_0__ERASE_BBRAM {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_10__ENABLE {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_10__ERASE_BBRAM {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_11__ENABLE {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_11__ERASE_BBRAM {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_12__ENABLE {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_12__ERASE_BBRAM {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_1__ENABLE {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_1__ERASE_BBRAM {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_2__ENABLE {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_2__ERASE_BBRAM {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_3__ENABLE {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_3__ERASE_BBRAM {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_4__ENABLE {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_4__ERASE_BBRAM {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_5__ENABLE {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_5__ERASE_BBRAM {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_6__ENABLE {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_6__ERASE_BBRAM {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_7__ENABLE {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_7__ERASE_BBRAM {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_8__ENABLE {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_8__ERASE_BBRAM {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_9__ENABLE {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_9__ERASE_BBRAM {0} \
   CONFIG.PSU__CSU__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__DDRC__ADDR_MIRROR {0} \
   CONFIG.PSU__DDRC__AL {0} \
   CONFIG.PSU__DDRC__BANK_ADDR_COUNT {2} \
   CONFIG.PSU__DDRC__BG_ADDR_COUNT {1} \
   CONFIG.PSU__DDRC__BRC_MAPPING {ROW_BANK_COL} \
   CONFIG.PSU__DDRC__BUS_WIDTH {64 Bit} \
   CONFIG.PSU__DDRC__CL {16} \
   CONFIG.PSU__DDRC__CLOCK_STOP_EN {0} \
   CONFIG.PSU__DDRC__COL_ADDR_COUNT {10} \
   CONFIG.PSU__DDRC__COMPONENTS {Components} \
   CONFIG.PSU__DDRC__CWL {16} \
   CONFIG.PSU__DDRC__DDR3L_T_REF_RANGE {NA} \
   CONFIG.PSU__DDRC__DDR3_T_REF_RANGE {NA} \
   CONFIG.PSU__DDRC__DDR4_ADDR_MAPPING {0} \
   CONFIG.PSU__DDRC__DDR4_CAL_MODE_ENABLE {0} \
   CONFIG.PSU__DDRC__DDR4_CRC_CONTROL {0} \
   CONFIG.PSU__DDRC__DDR4_MAXPWR_SAVING_EN {0} \
   CONFIG.PSU__DDRC__DDR4_T_REF_MODE {0} \
   CONFIG.PSU__DDRC__DDR4_T_REF_RANGE {Normal (0-85)} \
   CONFIG.PSU__DDRC__DEEP_PWR_DOWN_EN {0} \
   CONFIG.PSU__DDRC__DEVICE_CAPACITY {8192 MBits} \
   CONFIG.PSU__DDRC__DIMM_ADDR_MIRROR {0} \
   CONFIG.PSU__DDRC__DM_DBI {DM_NO_DBI} \
   CONFIG.PSU__DDRC__DQMAP_0_3 {0} \
   CONFIG.PSU__DDRC__DQMAP_12_15 {0} \
   CONFIG.PSU__DDRC__DQMAP_16_19 {0} \
   CONFIG.PSU__DDRC__DQMAP_20_23 {0} \
   CONFIG.PSU__DDRC__DQMAP_24_27 {0} \
   CONFIG.PSU__DDRC__DQMAP_28_31 {0} \
   CONFIG.PSU__DDRC__DQMAP_32_35 {0} \
   CONFIG.PSU__DDRC__DQMAP_36_39 {0} \
   CONFIG.PSU__DDRC__DQMAP_40_43 {0} \
   CONFIG.PSU__DDRC__DQMAP_44_47 {0} \
   CONFIG.PSU__DDRC__DQMAP_48_51 {0} \
   CONFIG.PSU__DDRC__DQMAP_4_7 {0} \
   CONFIG.PSU__DDRC__DQMAP_52_55 {0} \
   CONFIG.PSU__DDRC__DQMAP_56_59 {0} \
   CONFIG.PSU__DDRC__DQMAP_60_63 {0} \
   CONFIG.PSU__DDRC__DQMAP_64_67 {0} \
   CONFIG.PSU__DDRC__DQMAP_68_71 {0} \
   CONFIG.PSU__DDRC__DQMAP_8_11 {0} \
   CONFIG.PSU__DDRC__DRAM_WIDTH {16 Bits} \
   CONFIG.PSU__DDRC__ECC {Enabled} \
   CONFIG.PSU__DDRC__ECC_SCRUB {0} \
   CONFIG.PSU__DDRC__ENABLE {1} \
   CONFIG.PSU__DDRC__ENABLE_2T_TIMING {0} \
   CONFIG.PSU__DDRC__ENABLE_DP_SWITCH {0} \
   CONFIG.PSU__DDRC__ENABLE_LP4_HAS_ECC_COMP {ERR: 1  | 0} \
   CONFIG.PSU__DDRC__ENABLE_LP4_SLOWBOOT {0} \
   CONFIG.PSU__DDRC__EN_2ND_CLK {0} \
   CONFIG.PSU__DDRC__FGRM {1X} \
   CONFIG.PSU__DDRC__FREQ_MHZ {1} \
   CONFIG.PSU__DDRC__LPDDR3_DUALRANK_SDP {0} \
   CONFIG.PSU__DDRC__LPDDR3_T_REF_RANGE {NA} \
   CONFIG.PSU__DDRC__LPDDR4_T_REF_RANGE {NA} \
   CONFIG.PSU__DDRC__LP_ASR {manual normal} \
   CONFIG.PSU__DDRC__MEMORY_TYPE {DDR 4} \
   CONFIG.PSU__DDRC__PARITY_ENABLE {0} \
   CONFIG.PSU__DDRC__PER_BANK_REFRESH {0} \
   CONFIG.PSU__DDRC__PHY_DBI_MODE {0} \
   CONFIG.PSU__DDRC__PLL_BYPASS {0} \
   CONFIG.PSU__DDRC__PWR_DOWN_EN {0} \
   CONFIG.PSU__DDRC__RANK_ADDR_COUNT {0} \
   CONFIG.PSU__DDRC__RD_DQS_CENTER {0} \
   CONFIG.PSU__DDRC__ROW_ADDR_COUNT {16} \
   CONFIG.PSU__DDRC__SB_TARGET {16-16-16} \
   CONFIG.PSU__DDRC__SELF_REF_ABORT {0} \
   CONFIG.PSU__DDRC__SPEED_BIN {DDR4_2400R} \
   CONFIG.PSU__DDRC__STATIC_RD_MODE {0} \
   CONFIG.PSU__DDRC__TRAIN_DATA_EYE {1} \
   CONFIG.PSU__DDRC__TRAIN_READ_GATE {1} \
   CONFIG.PSU__DDRC__TRAIN_WRITE_LEVEL {1} \
   CONFIG.PSU__DDRC__T_FAW {30.0} \
   CONFIG.PSU__DDRC__T_RAS_MIN {32} \
   CONFIG.PSU__DDRC__T_RC {45.32} \
   CONFIG.PSU__DDRC__T_RCD {16} \
   CONFIG.PSU__DDRC__T_RP {16} \
   CONFIG.PSU__DDRC__VENDOR_PART {OTHERS} \
   CONFIG.PSU__DDRC__VIDEO_BUFFER_SIZE {0} \
   CONFIG.PSU__DDRC__VREF {1} \
   CONFIG.PSU__DDR_HIGH_ADDRESS_GUI_ENABLE {1} \
   CONFIG.PSU__DDR_QOS_ENABLE {0} \
   CONFIG.PSU__DDR_QOS_FIX_HP0_RDQOS {} \
   CONFIG.PSU__DDR_QOS_FIX_HP0_WRQOS {} \
   CONFIG.PSU__DDR_QOS_FIX_HP1_RDQOS {} \
   CONFIG.PSU__DDR_QOS_FIX_HP1_WRQOS {} \
   CONFIG.PSU__DDR_QOS_FIX_HP2_RDQOS {} \
   CONFIG.PSU__DDR_QOS_FIX_HP2_WRQOS {} \
   CONFIG.PSU__DDR_QOS_FIX_HP3_RDQOS {} \
   CONFIG.PSU__DDR_QOS_FIX_HP3_WRQOS {} \
   CONFIG.PSU__DDR_QOS_HP0_RDQOS {} \
   CONFIG.PSU__DDR_QOS_HP0_WRQOS {} \
   CONFIG.PSU__DDR_QOS_HP1_RDQOS {} \
   CONFIG.PSU__DDR_QOS_HP1_WRQOS {} \
   CONFIG.PSU__DDR_QOS_HP2_RDQOS {} \
   CONFIG.PSU__DDR_QOS_HP2_WRQOS {} \
   CONFIG.PSU__DDR_QOS_HP3_RDQOS {} \
   CONFIG.PSU__DDR_QOS_HP3_WRQOS {} \
   CONFIG.PSU__DDR_QOS_RD_HPR_THRSHLD {} \
   CONFIG.PSU__DDR_QOS_RD_LPR_THRSHLD {} \
   CONFIG.PSU__DDR_QOS_WR_THRSHLD {} \
   CONFIG.PSU__DDR_SW_REFRESH_ENABLED {1} \
   CONFIG.PSU__DDR__INTERFACE__FREQMHZ {600.000} \
   CONFIG.PSU__DEVICE_TYPE {EG} \
   CONFIG.PSU__DISPLAYPORT__LANE0__ENABLE {0} \
   CONFIG.PSU__DISPLAYPORT__LANE0__IO {<Select>} \
   CONFIG.PSU__DISPLAYPORT__LANE1__ENABLE {0} \
   CONFIG.PSU__DISPLAYPORT__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__DLL__ISUSED {1} \
   CONFIG.PSU__DPAUX__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__DPAUX__PERIPHERAL__IO {<Select>} \
   CONFIG.PSU__DP__LANE_SEL {<Select>} \
   CONFIG.PSU__DP__REF_CLK_FREQ {<Select>} \
   CONFIG.PSU__DP__REF_CLK_SEL {<Select>} \
   CONFIG.PSU__ENABLE__DDR__REFRESH__SIGNALS {0} \
   CONFIG.PSU__ENET0__FIFO__ENABLE {0} \
   CONFIG.PSU__ENET0__GRP_MDIO__ENABLE {1} \
   CONFIG.PSU__ENET0__GRP_MDIO__IO {MIO 76 .. 77} \
   CONFIG.PSU__ENET0__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__ENET0__PERIPHERAL__IO {MIO 26 .. 37} \
   CONFIG.PSU__ENET0__PTP__ENABLE {0} \
   CONFIG.PSU__ENET0__TSU__ENABLE {0} \
   CONFIG.PSU__ENET1__FIFO__ENABLE {0} \
   CONFIG.PSU__ENET1__GRP_MDIO__ENABLE {0} \
   CONFIG.PSU__ENET1__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__ENET1__PTP__ENABLE {0} \
   CONFIG.PSU__ENET1__TSU__ENABLE {0} \
   CONFIG.PSU__ENET2__FIFO__ENABLE {0} \
   CONFIG.PSU__ENET2__GRP_MDIO__ENABLE {0} \
   CONFIG.PSU__ENET2__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__ENET2__PTP__ENABLE {0} \
   CONFIG.PSU__ENET2__TSU__ENABLE {0} \
   CONFIG.PSU__ENET3__FIFO__ENABLE {0} \
   CONFIG.PSU__ENET3__GRP_MDIO__ENABLE {0} \
   CONFIG.PSU__ENET3__GRP_MDIO__IO {<Select>} \
   CONFIG.PSU__ENET3__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__ENET3__PERIPHERAL__IO {<Select>} \
   CONFIG.PSU__ENET3__PTP__ENABLE {0} \
   CONFIG.PSU__ENET3__TSU__ENABLE {0} \
   CONFIG.PSU__EN_AXI_STATUS_PORTS {0} \
   CONFIG.PSU__EN_EMIO_TRACE {0} \
   CONFIG.PSU__EP__IP {0} \
   CONFIG.PSU__EXPAND__CORESIGHT {0} \
   CONFIG.PSU__EXPAND__FPD_SLAVES {0} \
   CONFIG.PSU__EXPAND__GIC {0} \
   CONFIG.PSU__EXPAND__LOWER_LPS_SLAVES {0} \
   CONFIG.PSU__EXPAND__UPPER_LPS_SLAVES {0} \
   CONFIG.PSU__FPDMASTERS_COHERENCY {0} \
   CONFIG.PSU__FPD_SLCR__WDT1__ACT_FREQMHZ {100.000000} \
   CONFIG.PSU__FPD_SLCR__WDT1__FREQMHZ {100.000000} \
   CONFIG.PSU__FPD_SLCR__WDT_CLK_SEL__SELECT {APB} \
   CONFIG.PSU__FPGA_PL0_ENABLE {1} \
   CONFIG.PSU__FPGA_PL1_ENABLE {1} \
   CONFIG.PSU__FPGA_PL2_ENABLE {1} \
   CONFIG.PSU__FPGA_PL3_ENABLE {0} \
   CONFIG.PSU__FP__POWER__ON {1} \
   CONFIG.PSU__FTM__CTI_IN_0 {0} \
   CONFIG.PSU__FTM__CTI_IN_1 {0} \
   CONFIG.PSU__FTM__CTI_IN_2 {0} \
   CONFIG.PSU__FTM__CTI_IN_3 {0} \
   CONFIG.PSU__FTM__CTI_OUT_0 {0} \
   CONFIG.PSU__FTM__CTI_OUT_1 {0} \
   CONFIG.PSU__FTM__CTI_OUT_2 {0} \
   CONFIG.PSU__FTM__CTI_OUT_3 {0} \
   CONFIG.PSU__FTM__GPI {0} \
   CONFIG.PSU__FTM__GPO {0} \
   CONFIG.PSU__GEM0_COHERENCY {0} \
   CONFIG.PSU__GEM0_ROUTE_THROUGH_FPD {0} \
   CONFIG.PSU__GEM1_COHERENCY {0} \
   CONFIG.PSU__GEM1_ROUTE_THROUGH_FPD {0} \
   CONFIG.PSU__GEM2_COHERENCY {0} \
   CONFIG.PSU__GEM2_ROUTE_THROUGH_FPD {0} \
   CONFIG.PSU__GEM3_COHERENCY {0} \
   CONFIG.PSU__GEM3_ROUTE_THROUGH_FPD {0} \
   CONFIG.PSU__GEM__TSU__ENABLE {0} \
   CONFIG.PSU__GEN_IPI_0__MASTER {APU} \
   CONFIG.PSU__GEN_IPI_10__MASTER {NONE} \
   CONFIG.PSU__GEN_IPI_1__MASTER {RPU0} \
   CONFIG.PSU__GEN_IPI_2__MASTER {RPU1} \
   CONFIG.PSU__GEN_IPI_3__MASTER {PMU} \
   CONFIG.PSU__GEN_IPI_4__MASTER {PMU} \
   CONFIG.PSU__GEN_IPI_5__MASTER {PMU} \
   CONFIG.PSU__GEN_IPI_6__MASTER {PMU} \
   CONFIG.PSU__GEN_IPI_7__MASTER {NONE} \
   CONFIG.PSU__GEN_IPI_8__MASTER {NONE} \
   CONFIG.PSU__GEN_IPI_9__MASTER {NONE} \
   CONFIG.PSU__GPIO0_MIO__IO {MIO 0 .. 25} \
   CONFIG.PSU__GPIO0_MIO__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__GPIO1_MIO__IO {MIO 26 .. 51} \
   CONFIG.PSU__GPIO1_MIO__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__GPIO2_MIO__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__GPIO_EMIO_WIDTH {95} \
   CONFIG.PSU__GPIO_EMIO__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__GPIO_EMIO__PERIPHERAL__IO {95} \
   CONFIG.PSU__GPIO_EMIO__WIDTH {[94:0]} \
   CONFIG.PSU__GPU_PP0__POWER__ON {1} \
   CONFIG.PSU__GPU_PP1__POWER__ON {1} \
   CONFIG.PSU__GT_REF_CLK__FREQMHZ {33.333} \
   CONFIG.PSU__GT__LINK_SPEED {<Select>} \
   CONFIG.PSU__GT__PRE_EMPH_LVL_4 {} \
   CONFIG.PSU__GT__VLT_SWNG_LVL_4 {} \
   CONFIG.PSU__HIGH_ADDRESS__ENABLE {1} \
   CONFIG.PSU__HPM0_FPD__NUM_READ_THREADS {4} \
   CONFIG.PSU__HPM0_FPD__NUM_WRITE_THREADS {4} \
   CONFIG.PSU__HPM0_LPD__NUM_READ_THREADS {4} \
   CONFIG.PSU__HPM0_LPD__NUM_WRITE_THREADS {4} \
   CONFIG.PSU__HPM1_FPD__NUM_READ_THREADS {4} \
   CONFIG.PSU__HPM1_FPD__NUM_WRITE_THREADS {4} \
   CONFIG.PSU__I2C0_LOOP_I2C1__ENABLE {0} \
   CONFIG.PSU__I2C0__GRP_INT__ENABLE {0} \
   CONFIG.PSU__I2C0__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__I2C0__PERIPHERAL__IO {MIO 10 .. 11} \
   CONFIG.PSU__I2C1__GRP_INT__ENABLE {0} \
   CONFIG.PSU__I2C1__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__I2C1__PERIPHERAL__IO {<Select>} \
   CONFIG.PSU__IOU_SLCR__IOU_TTC_APB_CLK__TTC0_SEL {APB} \
   CONFIG.PSU__IOU_SLCR__IOU_TTC_APB_CLK__TTC1_SEL {APB} \
   CONFIG.PSU__IOU_SLCR__IOU_TTC_APB_CLK__TTC2_SEL {APB} \
   CONFIG.PSU__IOU_SLCR__IOU_TTC_APB_CLK__TTC3_SEL {APB} \
   CONFIG.PSU__IOU_SLCR__TTC0__ACT_FREQMHZ {100.000000} \
   CONFIG.PSU__IOU_SLCR__TTC0__FREQMHZ {100.000000} \
   CONFIG.PSU__IOU_SLCR__TTC1__ACT_FREQMHZ {100.000000} \
   CONFIG.PSU__IOU_SLCR__TTC1__FREQMHZ {100.000000} \
   CONFIG.PSU__IOU_SLCR__TTC2__ACT_FREQMHZ {100.000000} \
   CONFIG.PSU__IOU_SLCR__TTC2__FREQMHZ {100.000000} \
   CONFIG.PSU__IOU_SLCR__TTC3__ACT_FREQMHZ {100.000000} \
   CONFIG.PSU__IOU_SLCR__TTC3__FREQMHZ {100.000000} \
   CONFIG.PSU__IOU_SLCR__WDT0__ACT_FREQMHZ {100.000000} \
   CONFIG.PSU__IOU_SLCR__WDT0__FREQMHZ {100.000000} \
   CONFIG.PSU__IOU_SLCR__WDT_CLK_SEL__SELECT {APB} \
   CONFIG.PSU__IRQ_P2F_ADMA_CHAN__INT {0} \
   CONFIG.PSU__IRQ_P2F_AIB_AXI__INT {0} \
   CONFIG.PSU__IRQ_P2F_AMS__INT {0} \
   CONFIG.PSU__IRQ_P2F_APM_FPD__INT {0} \
   CONFIG.PSU__IRQ_P2F_APU_COMM__INT {0} \
   CONFIG.PSU__IRQ_P2F_APU_CPUMNT__INT {0} \
   CONFIG.PSU__IRQ_P2F_APU_CTI__INT {0} \
   CONFIG.PSU__IRQ_P2F_APU_EXTERR__INT {0} \
   CONFIG.PSU__IRQ_P2F_APU_IPI__INT {0} \
   CONFIG.PSU__IRQ_P2F_APU_L2ERR__INT {0} \
   CONFIG.PSU__IRQ_P2F_APU_PMU__INT {0} \
   CONFIG.PSU__IRQ_P2F_APU_REGS__INT {0} \
   CONFIG.PSU__IRQ_P2F_ATB_LPD__INT {0} \
   CONFIG.PSU__IRQ_P2F_CAN0__INT {0} \
   CONFIG.PSU__IRQ_P2F_CAN1__INT {0} \
   CONFIG.PSU__IRQ_P2F_CLKMON__INT {0} \
   CONFIG.PSU__IRQ_P2F_CSUPMU_WDT__INT {0} \
   CONFIG.PSU__IRQ_P2F_CSU_DMA__INT {0} \
   CONFIG.PSU__IRQ_P2F_CSU__INT {0} \
   CONFIG.PSU__IRQ_P2F_DDR_SS__INT {0} \
   CONFIG.PSU__IRQ_P2F_DPDMA__INT {0} \
   CONFIG.PSU__IRQ_P2F_DPORT__INT {0} \
   CONFIG.PSU__IRQ_P2F_EFUSE__INT {0} \
   CONFIG.PSU__IRQ_P2F_ENT0_WAKEUP__INT {0} \
   CONFIG.PSU__IRQ_P2F_ENT0__INT {0} \
   CONFIG.PSU__IRQ_P2F_ENT1_WAKEUP__INT {0} \
   CONFIG.PSU__IRQ_P2F_ENT1__INT {0} \
   CONFIG.PSU__IRQ_P2F_ENT2_WAKEUP__INT {0} \
   CONFIG.PSU__IRQ_P2F_ENT2__INT {0} \
   CONFIG.PSU__IRQ_P2F_ENT3_WAKEUP__INT {0} \
   CONFIG.PSU__IRQ_P2F_ENT3__INT {0} \
   CONFIG.PSU__IRQ_P2F_FPD_APB__INT {0} \
   CONFIG.PSU__IRQ_P2F_FPD_ATB_ERR__INT {0} \
   CONFIG.PSU__IRQ_P2F_FP_WDT__INT {0} \
   CONFIG.PSU__IRQ_P2F_GDMA_CHAN__INT {0} \
   CONFIG.PSU__IRQ_P2F_GPIO__INT {0} \
   CONFIG.PSU__IRQ_P2F_GPU__INT {0} \
   CONFIG.PSU__IRQ_P2F_I2C0__INT {0} \
   CONFIG.PSU__IRQ_P2F_I2C1__INT {0} \
   CONFIG.PSU__IRQ_P2F_LPD_APB__INT {0} \
   CONFIG.PSU__IRQ_P2F_LPD_APM__INT {0} \
   CONFIG.PSU__IRQ_P2F_LP_WDT__INT {0} \
   CONFIG.PSU__IRQ_P2F_NAND__INT {0} \
   CONFIG.PSU__IRQ_P2F_OCM_ERR__INT {0} \
   CONFIG.PSU__IRQ_P2F_PCIE_DMA__INT {0} \
   CONFIG.PSU__IRQ_P2F_PCIE_LEGACY__INT {0} \
   CONFIG.PSU__IRQ_P2F_PCIE_MSC__INT {0} \
   CONFIG.PSU__IRQ_P2F_PCIE_MSI__INT {0} \
   CONFIG.PSU__IRQ_P2F_PL_IPI__INT {0} \
   CONFIG.PSU__IRQ_P2F_QSPI__INT {0} \
   CONFIG.PSU__IRQ_P2F_R5_CORE0_ECC_ERR__INT {0} \
   CONFIG.PSU__IRQ_P2F_R5_CORE1_ECC_ERR__INT {0} \
   CONFIG.PSU__IRQ_P2F_RPU_IPI__INT {0} \
   CONFIG.PSU__IRQ_P2F_RPU_PERMON__INT {0} \
   CONFIG.PSU__IRQ_P2F_RTC_ALARM__INT {0} \
   CONFIG.PSU__IRQ_P2F_RTC_SECONDS__INT {0} \
   CONFIG.PSU__IRQ_P2F_SATA__INT {0} \
   CONFIG.PSU__IRQ_P2F_SDIO0_WAKE__INT {0} \
   CONFIG.PSU__IRQ_P2F_SDIO0__INT {0} \
   CONFIG.PSU__IRQ_P2F_SDIO1_WAKE__INT {0} \
   CONFIG.PSU__IRQ_P2F_SDIO1__INT {0} \
   CONFIG.PSU__IRQ_P2F_SPI0__INT {0} \
   CONFIG.PSU__IRQ_P2F_SPI1__INT {0} \
   CONFIG.PSU__IRQ_P2F_TTC0__INT0 {0} \
   CONFIG.PSU__IRQ_P2F_TTC0__INT1 {0} \
   CONFIG.PSU__IRQ_P2F_TTC0__INT2 {0} \
   CONFIG.PSU__IRQ_P2F_TTC1__INT0 {0} \
   CONFIG.PSU__IRQ_P2F_TTC1__INT1 {0} \
   CONFIG.PSU__IRQ_P2F_TTC1__INT2 {0} \
   CONFIG.PSU__IRQ_P2F_TTC2__INT0 {0} \
   CONFIG.PSU__IRQ_P2F_TTC2__INT1 {0} \
   CONFIG.PSU__IRQ_P2F_TTC2__INT2 {0} \
   CONFIG.PSU__IRQ_P2F_TTC3__INT0 {0} \
   CONFIG.PSU__IRQ_P2F_TTC3__INT1 {0} \
   CONFIG.PSU__IRQ_P2F_TTC3__INT2 {0} \
   CONFIG.PSU__IRQ_P2F_UART0__INT {0} \
   CONFIG.PSU__IRQ_P2F_UART1__INT {0} \
   CONFIG.PSU__IRQ_P2F_USB3_ENDPOINT__INT0 {0} \
   CONFIG.PSU__IRQ_P2F_USB3_ENDPOINT__INT1 {0} \
   CONFIG.PSU__IRQ_P2F_USB3_OTG__INT0 {0} \
   CONFIG.PSU__IRQ_P2F_USB3_OTG__INT1 {0} \
   CONFIG.PSU__IRQ_P2F_USB3_PMU_WAKEUP__INT {0} \
   CONFIG.PSU__IRQ_P2F_XMPU_FPD__INT {0} \
   CONFIG.PSU__IRQ_P2F_XMPU_LPD__INT {0} \
   CONFIG.PSU__IRQ_P2F__INTF_FPD_SMMU__INT {0} \
   CONFIG.PSU__IRQ_P2F__INTF_PPD_CCI__INT {0} \
   CONFIG.PSU__L2_BANK0__POWER__ON {1} \
   CONFIG.PSU__LPDMA0_COHERENCY {0} \
   CONFIG.PSU__LPDMA1_COHERENCY {0} \
   CONFIG.PSU__LPDMA2_COHERENCY {0} \
   CONFIG.PSU__LPDMA3_COHERENCY {0} \
   CONFIG.PSU__LPDMA4_COHERENCY {0} \
   CONFIG.PSU__LPDMA5_COHERENCY {0} \
   CONFIG.PSU__LPDMA6_COHERENCY {0} \
   CONFIG.PSU__LPDMA7_COHERENCY {0} \
   CONFIG.PSU__LPD_SLCR__CSUPMU_WDT_CLK_SEL__SELECT {APB} \
   CONFIG.PSU__LPD_SLCR__CSUPMU__ACT_FREQMHZ {100.000000} \
   CONFIG.PSU__LPD_SLCR__CSUPMU__FREQMHZ {100.000000} \
   CONFIG.PSU__MAXIGP0__DATA_WIDTH {128} \
   CONFIG.PSU__MAXIGP1__DATA_WIDTH {128} \
   CONFIG.PSU__MAXIGP2__DATA_WIDTH {32} \
   CONFIG.PSU__M_AXI_GP0_SUPPORTS_NARROW_BURST {1} \
   CONFIG.PSU__M_AXI_GP1_SUPPORTS_NARROW_BURST {1} \
   CONFIG.PSU__M_AXI_GP2_SUPPORTS_NARROW_BURST {1} \
   CONFIG.PSU__NAND_COHERENCY {0} \
   CONFIG.PSU__NAND_ROUTE_THROUGH_FPD {0} \
   CONFIG.PSU__NAND__CHIP_ENABLE__ENABLE {0} \
   CONFIG.PSU__NAND__DATA_STROBE__ENABLE {0} \
   CONFIG.PSU__NAND__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__NAND__READY0_BUSY__ENABLE {0} \
   CONFIG.PSU__NAND__READY1_BUSY__ENABLE {0} \
   CONFIG.PSU__NAND__READY_BUSY__ENABLE {0} \
   CONFIG.PSU__NUM_FABRIC_RESETS {1} \
   CONFIG.PSU__OCM_BANK0__POWER__ON {1} \
   CONFIG.PSU__OCM_BANK1__POWER__ON {1} \
   CONFIG.PSU__OCM_BANK2__POWER__ON {1} \
   CONFIG.PSU__OCM_BANK3__POWER__ON {1} \
   CONFIG.PSU__OVERRIDE_HPX_QOS {0} \
   CONFIG.PSU__OVERRIDE__BASIC_CLOCK {0} \
   CONFIG.PSU__PCIE__ACS_VIOLAION {0} \
   CONFIG.PSU__PCIE__ACS_VIOLATION {0} \
   CONFIG.PSU__PCIE__AER_CAPABILITY {0} \
   CONFIG.PSU__PCIE__ATOMICOP_EGRESS_BLOCKED {0} \
   CONFIG.PSU__PCIE__BAR0_64BIT {0} \
   CONFIG.PSU__PCIE__BAR0_ENABLE {0} \
   CONFIG.PSU__PCIE__BAR0_PREFETCHABLE {0} \
   CONFIG.PSU__PCIE__BAR0_VAL {} \
   CONFIG.PSU__PCIE__BAR1_64BIT {0} \
   CONFIG.PSU__PCIE__BAR1_ENABLE {0} \
   CONFIG.PSU__PCIE__BAR1_PREFETCHABLE {0} \
   CONFIG.PSU__PCIE__BAR1_VAL {} \
   CONFIG.PSU__PCIE__BAR2_64BIT {0} \
   CONFIG.PSU__PCIE__BAR2_ENABLE {0} \
   CONFIG.PSU__PCIE__BAR2_PREFETCHABLE {0} \
   CONFIG.PSU__PCIE__BAR2_VAL {} \
   CONFIG.PSU__PCIE__BAR3_64BIT {0} \
   CONFIG.PSU__PCIE__BAR3_ENABLE {0} \
   CONFIG.PSU__PCIE__BAR3_PREFETCHABLE {0} \
   CONFIG.PSU__PCIE__BAR3_VAL {} \
   CONFIG.PSU__PCIE__BAR4_64BIT {0} \
   CONFIG.PSU__PCIE__BAR4_ENABLE {0} \
   CONFIG.PSU__PCIE__BAR4_PREFETCHABLE {0} \
   CONFIG.PSU__PCIE__BAR4_VAL {} \
   CONFIG.PSU__PCIE__BAR5_64BIT {0} \
   CONFIG.PSU__PCIE__BAR5_ENABLE {0} \
   CONFIG.PSU__PCIE__BAR5_PREFETCHABLE {0} \
   CONFIG.PSU__PCIE__BAR5_VAL {} \
   CONFIG.PSU__PCIE__CLASS_CODE_BASE {0x06} \
   CONFIG.PSU__PCIE__CLASS_CODE_INTERFACE {0x0} \
   CONFIG.PSU__PCIE__CLASS_CODE_SUB {0x4} \
   CONFIG.PSU__PCIE__CLASS_CODE_VALUE {} \
   CONFIG.PSU__PCIE__COMPLETER_ABORT {0} \
   CONFIG.PSU__PCIE__COMPLTION_TIMEOUT {0} \
   CONFIG.PSU__PCIE__CORRECTABLE_INT_ERR {0} \
   CONFIG.PSU__PCIE__CRS_SW_VISIBILITY {0} \
   CONFIG.PSU__PCIE__DEVICE_ID {0xD021} \
   CONFIG.PSU__PCIE__DEVICE_PORT_TYPE {<Select>} \
   CONFIG.PSU__PCIE__ECRC_CHECK {0} \
   CONFIG.PSU__PCIE__ECRC_ERR {0} \
   CONFIG.PSU__PCIE__ECRC_GEN {0} \
   CONFIG.PSU__PCIE__EROM_ENABLE {0} \
   CONFIG.PSU__PCIE__EROM_VAL {} \
   CONFIG.PSU__PCIE__FLOW_CONTROL_ERR {0} \
   CONFIG.PSU__PCIE__FLOW_CONTROL_PROTOCOL_ERR {0} \
   CONFIG.PSU__PCIE__HEADER_LOG_OVERFLOW {0} \
   CONFIG.PSU__PCIE__INTX_GENERATION {0} \
   CONFIG.PSU__PCIE__LANE0__ENABLE {0} \
   CONFIG.PSU__PCIE__LANE0__IO {<Select>} \
   CONFIG.PSU__PCIE__LANE1__ENABLE {0} \
   CONFIG.PSU__PCIE__LANE2__ENABLE {0} \
   CONFIG.PSU__PCIE__LANE3__ENABLE {0} \
   CONFIG.PSU__PCIE__LINK_SPEED {<Select>} \
   CONFIG.PSU__PCIE__MAXIMUM_LINK_WIDTH {<Select>} \
   CONFIG.PSU__PCIE__MAX_PAYLOAD_SIZE {<Select>} \
   CONFIG.PSU__PCIE__MC_BLOCKED_TLP {0} \
   CONFIG.PSU__PCIE__MSIX_BAR_INDICATOR {} \
   CONFIG.PSU__PCIE__MSIX_CAPABILITY {0} \
   CONFIG.PSU__PCIE__MSIX_PBA_BAR_INDICATOR {} \
   CONFIG.PSU__PCIE__MSIX_PBA_OFFSET {0} \
   CONFIG.PSU__PCIE__MSIX_TABLE_OFFSET {0} \
   CONFIG.PSU__PCIE__MSIX_TABLE_SIZE {0} \
   CONFIG.PSU__PCIE__MSI_64BIT_ADDR_CAPABLE {0} \
   CONFIG.PSU__PCIE__MSI_CAPABILITY {0} \
   CONFIG.PSU__PCIE__MULTIHEADER {0} \
   CONFIG.PSU__PCIE__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__PCIE__PERIPHERAL__ENDPOINT_ENABLE {1} \
   CONFIG.PSU__PCIE__PERIPHERAL__ROOTPORT_ENABLE {0} \
   CONFIG.PSU__PCIE__PERIPHERAL__ROOTPORT_IO {<Select>} \
   CONFIG.PSU__PCIE__PERM_ROOT_ERR_UPDATE {0} \
   CONFIG.PSU__PCIE__RECEIVER_ERR {0} \
   CONFIG.PSU__PCIE__RECEIVER_OVERFLOW {0} \
   CONFIG.PSU__PCIE__REF_CLK_FREQ {<Select>} \
   CONFIG.PSU__PCIE__REF_CLK_SEL {<Select>} \
   CONFIG.PSU__PCIE__RESET__POLARITY {Active Low} \
   CONFIG.PSU__PCIE__REVISION_ID {0x0} \
   CONFIG.PSU__PCIE__SUBSYSTEM_ID {0x7} \
   CONFIG.PSU__PCIE__SUBSYSTEM_VENDOR_ID {0x10EE} \
   CONFIG.PSU__PCIE__SURPRISE_DOWN {0} \
   CONFIG.PSU__PCIE__TLP_PREFIX_BLOCKED {0} \
   CONFIG.PSU__PCIE__UNCORRECTABL_INT_ERR {0} \
   CONFIG.PSU__PCIE__VENDOR_ID {0x10EE} \
   CONFIG.PSU__PJTAG__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__PL_CLK0_BUF {TRUE} \
   CONFIG.PSU__PL_CLK1_BUF {TRUE} \
   CONFIG.PSU__PL_CLK2_BUF {TRUE} \
   CONFIG.PSU__PL_CLK3_BUF {FALSE} \
   CONFIG.PSU__PL__POWER__ON {1} \
   CONFIG.PSU__PMU_COHERENCY {0} \
   CONFIG.PSU__PMU__AIBACK__ENABLE {0} \
   CONFIG.PSU__PMU__EMIO_GPI__ENABLE {0} \
   CONFIG.PSU__PMU__EMIO_GPO__ENABLE {0} \
   CONFIG.PSU__PMU__GPI0__ENABLE {0} \
   CONFIG.PSU__PMU__GPI1__ENABLE {0} \
   CONFIG.PSU__PMU__GPI2__ENABLE {0} \
   CONFIG.PSU__PMU__GPI3__ENABLE {0} \
   CONFIG.PSU__PMU__GPI4__ENABLE {0} \
   CONFIG.PSU__PMU__GPI5__ENABLE {0} \
   CONFIG.PSU__PMU__GPO0__ENABLE {0} \
   CONFIG.PSU__PMU__GPO0__IO {<Select>} \
   CONFIG.PSU__PMU__GPO1__ENABLE {0} \
   CONFIG.PSU__PMU__GPO1__IO {<Select>} \
   CONFIG.PSU__PMU__GPO2__ENABLE {0} \
   CONFIG.PSU__PMU__GPO2__IO {<Select>} \
   CONFIG.PSU__PMU__GPO2__POLARITY {high} \
   CONFIG.PSU__PMU__GPO3__ENABLE {0} \
   CONFIG.PSU__PMU__GPO3__IO {<Select>} \
   CONFIG.PSU__PMU__GPO3__POLARITY {low} \
   CONFIG.PSU__PMU__GPO4__ENABLE {0} \
   CONFIG.PSU__PMU__GPO4__IO {<Select>} \
   CONFIG.PSU__PMU__GPO4__POLARITY {low} \
   CONFIG.PSU__PMU__GPO5__ENABLE {0} \
   CONFIG.PSU__PMU__GPO5__IO {<Select>} \
   CONFIG.PSU__PMU__GPO5__POLARITY {low} \
   CONFIG.PSU__PMU__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__PMU__PLERROR__ENABLE {0} \
   CONFIG.PSU__PRESET_APPLIED {1} \
   CONFIG.PSU__PROTECTION__DDR_SEGMENTS {NONE} \
   CONFIG.PSU__PROTECTION__DEBUG {0} \
   CONFIG.PSU__PROTECTION__ENABLE {0} \
   CONFIG.PSU__PROTECTION__FPD_SEGMENTS {\
SA:0xFD1A0000; SIZE:1280; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write;\
subsystemId:PMU Firmware |  SA:0xFD000000; SIZE:64; UNIT:KB; RegionTZ:Secure;\
WrAllowed:Read/Write; subsystemId:PMU Firmware |  SA:0xFD010000; SIZE:64;\
UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware | \
SA:0xFD020000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write;\
subsystemId:PMU Firmware |  SA:0xFD030000; SIZE:64; UNIT:KB; RegionTZ:Secure;\
WrAllowed:Read/Write; subsystemId:PMU Firmware |  SA:0xFD040000; SIZE:64;\
UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware | \
SA:0xFD050000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write;\
subsystemId:PMU Firmware |  SA:0xFD610000; SIZE:512; UNIT:KB; RegionTZ:Secure;\
WrAllowed:Read/Write; subsystemId:PMU Firmware |  SA:0xFD5D0000; SIZE:64;\
UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware |\
SA:0xFD1A0000 ; SIZE:1280; UNIT:KB; RegionTZ:Secure ; WrAllowed:Read/Write;\
subsystemId:Secure Subsystem} \
   CONFIG.PSU__PROTECTION__LOCK_UNUSED_SEGMENTS {0} \
   CONFIG.PSU__PROTECTION__LPD_SEGMENTS {\
SA:0xFF980000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write;\
subsystemId:PMU Firmware| SA:0xFF5E0000; SIZE:2560; UNIT:KB; RegionTZ:Secure;\
WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFFCC0000; SIZE:64;\
UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware|\
SA:0xFF180000; SIZE:768; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write;\
subsystemId:PMU Firmware| SA:0xFF410000; SIZE:640; UNIT:KB; RegionTZ:Secure;\
WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFFA70000; SIZE:64;\
UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware|\
SA:0xFF9A0000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write;\
subsystemId:PMU Firmware|SA:0xFF5E0000 ; SIZE:2560; UNIT:KB; RegionTZ:Secure ;\
WrAllowed:Read/Write; subsystemId:Secure Subsystem|SA:0xFFCC0000 ; SIZE:64;\
UNIT:KB; RegionTZ:Secure ; WrAllowed:Read/Write; subsystemId:Secure\
Subsystem|SA:0xFF180000 ; SIZE:768; UNIT:KB; RegionTZ:Secure ;\
WrAllowed:Read/Write; subsystemId:Secure Subsystem|SA:0xFF9A0000 ; SIZE:64;\
UNIT:KB; RegionTZ:Secure ; WrAllowed:Read/Write; subsystemId:Secure Subsystem} \
   CONFIG.PSU__PROTECTION__MASTERS {\
USB1:NonSecure;0|USB0:NonSecure;1|S_AXI_LPD:NA;0|S_AXI_HPC1_FPD:NA;0|S_AXI_HPC0_FPD:NA;0|S_AXI_HP3_FPD:NA;0|S_AXI_HP2_FPD:NA;1|S_AXI_HP1_FPD:NA;1|S_AXI_HP0_FPD:NA;1|S_AXI_ACP:NA;0|S_AXI_ACE:NA;0|SD1:NonSecure;1|SD0:NonSecure;1|SATA1:NonSecure;0|SATA0:NonSecure;0|RPU1:Secure;1|RPU0:Secure;1|QSPI:NonSecure;0|PMU:NA;1|PCIe:NonSecure;0|NAND:NonSecure;0|LDMA:NonSecure;1|GPU:NonSecure;1|GEM3:NonSecure;0|GEM2:NonSecure;0|GEM1:NonSecure;0|GEM0:NonSecure;1|FDMA:NonSecure;1|DP:NonSecure;0|DAP:NA;1|Coresight:NA;1|CSU:NA;1|APU:NA;1} \
   CONFIG.PSU__PROTECTION__MASTERS_TZ {\
GEM0:NonSecure|SD1:NonSecure|GEM2:NonSecure|GEM1:NonSecure|GEM3:NonSecure|PCIe:NonSecure|DP:NonSecure|NAND:NonSecure|GPU:NonSecure|USB1:NonSecure|USB0:NonSecure|LDMA:NonSecure|FDMA:NonSecure|QSPI:NonSecure|SD0:NonSecure} \
   CONFIG.PSU__PROTECTION__OCM_SEGMENTS {NONE} \
   CONFIG.PSU__PROTECTION__PRESUBSYSTEMS {NONE} \
   CONFIG.PSU__PROTECTION__SLAVES {\
LPD;USB3_1_XHCI;FE300000;FE3FFFFF;0|LPD;USB3_1;FF9E0000;FF9EFFFF;0|LPD;USB3_0_XHCI;FE200000;FE2FFFFF;1|LPD;USB3_0;FF9D0000;FF9DFFFF;1|LPD;UART1;FF010000;FF01FFFF;1|LPD;UART0;FF000000;FF00FFFF;1|LPD;TTC3;FF140000;FF14FFFF;1|LPD;TTC2;FF130000;FF13FFFF;1|LPD;TTC1;FF120000;FF12FFFF;1|LPD;TTC0;FF110000;FF11FFFF;1|FPD;SWDT1;FD4D0000;FD4DFFFF;1|LPD;SWDT0;FF150000;FF15FFFF;1|LPD;SPI1;FF050000;FF05FFFF;1|LPD;SPI0;FF040000;FF04FFFF;1|FPD;SMMU_REG;FD5F0000;FD5FFFFF;1|FPD;SMMU;FD800000;FDFFFFFF;1|FPD;SIOU;FD3D0000;FD3DFFFF;1|FPD;SERDES;FD400000;FD47FFFF;1|LPD;SD1;FF170000;FF17FFFF;1|LPD;SD0;FF160000;FF16FFFF;1|FPD;SATA;FD0C0000;FD0CFFFF;0|LPD;RTC;FFA60000;FFA6FFFF;1|LPD;RSA_CORE;FFCE0000;FFCEFFFF;1|LPD;RPU;FF9A0000;FF9AFFFF;1|LPD;R5_TCM_RAM_GLOBAL;FFE00000;FFE3FFFF;1|LPD;R5_1_Instruction_Cache;FFEC0000;FFECFFFF;1|LPD;R5_1_Data_Cache;FFED0000;FFEDFFFF;1|LPD;R5_1_BTCM_GLOBAL;FFEB0000;FFEBFFFF;1|LPD;R5_1_ATCM_GLOBAL;FFE90000;FFE9FFFF;1|LPD;R5_0_Instruction_Cache;FFE40000;FFE4FFFF;1|LPD;R5_0_Data_Cache;FFE50000;FFE5FFFF;1|LPD;R5_0_BTCM_GLOBAL;FFE20000;FFE2FFFF;1|LPD;R5_0_ATCM_GLOBAL;FFE00000;FFE0FFFF;1|LPD;QSPI_Linear_Address;C0000000;DFFFFFFF;1|LPD;QSPI;FF0F0000;FF0FFFFF;0|LPD;PMU_RAM;FFDC0000;FFDDFFFF;1|LPD;PMU_GLOBAL;FFD80000;FFDBFFFF;1|FPD;PCIE_MAIN;FD0E0000;FD0EFFFF;0|FPD;PCIE_LOW;E0000000;EFFFFFFF;0|FPD;PCIE_HIGH2;8000000000;BFFFFFFFFF;0|FPD;PCIE_HIGH1;600000000;7FFFFFFFF;0|FPD;PCIE_DMA;FD0F0000;FD0FFFFF;0|FPD;PCIE_ATTRIB;FD480000;FD48FFFF;0|LPD;OCM_XMPU_CFG;FFA70000;FFA7FFFF;1|LPD;OCM_SLCR;FF960000;FF96FFFF;1|OCM;OCM;FFFC0000;FFFFFFFF;1|LPD;NAND;FF100000;FF10FFFF;0|LPD;MBISTJTAG;FFCF0000;FFCFFFFF;1|LPD;LPD_XPPU_SINK;FF9C0000;FF9CFFFF;1|LPD;LPD_XPPU;FF980000;FF98FFFF;1|LPD;LPD_SLCR_SECURE;FF4B0000;FF4DFFFF;1|LPD;LPD_SLCR;FF410000;FF4AFFFF;1|LPD;LPD_GPV;FE100000;FE1FFFFF;1|LPD;LPD_DMA_7;FFAF0000;FFAFFFFF;1|LPD;LPD_DMA_6;FFAE0000;FFAEFFFF;1|LPD;LPD_DMA_5;FFAD0000;FFADFFFF;1|LPD;LPD_DMA_4;FFAC0000;FFACFFFF;1|LPD;LPD_DMA_3;FFAB0000;FFABFFFF;1|LPD;LPD_DMA_2;FFAA0000;FFAAFFFF;1|LPD;LPD_DMA_1;FFA90000;FFA9FFFF;1|LPD;LPD_DMA_0;FFA80000;FFA8FFFF;1|LPD;IPI_CTRL;FF380000;FF3FFFFF;1|LPD;IOU_SLCR;FF180000;FF23FFFF;1|LPD;IOU_SECURE_SLCR;FF240000;FF24FFFF;1|LPD;IOU_SCNTRS;FF260000;FF26FFFF;1|LPD;IOU_SCNTR;FF250000;FF25FFFF;1|LPD;IOU_GPV;FE000000;FE0FFFFF;1|LPD;I2C1;FF030000;FF03FFFF;0|LPD;I2C0;FF020000;FF02FFFF;1|FPD;GPU;FD4B0000;FD4BFFFF;1|LPD;GPIO;FF0A0000;FF0AFFFF;1|LPD;GEM3;FF0E0000;FF0EFFFF;0|LPD;GEM2;FF0D0000;FF0DFFFF;0|LPD;GEM1;FF0C0000;FF0CFFFF;0|LPD;GEM0;FF0B0000;FF0BFFFF;1|FPD;FPD_XMPU_SINK;FD4F0000;FD4FFFFF;1|FPD;FPD_XMPU_CFG;FD5D0000;FD5DFFFF;1|FPD;FPD_SLCR_SECURE;FD690000;FD6CFFFF;1|FPD;FPD_SLCR;FD610000;FD68FFFF;1|FPD;FPD_DMA_CH7;FD570000;FD57FFFF;1|FPD;FPD_DMA_CH6;FD560000;FD56FFFF;1|FPD;FPD_DMA_CH5;FD550000;FD55FFFF;1|FPD;FPD_DMA_CH4;FD540000;FD54FFFF;1|FPD;FPD_DMA_CH3;FD530000;FD53FFFF;1|FPD;FPD_DMA_CH2;FD520000;FD52FFFF;1|FPD;FPD_DMA_CH1;FD510000;FD51FFFF;1|FPD;FPD_DMA_CH0;FD500000;FD50FFFF;1|LPD;EFUSE;FFCC0000;FFCCFFFF;1|FPD;Display\
Port;FD4A0000;FD4AFFFF;0|FPD;DPDMA;FD4C0000;FD4CFFFF;0|FPD;DDR_XMPU5_CFG;FD050000;FD05FFFF;1|FPD;DDR_XMPU4_CFG;FD040000;FD04FFFF;1|FPD;DDR_XMPU3_CFG;FD030000;FD03FFFF;1|FPD;DDR_XMPU2_CFG;FD020000;FD02FFFF;1|FPD;DDR_XMPU1_CFG;FD010000;FD01FFFF;1|FPD;DDR_XMPU0_CFG;FD000000;FD00FFFF;1|FPD;DDR_QOS_CTRL;FD090000;FD09FFFF;1|FPD;DDR_PHY;FD080000;FD08FFFF;1|DDR;DDR_LOW;0;7FFFFFFF;1|DDR;DDR_HIGH;800000000;87FFFFFFF;1|FPD;DDDR_CTRL;FD070000;FD070FFF;1|LPD;Coresight;FE800000;FEFFFFFF;1|LPD;CSU_DMA;FFC80000;FFC9FFFF;1|LPD;CSU;FFCA0000;FFCAFFFF;1|LPD;CRL_APB;FF5E0000;FF85FFFF;1|FPD;CRF_APB;FD1A0000;FD2DFFFF;1|FPD;CCI_REG;FD5E0000;FD5EFFFF;1|LPD;CAN1;FF070000;FF07FFFF;0|LPD;CAN0;FF060000;FF06FFFF;1|FPD;APU;FD5C0000;FD5CFFFF;1|LPD;APM_INTC_IOU;FFA20000;FFA2FFFF;1|LPD;APM_FPD_LPD;FFA30000;FFA3FFFF;1|FPD;APM_5;FD490000;FD49FFFF;1|FPD;APM_0;FD0B0000;FD0BFFFF;1|LPD;APM2;FFA10000;FFA1FFFF;1|LPD;APM1;FFA00000;FFA0FFFF;1|LPD;AMS;FFA50000;FFA5FFFF;1|FPD;AFI_5;FD3B0000;FD3BFFFF;1|FPD;AFI_4;FD3A0000;FD3AFFFF;1|FPD;AFI_3;FD390000;FD39FFFF;1|FPD;AFI_2;FD380000;FD38FFFF;1|FPD;AFI_1;FD370000;FD37FFFF;1|FPD;AFI_0;FD360000;FD36FFFF;1|LPD;AFIFM6;FF9B0000;FF9BFFFF;1|FPD;ACPU_GIC;F9010000;F907FFFF;1} \
   CONFIG.PSU__PROTECTION__SUBSYSTEMS {PMU Firmware:PMU|Secure Subsystem:} \
   CONFIG.PSU__PSS_ALT_REF_CLK__ENABLE {0} \
   CONFIG.PSU__PSS_ALT_REF_CLK__FREQMHZ {33.333} \
   CONFIG.PSU__PSS_REF_CLK__FREQMHZ {33.333333333} \
   CONFIG.PSU__QSPI_COHERENCY {0} \
   CONFIG.PSU__QSPI_ROUTE_THROUGH_FPD {0} \
   CONFIG.PSU__QSPI__GRP_FBCLK__ENABLE {0} \
   CONFIG.PSU__QSPI__GRP_FBCLK__IO {<Select>} \
   CONFIG.PSU__QSPI__PERIPHERAL__DATA_MODE {<Select>} \
   CONFIG.PSU__QSPI__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__QSPI__PERIPHERAL__IO {<Select>} \
   CONFIG.PSU__QSPI__PERIPHERAL__MODE {<Select>} \
   CONFIG.PSU__REPORT__DBGLOG {0} \
   CONFIG.PSU__RPU_COHERENCY {0} \
   CONFIG.PSU__RPU__POWER__ON {1} \
   CONFIG.PSU__SATA__LANE0__ENABLE {0} \
   CONFIG.PSU__SATA__LANE1__ENABLE {0} \
   CONFIG.PSU__SATA__LANE1__IO {<Select>} \
   CONFIG.PSU__SATA__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__SATA__REF_CLK_FREQ {<Select>} \
   CONFIG.PSU__SATA__REF_CLK_SEL {<Select>} \
   CONFIG.PSU__SAXIGP0__DATA_WIDTH {128} \
   CONFIG.PSU__SAXIGP1__DATA_WIDTH {128} \
   CONFIG.PSU__SAXIGP2__DATA_WIDTH {128} \
   CONFIG.PSU__SAXIGP3__DATA_WIDTH {128} \
   CONFIG.PSU__SAXIGP4__DATA_WIDTH {128} \
   CONFIG.PSU__SAXIGP5__DATA_WIDTH {128} \
   CONFIG.PSU__SAXIGP6__DATA_WIDTH {128} \
   CONFIG.PSU__SD0_COHERENCY {0} \
   CONFIG.PSU__SD0_ROUTE_THROUGH_FPD {0} \
   CONFIG.PSU__SD0__DATA_TRANSFER_MODE {8Bit} \
   CONFIG.PSU__SD0__GRP_CD__ENABLE {0} \
   CONFIG.PSU__SD0__GRP_POW__ENABLE {1} \
   CONFIG.PSU__SD0__GRP_POW__IO {MIO 23} \
   CONFIG.PSU__SD0__GRP_WP__ENABLE {0} \
   CONFIG.PSU__SD0__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__SD0__PERIPHERAL__IO {MIO 13 .. 22} \
   CONFIG.PSU__SD0__RESET__ENABLE {1} \
   CONFIG.PSU__SD0__SLOT_TYPE {eMMC} \
   CONFIG.PSU__SD1_COHERENCY {0} \
   CONFIG.PSU__SD1_ROUTE_THROUGH_FPD {0} \
   CONFIG.PSU__SD1__DATA_TRANSFER_MODE {4Bit} \
   CONFIG.PSU__SD1__GRP_CD__ENABLE {1} \
   CONFIG.PSU__SD1__GRP_CD__IO {MIO 45} \
   CONFIG.PSU__SD1__GRP_POW__ENABLE {0} \
   CONFIG.PSU__SD1__GRP_WP__ENABLE {1} \
   CONFIG.PSU__SD1__GRP_WP__IO {MIO 44} \
   CONFIG.PSU__SD1__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__SD1__PERIPHERAL__IO {MIO 46 .. 51} \
   CONFIG.PSU__SD1__RESET__ENABLE {0} \
   CONFIG.PSU__SD1__SLOT_TYPE {SD 2.0} \
   CONFIG.PSU__SPI0_LOOP_SPI1__ENABLE {0} \
   CONFIG.PSU__SPI0__GRP_SS0__ENABLE {1} \
   CONFIG.PSU__SPI0__GRP_SS0__IO {EMIO} \
   CONFIG.PSU__SPI0__GRP_SS1__ENABLE {1} \
   CONFIG.PSU__SPI0__GRP_SS1__IO {EMIO} \
   CONFIG.PSU__SPI0__GRP_SS2__ENABLE {1} \
   CONFIG.PSU__SPI0__GRP_SS2__IO {EMIO} \
   CONFIG.PSU__SPI0__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__SPI0__PERIPHERAL__IO {EMIO} \
   CONFIG.PSU__SPI1__GRP_SS0__ENABLE {1} \
   CONFIG.PSU__SPI1__GRP_SS0__IO {EMIO} \
   CONFIG.PSU__SPI1__GRP_SS1__ENABLE {1} \
   CONFIG.PSU__SPI1__GRP_SS1__IO {EMIO} \
   CONFIG.PSU__SPI1__GRP_SS2__ENABLE {1} \
   CONFIG.PSU__SPI1__GRP_SS2__IO {EMIO} \
   CONFIG.PSU__SPI1__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__SPI1__PERIPHERAL__IO {EMIO} \
   CONFIG.PSU__SWDT0__CLOCK__ENABLE {0} \
   CONFIG.PSU__SWDT0__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__SWDT0__PERIPHERAL__IO {NA} \
   CONFIG.PSU__SWDT0__RESET__ENABLE {0} \
   CONFIG.PSU__SWDT1__CLOCK__ENABLE {0} \
   CONFIG.PSU__SWDT1__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__SWDT1__PERIPHERAL__IO {NA} \
   CONFIG.PSU__SWDT1__RESET__ENABLE {0} \
   CONFIG.PSU__TCM0A__POWER__ON {1} \
   CONFIG.PSU__TCM0B__POWER__ON {1} \
   CONFIG.PSU__TCM1A__POWER__ON {1} \
   CONFIG.PSU__TCM1B__POWER__ON {1} \
   CONFIG.PSU__TESTSCAN__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__TRACE_PIPELINE_WIDTH {8} \
   CONFIG.PSU__TRACE__INTERNAL_WIDTH {32} \
   CONFIG.PSU__TRACE__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__TRISTATE__INVERTED {1} \
   CONFIG.PSU__TSU__BUFG_PORT_PAIR {0} \
   CONFIG.PSU__TTC0__CLOCK__ENABLE {0} \
   CONFIG.PSU__TTC0__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__TTC0__PERIPHERAL__IO {NA} \
   CONFIG.PSU__TTC0__WAVEOUT__ENABLE {0} \
   CONFIG.PSU__TTC1__CLOCK__ENABLE {0} \
   CONFIG.PSU__TTC1__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__TTC1__PERIPHERAL__IO {NA} \
   CONFIG.PSU__TTC1__WAVEOUT__ENABLE {0} \
   CONFIG.PSU__TTC2__CLOCK__ENABLE {0} \
   CONFIG.PSU__TTC2__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__TTC2__PERIPHERAL__IO {NA} \
   CONFIG.PSU__TTC2__WAVEOUT__ENABLE {0} \
   CONFIG.PSU__TTC3__CLOCK__ENABLE {0} \
   CONFIG.PSU__TTC3__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__TTC3__PERIPHERAL__IO {NA} \
   CONFIG.PSU__TTC3__WAVEOUT__ENABLE {0} \
   CONFIG.PSU__UART0_LOOP_UART1__ENABLE {0} \
   CONFIG.PSU__UART0__BAUD_RATE {115200} \
   CONFIG.PSU__UART0__MODEM__ENABLE {0} \
   CONFIG.PSU__UART0__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__UART0__PERIPHERAL__IO {MIO 6 .. 7} \
   CONFIG.PSU__UART1__BAUD_RATE {115200} \
   CONFIG.PSU__UART1__MODEM__ENABLE {0} \
   CONFIG.PSU__UART1__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__UART1__PERIPHERAL__IO {MIO 8 .. 9} \
   CONFIG.PSU__USB0_COHERENCY {0} \
   CONFIG.PSU__USB0__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__USB0__PERIPHERAL__IO {MIO 52 .. 63} \
   CONFIG.PSU__USB0__REF_CLK_FREQ {52} \
   CONFIG.PSU__USB0__REF_CLK_SEL {Ref Clk2} \
   CONFIG.PSU__USB0__RESET__ENABLE {1} \
   CONFIG.PSU__USB0__RESET__IO {MIO 42} \
   CONFIG.PSU__USB1_COHERENCY {0} \
   CONFIG.PSU__USB1__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__USB1__RESET__ENABLE {0} \
   CONFIG.PSU__USB2_0__EMIO__ENABLE {0} \
   CONFIG.PSU__USB2_1__EMIO__ENABLE {0} \
   CONFIG.PSU__USB3_0__EMIO__ENABLE {0} \
   CONFIG.PSU__USB3_0__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__USB3_0__PERIPHERAL__IO {GT Lane2} \
   CONFIG.PSU__USB3_1__EMIO__ENABLE {0} \
   CONFIG.PSU__USB3_1__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__USB__RESET__MODE {Shared MIO Pin} \
   CONFIG.PSU__USB__RESET__POLARITY {Active Low} \
   CONFIG.PSU__USE_DIFF_RW_CLK_GP0 {0} \
   CONFIG.PSU__USE_DIFF_RW_CLK_GP1 {0} \
   CONFIG.PSU__USE_DIFF_RW_CLK_GP2 {0} \
   CONFIG.PSU__USE_DIFF_RW_CLK_GP3 {0} \
   CONFIG.PSU__USE_DIFF_RW_CLK_GP4 {0} \
   CONFIG.PSU__USE_DIFF_RW_CLK_GP5 {0} \
   CONFIG.PSU__USE_DIFF_RW_CLK_GP6 {0} \
   CONFIG.PSU__USE__ADMA {0} \
   CONFIG.PSU__USE__APU_LEGACY_INTERRUPT {0} \
   CONFIG.PSU__USE__AUDIO {0} \
   CONFIG.PSU__USE__CLK {0} \
   CONFIG.PSU__USE__CLK0 {0} \
   CONFIG.PSU__USE__CLK1 {0} \
   CONFIG.PSU__USE__CLK2 {0} \
   CONFIG.PSU__USE__CLK3 {0} \
   CONFIG.PSU__USE__CROSS_TRIGGER {0} \
   CONFIG.PSU__USE__DDR_INTF_REQUESTED {0} \
   CONFIG.PSU__USE__DEBUG__TEST {0} \
   CONFIG.PSU__USE__EVENT_RPU {0} \
   CONFIG.PSU__USE__FABRIC__RST {1} \
   CONFIG.PSU__USE__FTM {0} \
   CONFIG.PSU__USE__GDMA {0} \
   CONFIG.PSU__USE__IRQ {0} \
   CONFIG.PSU__USE__IRQ0 {1} \
   CONFIG.PSU__USE__IRQ1 {1} \
   CONFIG.PSU__USE__M_AXI_GP0 {0} \
   CONFIG.PSU__USE__M_AXI_GP1 {0} \
   CONFIG.PSU__USE__M_AXI_GP2 {1} \
   CONFIG.PSU__USE__PROC_EVENT_BUS {0} \
   CONFIG.PSU__USE__RPU_LEGACY_INTERRUPT {0} \
   CONFIG.PSU__USE__RST0 {0} \
   CONFIG.PSU__USE__RST1 {0} \
   CONFIG.PSU__USE__RST2 {0} \
   CONFIG.PSU__USE__RST3 {0} \
   CONFIG.PSU__USE__RTC {0} \
   CONFIG.PSU__USE__STM {0} \
   CONFIG.PSU__USE__S_AXI_ACE {0} \
   CONFIG.PSU__USE__S_AXI_ACP {0} \
   CONFIG.PSU__USE__S_AXI_GP0 {0} \
   CONFIG.PSU__USE__S_AXI_GP1 {0} \
   CONFIG.PSU__USE__S_AXI_GP2 {1} \
   CONFIG.PSU__USE__S_AXI_GP3 {1} \
   CONFIG.PSU__USE__S_AXI_GP4 {1} \
   CONFIG.PSU__USE__S_AXI_GP5 {0} \
   CONFIG.PSU__USE__S_AXI_GP6 {0} \
   CONFIG.PSU__USE__USB3_0_HUB {0} \
   CONFIG.PSU__USE__USB3_1_HUB {0} \
   CONFIG.PSU__USE__VIDEO {0} \
   CONFIG.PSU__VIDEO_REF_CLK__ENABLE {0} \
   CONFIG.PSU__VIDEO_REF_CLK__FREQMHZ {33.333} \
   CONFIG.QSPI_BOARD_INTERFACE {custom} \
   CONFIG.SATA_BOARD_INTERFACE {custom} \
   CONFIG.SD0_BOARD_INTERFACE {custom} \
   CONFIG.SD1_BOARD_INTERFACE {custom} \
   CONFIG.SPI0_BOARD_INTERFACE {custom} \
   CONFIG.SPI1_BOARD_INTERFACE {custom} \
   CONFIG.SUBPRESET1 {Custom} \
   CONFIG.SUBPRESET2 {Custom} \
   CONFIG.SWDT0_BOARD_INTERFACE {custom} \
   CONFIG.SWDT1_BOARD_INTERFACE {custom} \
   CONFIG.TRACE_BOARD_INTERFACE {custom} \
   CONFIG.TTC0_BOARD_INTERFACE {custom} \
   CONFIG.TTC1_BOARD_INTERFACE {custom} \
   CONFIG.TTC2_BOARD_INTERFACE {custom} \
   CONFIG.TTC3_BOARD_INTERFACE {custom} \
   CONFIG.UART0_BOARD_INTERFACE {custom} \
   CONFIG.UART1_BOARD_INTERFACE {custom} \
   CONFIG.USB0_BOARD_INTERFACE {custom} \
   CONFIG.USB1_BOARD_INTERFACE {custom} \
 ] $sys_ps8

  # Create instance: sys_rstgen, and set properties
  set sys_rstgen [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 sys_rstgen ]
  set_property -dict [ list \
   CONFIG.C_EXT_RST_WIDTH {1} \
 ] $sys_rstgen

  # Create instance: tx_device_clk_rstgen, and set properties
  set tx_device_clk_rstgen [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 tx_device_clk_rstgen ]

  # Create instance: tx_mxfe_tpl_core
  create_hier_cell_tx_mxfe_tpl_core [current_bd_instance .] tx_mxfe_tpl_core

  # Create instance: upack_reset_sources, and set properties
  set upack_reset_sources [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 upack_reset_sources ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {2} \
 ] $upack_reset_sources

  # Create instance: upack_rst_logic, and set properties
  set upack_rst_logic [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_reduced_logic:2.0 upack_rst_logic ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {or} \
   CONFIG.C_SIZE {2} \
 ] $upack_rst_logic

  # Create instance: util_mxfe_cpack, and set properties
  set util_mxfe_cpack [ create_bd_cell -type ip -vlnv analog.com:user:util_cpack2:1.0 util_mxfe_cpack ]
  set_property -dict [ list \
   CONFIG.NUM_OF_CHANNELS {2} \
   CONFIG.SAMPLES_PER_CHANNEL {16} \
   CONFIG.SAMPLE_DATA_WIDTH {16} \
 ] $util_mxfe_cpack

  # Create instance: util_mxfe_upack, and set properties
  set util_mxfe_upack [ create_bd_cell -type ip -vlnv analog.com:user:util_upack2:1.0 util_mxfe_upack ]
  set_property -dict [ list \
   CONFIG.NUM_OF_CHANNELS {2} \
   CONFIG.SAMPLES_PER_CHANNEL {16} \
   CONFIG.SAMPLE_DATA_WIDTH {16} \
 ] $util_mxfe_upack

  # Create instance: util_mxfe_xcvr, and set properties
  set util_mxfe_xcvr [ create_bd_cell -type ip -vlnv analog.com:user:util_adxcvr:1.0 util_mxfe_xcvr ]
  set_property -dict [ list \
   CONFIG.CPLL_CFG0 {0x01FA} \
   CONFIG.CPLL_CFG1 {0x002B} \
   CONFIG.CPLL_CFG2 {0x0002} \
   CONFIG.CPLL_FBDIV {2} \
   CONFIG.CPLL_FBDIV_4_5 {5} \
   CONFIG.LINK_MODE {2} \
   CONFIG.PPF1_CFG {0x0400} \
   CONFIG.PREIQ_FREQ_BST {2} \
   CONFIG.QPLL_CFG0 {0x331c} \
   CONFIG.QPLL_CFG2 {0x0FC1} \
   CONFIG.QPLL_CFG2_G3 {0x0FC1} \
   CONFIG.QPLL_CFG4 {0x0003} \
   CONFIG.QPLL_FBDIV {"0001000010"} \
   CONFIG.QPLL_REFCLK_DIV {2} \
   CONFIG.RXCDR_CFG2 {0x01E9} \
   CONFIG.RXCDR_CFG3 {0x0023} \
   CONFIG.RXDFE_KH_CFG2 {0x281C} \
   CONFIG.RXDFE_KH_CFG3 {0x4120} \
   CONFIG.RX_CLK25_DIV {10} \
   CONFIG.RX_LANE_RATE {18.5625} \
   CONFIG.RX_NUM_OF_LANES {8} \
   CONFIG.RX_OUT_DIV {1} \
   CONFIG.RX_WIDEMODE_CDR {0x2} \
   CONFIG.RX_XMODE_SEL {0x0} \
   CONFIG.TXDRV_FREQBAND {1} \
   CONFIG.TXFE_CFG0 {0x03C2} \
   CONFIG.TXFE_CFG1 {0xAA00} \
   CONFIG.TXFE_CFG2 {0xAA00} \
   CONFIG.TXFE_CFG3 {0xAA00} \
   CONFIG.TXPI_CFG0 {0x0100} \
   CONFIG.TXPI_CFG1 {0x1000} \
   CONFIG.TXSWBST_EN {0} \
   CONFIG.TX_CLK25_DIV {10} \
   CONFIG.TX_LANE_RATE {18.5625} \
   CONFIG.TX_NUM_OF_LANES {8} \
 ] $util_mxfe_xcvr

  # Create interface connections
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M00_AXI [get_bd_intf_pins axi_cpu_interconnect/M00_AXI] [get_bd_intf_pins axi_sysid_0/s_axi]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M01_AXI [get_bd_intf_pins axi_cpu_interconnect/M01_AXI] [get_bd_intf_pins axi_mxfe_rx_xcvr/s_axi]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M02_AXI [get_bd_intf_pins axi_cpu_interconnect/M02_AXI] [get_bd_intf_pins axi_mxfe_tx_xcvr/s_axi]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M03_AXI [get_bd_intf_pins axi_cpu_interconnect/M03_AXI] [get_bd_intf_pins rx_mxfe_tpl_core/s_axi]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M04_AXI [get_bd_intf_pins axi_cpu_interconnect/M04_AXI] [get_bd_intf_pins tx_mxfe_tpl_core/s_axi]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M05_AXI [get_bd_intf_pins axi_cpu_interconnect/M05_AXI] [get_bd_intf_pins axi_mxfe_rx_jesd/s_axi]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M06_AXI [get_bd_intf_pins axi_cpu_interconnect/M06_AXI] [get_bd_intf_pins axi_mxfe_tx_jesd/s_axi]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M07_AXI [get_bd_intf_pins axi_cpu_interconnect/M07_AXI] [get_bd_intf_pins axi_mxfe_rx_dma/s_axi]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M08_AXI [get_bd_intf_pins axi_cpu_interconnect/M08_AXI] [get_bd_intf_pins axi_mxfe_tx_dma/s_axi]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M09_AXI [get_bd_intf_pins axi_cpu_interconnect/M09_AXI] [get_bd_intf_pins mxfe_tx_data_offload/s_axi]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M10_AXI [get_bd_intf_pins axi_cpu_interconnect/M10_AXI] [get_bd_intf_pins mxfe_rx_data_offload/s_axi]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M11_AXI [get_bd_intf_pins axi_cpu_interconnect/M11_AXI] [get_bd_intf_pins axi_slave_wishbone_c_0/S_AXI]
  connect_bd_intf_net -intf_net axi_hp0_interconnect_M00_AXI [get_bd_intf_pins axi_hp0_interconnect/M00_AXI] [get_bd_intf_pins sys_ps8/S_AXI_HP0_FPD]
  connect_bd_intf_net -intf_net axi_hp1_interconnect_M00_AXI [get_bd_intf_pins axi_hp1_interconnect/M00_AXI] [get_bd_intf_pins sys_ps8/S_AXI_HP1_FPD]
  connect_bd_intf_net -intf_net axi_hp2_interconnect_M00_AXI [get_bd_intf_pins axi_hp2_interconnect/M00_AXI] [get_bd_intf_pins sys_ps8/S_AXI_HP2_FPD]
  connect_bd_intf_net -intf_net axi_mxfe_rx_dma_m_dest_axi [get_bd_intf_pins axi_hp1_interconnect/S00_AXI] [get_bd_intf_pins axi_mxfe_rx_dma/m_dest_axi]
  connect_bd_intf_net -intf_net axi_mxfe_rx_xcvr_m_axi [get_bd_intf_pins axi_hp0_interconnect/S00_AXI] [get_bd_intf_pins axi_mxfe_rx_xcvr/m_axi]
  connect_bd_intf_net -intf_net axi_mxfe_rx_xcvr_up_ch_0 [get_bd_intf_pins axi_mxfe_rx_xcvr/up_ch_0] [get_bd_intf_pins util_mxfe_xcvr/up_rx_0]
  connect_bd_intf_net -intf_net axi_mxfe_rx_xcvr_up_ch_1 [get_bd_intf_pins axi_mxfe_rx_xcvr/up_ch_1] [get_bd_intf_pins util_mxfe_xcvr/up_rx_1]
  connect_bd_intf_net -intf_net axi_mxfe_rx_xcvr_up_ch_2 [get_bd_intf_pins axi_mxfe_rx_xcvr/up_ch_2] [get_bd_intf_pins util_mxfe_xcvr/up_rx_2]
  connect_bd_intf_net -intf_net axi_mxfe_rx_xcvr_up_ch_3 [get_bd_intf_pins axi_mxfe_rx_xcvr/up_ch_3] [get_bd_intf_pins util_mxfe_xcvr/up_rx_3]
  connect_bd_intf_net -intf_net axi_mxfe_rx_xcvr_up_ch_4 [get_bd_intf_pins axi_mxfe_rx_xcvr/up_ch_4] [get_bd_intf_pins util_mxfe_xcvr/up_rx_4]
  connect_bd_intf_net -intf_net axi_mxfe_rx_xcvr_up_ch_5 [get_bd_intf_pins axi_mxfe_rx_xcvr/up_ch_5] [get_bd_intf_pins util_mxfe_xcvr/up_rx_5]
  connect_bd_intf_net -intf_net axi_mxfe_rx_xcvr_up_ch_6 [get_bd_intf_pins axi_mxfe_rx_xcvr/up_ch_6] [get_bd_intf_pins util_mxfe_xcvr/up_rx_6]
  connect_bd_intf_net -intf_net axi_mxfe_rx_xcvr_up_ch_7 [get_bd_intf_pins axi_mxfe_rx_xcvr/up_ch_7] [get_bd_intf_pins util_mxfe_xcvr/up_rx_7]
  connect_bd_intf_net -intf_net axi_mxfe_rx_xcvr_up_cm_0 [get_bd_intf_pins axi_mxfe_rx_xcvr/up_cm_0] [get_bd_intf_pins util_mxfe_xcvr/up_cm_0]
  connect_bd_intf_net -intf_net axi_mxfe_rx_xcvr_up_cm_4 [get_bd_intf_pins axi_mxfe_rx_xcvr/up_cm_4] [get_bd_intf_pins util_mxfe_xcvr/up_cm_4]
  connect_bd_intf_net -intf_net axi_mxfe_rx_xcvr_up_es_0 [get_bd_intf_pins axi_mxfe_rx_xcvr/up_es_0] [get_bd_intf_pins util_mxfe_xcvr/up_es_0]
  connect_bd_intf_net -intf_net axi_mxfe_rx_xcvr_up_es_1 [get_bd_intf_pins axi_mxfe_rx_xcvr/up_es_1] [get_bd_intf_pins util_mxfe_xcvr/up_es_1]
  connect_bd_intf_net -intf_net axi_mxfe_rx_xcvr_up_es_2 [get_bd_intf_pins axi_mxfe_rx_xcvr/up_es_2] [get_bd_intf_pins util_mxfe_xcvr/up_es_2]
  connect_bd_intf_net -intf_net axi_mxfe_rx_xcvr_up_es_3 [get_bd_intf_pins axi_mxfe_rx_xcvr/up_es_3] [get_bd_intf_pins util_mxfe_xcvr/up_es_3]
  connect_bd_intf_net -intf_net axi_mxfe_rx_xcvr_up_es_4 [get_bd_intf_pins axi_mxfe_rx_xcvr/up_es_4] [get_bd_intf_pins util_mxfe_xcvr/up_es_4]
  connect_bd_intf_net -intf_net axi_mxfe_rx_xcvr_up_es_5 [get_bd_intf_pins axi_mxfe_rx_xcvr/up_es_5] [get_bd_intf_pins util_mxfe_xcvr/up_es_5]
  connect_bd_intf_net -intf_net axi_mxfe_rx_xcvr_up_es_6 [get_bd_intf_pins axi_mxfe_rx_xcvr/up_es_6] [get_bd_intf_pins util_mxfe_xcvr/up_es_6]
  connect_bd_intf_net -intf_net axi_mxfe_rx_xcvr_up_es_7 [get_bd_intf_pins axi_mxfe_rx_xcvr/up_es_7] [get_bd_intf_pins util_mxfe_xcvr/up_es_7]
  connect_bd_intf_net -intf_net axi_mxfe_tx_dma_m_src_axi [get_bd_intf_pins axi_hp2_interconnect/S00_AXI] [get_bd_intf_pins axi_mxfe_tx_dma/m_src_axi]
  connect_bd_intf_net -intf_net axi_mxfe_tx_jesd_tx_phy0 [get_bd_intf_pins axi_mxfe_tx_jesd/tx_phy0] [get_bd_intf_pins util_mxfe_xcvr/tx_0]
  connect_bd_intf_net -intf_net axi_mxfe_tx_jesd_tx_phy1 [get_bd_intf_pins axi_mxfe_tx_jesd/tx_phy1] [get_bd_intf_pins util_mxfe_xcvr/tx_1]
  connect_bd_intf_net -intf_net axi_mxfe_tx_jesd_tx_phy2 [get_bd_intf_pins axi_mxfe_tx_jesd/tx_phy2] [get_bd_intf_pins util_mxfe_xcvr/tx_2]
  connect_bd_intf_net -intf_net axi_mxfe_tx_jesd_tx_phy3 [get_bd_intf_pins axi_mxfe_tx_jesd/tx_phy3] [get_bd_intf_pins util_mxfe_xcvr/tx_3]
  connect_bd_intf_net -intf_net axi_mxfe_tx_jesd_tx_phy4 [get_bd_intf_pins axi_mxfe_tx_jesd/tx_phy4] [get_bd_intf_pins util_mxfe_xcvr/tx_4]
  connect_bd_intf_net -intf_net axi_mxfe_tx_jesd_tx_phy5 [get_bd_intf_pins axi_mxfe_tx_jesd/tx_phy5] [get_bd_intf_pins util_mxfe_xcvr/tx_5]
  connect_bd_intf_net -intf_net axi_mxfe_tx_jesd_tx_phy6 [get_bd_intf_pins axi_mxfe_tx_jesd/tx_phy6] [get_bd_intf_pins util_mxfe_xcvr/tx_6]
  connect_bd_intf_net -intf_net axi_mxfe_tx_jesd_tx_phy7 [get_bd_intf_pins axi_mxfe_tx_jesd/tx_phy7] [get_bd_intf_pins util_mxfe_xcvr/tx_7]
  connect_bd_intf_net -intf_net axi_mxfe_tx_xcvr_up_ch_0 [get_bd_intf_pins axi_mxfe_tx_xcvr/up_ch_0] [get_bd_intf_pins util_mxfe_xcvr/up_tx_0]
  connect_bd_intf_net -intf_net axi_mxfe_tx_xcvr_up_ch_1 [get_bd_intf_pins axi_mxfe_tx_xcvr/up_ch_1] [get_bd_intf_pins util_mxfe_xcvr/up_tx_1]
  connect_bd_intf_net -intf_net axi_mxfe_tx_xcvr_up_ch_2 [get_bd_intf_pins axi_mxfe_tx_xcvr/up_ch_2] [get_bd_intf_pins util_mxfe_xcvr/up_tx_2]
  connect_bd_intf_net -intf_net axi_mxfe_tx_xcvr_up_ch_3 [get_bd_intf_pins axi_mxfe_tx_xcvr/up_ch_3] [get_bd_intf_pins util_mxfe_xcvr/up_tx_3]
  connect_bd_intf_net -intf_net axi_mxfe_tx_xcvr_up_ch_4 [get_bd_intf_pins axi_mxfe_tx_xcvr/up_ch_4] [get_bd_intf_pins util_mxfe_xcvr/up_tx_4]
  connect_bd_intf_net -intf_net axi_mxfe_tx_xcvr_up_ch_5 [get_bd_intf_pins axi_mxfe_tx_xcvr/up_ch_5] [get_bd_intf_pins util_mxfe_xcvr/up_tx_5]
  connect_bd_intf_net -intf_net axi_mxfe_tx_xcvr_up_ch_6 [get_bd_intf_pins axi_mxfe_tx_xcvr/up_ch_6] [get_bd_intf_pins util_mxfe_xcvr/up_tx_6]
  connect_bd_intf_net -intf_net axi_mxfe_tx_xcvr_up_ch_7 [get_bd_intf_pins axi_mxfe_tx_xcvr/up_ch_7] [get_bd_intf_pins util_mxfe_xcvr/up_tx_7]
  connect_bd_intf_net -intf_net mxfe_rx_data_offload_m_axis [get_bd_intf_pins axi_mxfe_rx_dma/s_axis] [get_bd_intf_pins mxfe_rx_data_offload/m_axis]
  connect_bd_intf_net -intf_net mxfe_tx_data_offload_m_axis [get_bd_intf_pins mxfe_tx_data_offload/m_axis] [get_bd_intf_pins util_mxfe_upack/s_axis]
  connect_bd_intf_net -intf_net s_axis_1 [get_bd_intf_pins axi_mxfe_tx_dma/m_axis] [get_bd_intf_pins mxfe_tx_data_offload/s_axis]
  connect_bd_intf_net -intf_net sys_ps8_M_AXI_HPM0_LPD [get_bd_intf_pins axi_cpu_interconnect/S00_AXI] [get_bd_intf_pins sys_ps8/M_AXI_HPM0_LPD]
  connect_bd_intf_net -intf_net tx_mxfe_tpl_core_link [get_bd_intf_pins axi_mxfe_tx_jesd/tx_data] [get_bd_intf_pins tx_mxfe_tpl_core/link]
  connect_bd_intf_net -intf_net util_mxfe_xcvr_rx_0 [get_bd_intf_pins axi_mxfe_rx_jesd/rx_phy0] [get_bd_intf_pins util_mxfe_xcvr/rx_0]
  connect_bd_intf_net -intf_net util_mxfe_xcvr_rx_1 [get_bd_intf_pins axi_mxfe_rx_jesd/rx_phy1] [get_bd_intf_pins util_mxfe_xcvr/rx_1]
  connect_bd_intf_net -intf_net util_mxfe_xcvr_rx_2 [get_bd_intf_pins axi_mxfe_rx_jesd/rx_phy2] [get_bd_intf_pins util_mxfe_xcvr/rx_2]
  connect_bd_intf_net -intf_net util_mxfe_xcvr_rx_3 [get_bd_intf_pins axi_mxfe_rx_jesd/rx_phy3] [get_bd_intf_pins util_mxfe_xcvr/rx_3]
  connect_bd_intf_net -intf_net util_mxfe_xcvr_rx_4 [get_bd_intf_pins axi_mxfe_rx_jesd/rx_phy4] [get_bd_intf_pins util_mxfe_xcvr/rx_4]
  connect_bd_intf_net -intf_net util_mxfe_xcvr_rx_5 [get_bd_intf_pins axi_mxfe_rx_jesd/rx_phy5] [get_bd_intf_pins util_mxfe_xcvr/rx_5]
  connect_bd_intf_net -intf_net util_mxfe_xcvr_rx_6 [get_bd_intf_pins axi_mxfe_rx_jesd/rx_phy6] [get_bd_intf_pins util_mxfe_xcvr/rx_6]
  connect_bd_intf_net -intf_net util_mxfe_xcvr_rx_7 [get_bd_intf_pins axi_mxfe_rx_jesd/rx_phy7] [get_bd_intf_pins util_mxfe_xcvr/rx_7]

  # Create port connections
  connect_bd_net -net ACK_I_0_1 [get_bd_ports ACK_I] [get_bd_pins axi_slave_wishbone_c_0/ACK_I]
  connect_bd_net -net DAT_I_0_1 [get_bd_ports DAT_I] [get_bd_pins axi_slave_wishbone_c_0/DAT_I]
  connect_bd_net -net GND_1_dout [get_bd_pins GND_1/dout] [get_bd_pins mxfe_rx_data_offload/s_axis_tlast] [get_bd_pins mxfe_rx_data_offload/sync_ext] [get_bd_pins mxfe_tx_data_offload/sync_ext] [get_bd_pins sys_concat_intc_0/In0] [get_bd_pins sys_concat_intc_0/In1] [get_bd_pins sys_concat_intc_0/In2] [get_bd_pins sys_concat_intc_0/In3] [get_bd_pins sys_concat_intc_0/In4] [get_bd_pins sys_concat_intc_0/In5] [get_bd_pins sys_concat_intc_0/In6] [get_bd_pins sys_concat_intc_0/In7] [get_bd_pins sys_concat_intc_1/In0] [get_bd_pins sys_concat_intc_1/In1] [get_bd_pins sys_concat_intc_1/In6] [get_bd_pins sys_concat_intc_1/In7] [get_bd_pins sys_ps8/emio_spi0_s_i] [get_bd_pins sys_ps8/emio_spi0_sclk_i] [get_bd_pins sys_ps8/emio_spi1_s_i] [get_bd_pins sys_ps8/emio_spi1_sclk_i] [get_bd_pins tx_mxfe_tpl_core/dac_dunf]
  connect_bd_net -net VCC_1_dout [get_bd_pins VCC_1/dout] [get_bd_pins mxfe_rx_data_offload/s_axis_tkeep] [get_bd_pins sys_ps8/emio_spi0_ss_i_n] [get_bd_pins sys_ps8/emio_spi1_ss_i_n]
  connect_bd_net -net adc_dovf_1 [get_bd_pins rx_mxfe_tpl_core/adc_dovf] [get_bd_pins util_mxfe_cpack/fifo_wr_overflow]
  connect_bd_net -net axi_mxfe_rx_dma_irq [get_bd_pins axi_mxfe_rx_dma/irq] [get_bd_pins sys_concat_intc_1/In5]
  connect_bd_net -net axi_mxfe_rx_jesd_irq [get_bd_pins axi_mxfe_rx_jesd/irq] [get_bd_pins sys_concat_intc_1/In3]
  connect_bd_net -net axi_mxfe_rx_jesd_rx_data_tdata [get_bd_pins axi_mxfe_rx_jesd/rx_data_tdata] [get_bd_pins rx_mxfe_tpl_core/link_data]
  connect_bd_net -net axi_mxfe_rx_jesd_rx_data_tvalid [get_bd_pins axi_mxfe_rx_jesd/rx_data_tvalid] [get_bd_pins rx_mxfe_tpl_core/link_valid]
  connect_bd_net -net axi_mxfe_rx_jesd_rx_sof [get_bd_pins axi_mxfe_rx_jesd/rx_sof] [get_bd_pins rx_mxfe_tpl_core/link_sof]
  connect_bd_net -net axi_mxfe_rx_xcvr_up_pll_rst [get_bd_pins axi_mxfe_rx_xcvr/up_pll_rst] [get_bd_pins util_mxfe_xcvr/up_cpll_rst_0] [get_bd_pins util_mxfe_xcvr/up_cpll_rst_1] [get_bd_pins util_mxfe_xcvr/up_cpll_rst_2] [get_bd_pins util_mxfe_xcvr/up_cpll_rst_3] [get_bd_pins util_mxfe_xcvr/up_cpll_rst_4] [get_bd_pins util_mxfe_xcvr/up_cpll_rst_5] [get_bd_pins util_mxfe_xcvr/up_cpll_rst_6] [get_bd_pins util_mxfe_xcvr/up_cpll_rst_7]
  connect_bd_net -net axi_mxfe_tx_dma_irq [get_bd_pins axi_mxfe_tx_dma/irq] [get_bd_pins sys_concat_intc_1/In4]
  connect_bd_net -net axi_mxfe_tx_jesd_irq [get_bd_pins axi_mxfe_tx_jesd/irq] [get_bd_pins sys_concat_intc_1/In2]
  connect_bd_net -net axi_mxfe_tx_xcvr_up_pll_rst [get_bd_pins axi_mxfe_tx_xcvr/up_pll_rst] [get_bd_pins util_mxfe_xcvr/up_qpll_rst_0] [get_bd_pins util_mxfe_xcvr/up_qpll_rst_4]
  connect_bd_net -net axi_slave_wishbone_c_0_ADR_O [get_bd_ports ADR_O] [get_bd_pins axi_slave_wishbone_c_0/ADR_O]
  connect_bd_net -net axi_slave_wishbone_c_0_CYC_O [get_bd_ports CYC_O] [get_bd_pins axi_slave_wishbone_c_0/CYC_O]
  connect_bd_net -net axi_slave_wishbone_c_0_DAT_O [get_bd_ports DAT_O] [get_bd_pins axi_slave_wishbone_c_0/DAT_O]
  connect_bd_net -net axi_slave_wishbone_c_0_RST_O [get_bd_ports RST_O] [get_bd_pins axi_slave_wishbone_c_0/RST_O]
  connect_bd_net -net axi_slave_wishbone_c_0_SEL_O [get_bd_ports SEL_O] [get_bd_pins axi_slave_wishbone_c_0/SEL_O]
  connect_bd_net -net axi_slave_wishbone_c_0_STB_O [get_bd_ports STB_O] [get_bd_pins axi_slave_wishbone_c_0/STB_O]
  connect_bd_net -net axi_slave_wishbone_c_0_WE_O [get_bd_ports WE_O] [get_bd_pins axi_slave_wishbone_c_0/WE_O]
  connect_bd_net -net axi_sysid_0_rom_addr [get_bd_pins axi_sysid_0/rom_addr] [get_bd_pins rom_sys_0/rom_addr]
  connect_bd_net -net clk_wiz_0_clk300mhz [get_bd_ports clk300mhz] [get_bd_pins clk_wiz_0/clk300mhz]
  connect_bd_net -net clk_wiz_0_clkout90 [get_bd_ports axi_aclk90] [get_bd_pins clk_wiz_0/clkout90]
  connect_bd_net -net clk_wiz_0_clkout180 [get_bd_ports axi_aclk180] [get_bd_pins clk_wiz_0/clkout180]
  connect_bd_net -net clk_wiz_0_clkout270 [get_bd_ports axi_aclk270] [get_bd_pins clk_wiz_0/clkout270]
  connect_bd_net -net clk_wiz_0_locked [get_bd_pins clk_wiz_0/locked] [get_bd_pins sys_rstgen/dcm_locked]
  connect_bd_net -net cpack_reset_sources_dout [get_bd_pins cpack_reset_sources/dout] [get_bd_pins cpack_rst_logic/Op1]
  connect_bd_net -net cpack_rst_logic_Res [get_bd_pins cpack_rst_logic/Res] [get_bd_pins util_mxfe_cpack/reset]
  connect_bd_net -net ext_sync_in_1 [get_bd_ports ext_sync_in] [get_bd_pins rx_mxfe_tpl_core/ext_sync_in] [get_bd_pins tx_mxfe_tpl_core/ext_sync_in]
  connect_bd_net -net gpio_i_1 [get_bd_ports gpio_i] [get_bd_pins sys_ps8/emio_gpio_i]
  connect_bd_net -net init_req_1 [get_bd_pins axi_mxfe_tx_dma/m_axis_xfer_req] [get_bd_pins mxfe_tx_data_offload/init_req]
  connect_bd_net -net init_req_2 [get_bd_pins axi_mxfe_rx_dma/s_axis_xfer_req] [get_bd_pins mxfe_rx_data_offload/init_req]
  connect_bd_net -net manual_sync_or_Res [get_bd_pins manual_sync_or/Res] [get_bd_pins rx_mxfe_tpl_core/adc_sync_manual_req_in] [get_bd_pins tx_mxfe_tpl_core/dac_sync_manual_req_in]
  connect_bd_net -net mxfe_rx_data_offload_s_axis_tready [get_bd_pins mxfe_rx_data_offload/s_axis_tready] [get_bd_pins rx_do_rstout_logic/Op1]
  connect_bd_net -net ref_clk_q0_1 [get_bd_ports ref_clk_q0] [get_bd_pins util_mxfe_xcvr/cpll_ref_clk_0] [get_bd_pins util_mxfe_xcvr/cpll_ref_clk_1] [get_bd_pins util_mxfe_xcvr/cpll_ref_clk_2] [get_bd_pins util_mxfe_xcvr/cpll_ref_clk_3] [get_bd_pins util_mxfe_xcvr/qpll_ref_clk_0]
  connect_bd_net -net ref_clk_q1_1 [get_bd_ports ref_clk_q1] [get_bd_pins util_mxfe_xcvr/cpll_ref_clk_4] [get_bd_pins util_mxfe_xcvr/cpll_ref_clk_5] [get_bd_pins util_mxfe_xcvr/cpll_ref_clk_6] [get_bd_pins util_mxfe_xcvr/cpll_ref_clk_7] [get_bd_pins util_mxfe_xcvr/qpll_ref_clk_4]
  connect_bd_net -net rom_sys_0_rom_data [get_bd_pins axi_sysid_0/sys_rom_data] [get_bd_pins rom_sys_0/rom_data]
  connect_bd_net -net rx_data_0_n_1 [get_bd_ports rx_data_0_n] [get_bd_pins util_mxfe_xcvr/rx_0_n]
  connect_bd_net -net rx_data_0_p_1 [get_bd_ports rx_data_0_p] [get_bd_pins util_mxfe_xcvr/rx_0_p]
  connect_bd_net -net rx_data_1_n_1 [get_bd_ports rx_data_1_n] [get_bd_pins util_mxfe_xcvr/rx_1_n]
  connect_bd_net -net rx_data_1_p_1 [get_bd_ports rx_data_1_p] [get_bd_pins util_mxfe_xcvr/rx_1_p]
  connect_bd_net -net rx_data_2_n_1 [get_bd_ports rx_data_2_n] [get_bd_pins util_mxfe_xcvr/rx_2_n]
  connect_bd_net -net rx_data_2_p_1 [get_bd_ports rx_data_2_p] [get_bd_pins util_mxfe_xcvr/rx_2_p]
  connect_bd_net -net rx_data_3_n_1 [get_bd_ports rx_data_3_n] [get_bd_pins util_mxfe_xcvr/rx_3_n]
  connect_bd_net -net rx_data_3_p_1 [get_bd_ports rx_data_3_p] [get_bd_pins util_mxfe_xcvr/rx_3_p]
  connect_bd_net -net rx_data_4_n_1 [get_bd_ports rx_data_4_n] [get_bd_pins util_mxfe_xcvr/rx_4_n]
  connect_bd_net -net rx_data_4_p_1 [get_bd_ports rx_data_4_p] [get_bd_pins util_mxfe_xcvr/rx_4_p]
  connect_bd_net -net rx_data_5_n_1 [get_bd_ports rx_data_5_n] [get_bd_pins util_mxfe_xcvr/rx_5_n]
  connect_bd_net -net rx_data_5_p_1 [get_bd_ports rx_data_5_p] [get_bd_pins util_mxfe_xcvr/rx_5_p]
  connect_bd_net -net rx_data_6_n_1 [get_bd_ports rx_data_6_n] [get_bd_pins util_mxfe_xcvr/rx_6_n]
  connect_bd_net -net rx_data_6_p_1 [get_bd_ports rx_data_6_p] [get_bd_pins util_mxfe_xcvr/rx_6_p]
  connect_bd_net -net rx_data_7_n_1 [get_bd_ports rx_data_7_n] [get_bd_pins util_mxfe_xcvr/rx_7_n]
  connect_bd_net -net rx_data_7_p_1 [get_bd_ports rx_data_7_p] [get_bd_pins util_mxfe_xcvr/rx_7_p]
  connect_bd_net -net rx_device_clk_1 [get_bd_ports rx_device_clk] [get_bd_pins axi_mxfe_rx_jesd/device_clk] [get_bd_pins mxfe_rx_data_offload/s_axis_aclk] [get_bd_pins rx_device_clk_rstgen/slowest_sync_clk] [get_bd_pins rx_mxfe_tpl_core/link_clk] [get_bd_pins util_mxfe_cpack/clk]
  connect_bd_net -net rx_device_clk_rstgen_peripheral_aresetn [get_bd_pins mxfe_rx_data_offload/s_axis_aresetn] [get_bd_pins rx_device_clk_rstgen/peripheral_aresetn]
  connect_bd_net -net rx_device_clk_rstgen_peripheral_reset [get_bd_pins cpack_reset_sources/In0] [get_bd_pins rx_device_clk_rstgen/peripheral_reset]
  connect_bd_net -net rx_do_rstout_logic_Res [get_bd_pins cpack_reset_sources/In2] [get_bd_pins rx_do_rstout_logic/Res]
  connect_bd_net -net rx_mxfe_tpl_core_adc_data_0 [get_bd_pins rx_mxfe_tpl_core/adc_data_0] [get_bd_pins util_mxfe_cpack/fifo_wr_data_0]
  connect_bd_net -net rx_mxfe_tpl_core_adc_data_1 [get_bd_pins rx_mxfe_tpl_core/adc_data_1] [get_bd_pins util_mxfe_cpack/fifo_wr_data_1]
  connect_bd_net -net rx_mxfe_tpl_core_adc_enable_0 [get_bd_pins rx_mxfe_tpl_core/adc_enable_0] [get_bd_pins util_mxfe_cpack/enable_0]
  connect_bd_net -net rx_mxfe_tpl_core_adc_enable_1 [get_bd_pins rx_mxfe_tpl_core/adc_enable_1] [get_bd_pins util_mxfe_cpack/enable_1]
  connect_bd_net -net rx_mxfe_tpl_core_adc_rst [get_bd_pins cpack_reset_sources/In1] [get_bd_pins rx_mxfe_tpl_core/adc_rst]
  connect_bd_net -net rx_mxfe_tpl_core_adc_sync_manual_req_out [get_bd_pins manual_sync_or/Op1] [get_bd_pins rx_mxfe_tpl_core/adc_sync_manual_req_out]
  connect_bd_net -net rx_mxfe_tpl_core_adc_valid_0 [get_bd_pins rx_mxfe_tpl_core/adc_valid_0] [get_bd_pins util_mxfe_cpack/fifo_wr_en]
  connect_bd_net -net spi0_csn_concat_dout [get_bd_ports spi0_csn] [get_bd_pins spi0_csn_concat/dout]
  connect_bd_net -net spi0_miso_1 [get_bd_ports spi0_miso] [get_bd_pins sys_ps8/emio_spi0_m_i]
  connect_bd_net -net spi1_csn_concat_dout [get_bd_ports spi1_csn] [get_bd_pins spi1_csn_concat/dout]
  connect_bd_net -net spi1_miso_1 [get_bd_ports spi1_miso] [get_bd_pins sys_ps8/emio_spi1_m_i]
  connect_bd_net -net sys_250m_clk [get_bd_pins axi_hp1_interconnect/aclk1] [get_bd_pins axi_hp2_interconnect/aclk] [get_bd_pins axi_mxfe_rx_dma/m_dest_axi_aclk] [get_bd_pins axi_mxfe_rx_dma/s_axis_aclk] [get_bd_pins axi_mxfe_tx_dma/m_axis_aclk] [get_bd_pins axi_mxfe_tx_dma/m_src_axi_aclk] [get_bd_pins mxfe_rx_data_offload/m_axis_aclk] [get_bd_pins mxfe_tx_data_offload/s_axis_aclk] [get_bd_pins sys_250m_rstgen/slowest_sync_clk] [get_bd_pins sys_ps8/pl_clk1] [get_bd_pins sys_ps8/saxihp2_fpd_aclk]
  connect_bd_net -net sys_250m_reset [get_bd_pins sys_250m_rstgen/peripheral_reset]
  connect_bd_net -net sys_250m_resetn [get_bd_pins axi_hp2_interconnect/aresetn] [get_bd_pins axi_mxfe_rx_dma/m_dest_axi_aresetn] [get_bd_pins axi_mxfe_tx_dma/m_src_axi_aresetn] [get_bd_pins mxfe_rx_data_offload/m_axis_aresetn] [get_bd_pins mxfe_tx_data_offload/s_axis_aresetn] [get_bd_pins sys_250m_rstgen/peripheral_aresetn]
  connect_bd_net -net sys_concat_intc_0_dout [get_bd_pins sys_concat_intc_0/dout] [get_bd_pins sys_ps8/pl_ps_irq0]
  connect_bd_net -net sys_concat_intc_1_dout [get_bd_pins sys_concat_intc_1/dout] [get_bd_pins sys_ps8/pl_ps_irq1]
  connect_bd_net -net sys_cpu_clk [get_bd_ports axi_aclk] [get_bd_pins axi_cpu_interconnect/aclk] [get_bd_pins axi_hp0_interconnect/aclk] [get_bd_pins axi_hp1_interconnect/aclk] [get_bd_pins axi_mxfe_rx_dma/s_axi_aclk] [get_bd_pins axi_mxfe_rx_jesd/s_axi_aclk] [get_bd_pins axi_mxfe_rx_xcvr/s_axi_aclk] [get_bd_pins axi_mxfe_tx_dma/s_axi_aclk] [get_bd_pins axi_mxfe_tx_jesd/s_axi_aclk] [get_bd_pins axi_mxfe_tx_xcvr/s_axi_aclk] [get_bd_pins axi_slave_wishbone_c_0/S_AXI_ACLK] [get_bd_pins axi_sysid_0/s_axi_aclk] [get_bd_pins clk_wiz_0/clk_in1] [get_bd_pins mxfe_rx_data_offload/s_axi_aclk] [get_bd_pins mxfe_tx_data_offload/s_axi_aclk] [get_bd_pins rom_sys_0/clk] [get_bd_pins rx_mxfe_tpl_core/s_axi_aclk] [get_bd_pins sys_ps8/maxihpm0_lpd_aclk] [get_bd_pins sys_ps8/pl_clk0] [get_bd_pins sys_ps8/saxihp0_fpd_aclk] [get_bd_pins sys_ps8/saxihp1_fpd_aclk] [get_bd_pins sys_rstgen/slowest_sync_clk] [get_bd_pins tx_mxfe_tpl_core/s_axi_aclk] [get_bd_pins util_mxfe_xcvr/up_clk]
  connect_bd_net -net sys_cpu_reset [get_bd_pins sys_rstgen/peripheral_reset]
  connect_bd_net -net sys_cpu_resetn [get_bd_pins axi_cpu_interconnect/aresetn] [get_bd_pins axi_hp0_interconnect/aresetn] [get_bd_pins axi_hp1_interconnect/aresetn] [get_bd_pins axi_mxfe_rx_dma/s_axi_aresetn] [get_bd_pins axi_mxfe_rx_jesd/s_axi_aresetn] [get_bd_pins axi_mxfe_rx_xcvr/s_axi_aresetn] [get_bd_pins axi_mxfe_tx_dma/s_axi_aresetn] [get_bd_pins axi_mxfe_tx_jesd/s_axi_aresetn] [get_bd_pins axi_mxfe_tx_xcvr/s_axi_aresetn] [get_bd_pins axi_slave_wishbone_c_0/S_AXI_ARESETN] [get_bd_pins axi_sysid_0/s_axi_aresetn] [get_bd_pins mxfe_rx_data_offload/s_axi_aresetn] [get_bd_pins mxfe_tx_data_offload/s_axi_aresetn] [get_bd_pins rx_device_clk_rstgen/ext_reset_in] [get_bd_pins rx_mxfe_tpl_core/s_axi_aresetn] [get_bd_pins sys_rstgen/peripheral_aresetn] [get_bd_pins tx_device_clk_rstgen/ext_reset_in] [get_bd_pins tx_mxfe_tpl_core/s_axi_aresetn] [get_bd_pins util_mxfe_xcvr/up_rstn]
  connect_bd_net -net sys_ps8_emio_gpio_o [get_bd_ports gpio_o] [get_bd_pins sys_ps8/emio_gpio_o]
  connect_bd_net -net sys_ps8_emio_gpio_t [get_bd_ports gpio_t] [get_bd_pins sys_ps8/emio_gpio_t]
  connect_bd_net -net sys_ps8_emio_spi0_m_o [get_bd_ports spi0_mosi] [get_bd_pins sys_ps8/emio_spi0_m_o]
  connect_bd_net -net sys_ps8_emio_spi0_sclk_o [get_bd_ports spi0_sclk] [get_bd_pins sys_ps8/emio_spi0_sclk_o]
  connect_bd_net -net sys_ps8_emio_spi0_ss1_o_n [get_bd_pins spi0_csn_concat/In1] [get_bd_pins sys_ps8/emio_spi0_ss1_o_n]
  connect_bd_net -net sys_ps8_emio_spi0_ss2_o_n [get_bd_pins spi0_csn_concat/In2] [get_bd_pins sys_ps8/emio_spi0_ss2_o_n]
  connect_bd_net -net sys_ps8_emio_spi0_ss_o_n [get_bd_pins spi0_csn_concat/In0] [get_bd_pins sys_ps8/emio_spi0_ss_o_n]
  connect_bd_net -net sys_ps8_emio_spi1_m_o [get_bd_ports spi1_mosi] [get_bd_pins sys_ps8/emio_spi1_m_o]
  connect_bd_net -net sys_ps8_emio_spi1_sclk_o [get_bd_ports spi1_sclk] [get_bd_pins sys_ps8/emio_spi1_sclk_o]
  connect_bd_net -net sys_ps8_emio_spi1_ss1_o_n [get_bd_pins spi1_csn_concat/In1] [get_bd_pins sys_ps8/emio_spi1_ss1_o_n]
  connect_bd_net -net sys_ps8_emio_spi1_ss2_o_n [get_bd_pins spi1_csn_concat/In2] [get_bd_pins sys_ps8/emio_spi1_ss2_o_n]
  connect_bd_net -net sys_ps8_emio_spi1_ss_o_n [get_bd_pins spi1_csn_concat/In0] [get_bd_pins sys_ps8/emio_spi1_ss_o_n]
  connect_bd_net -net sys_ps8_pl_resetn0 [get_bd_pins sys_250m_rstgen/ext_reset_in] [get_bd_pins sys_ps8/pl_resetn0] [get_bd_pins sys_rstgen/ext_reset_in]
  connect_bd_net -net sysref_1 [get_bd_ports rx_sysref_0] [get_bd_pins axi_mxfe_rx_jesd/sysref]
  connect_bd_net -net sysref_2 [get_bd_ports tx_sysref_0] [get_bd_pins axi_mxfe_tx_jesd/sysref]
  connect_bd_net -net tx_device_clk_1 [get_bd_ports tx_device_clk] [get_bd_pins axi_mxfe_tx_jesd/device_clk] [get_bd_pins mxfe_tx_data_offload/m_axis_aclk] [get_bd_pins tx_device_clk_rstgen/slowest_sync_clk] [get_bd_pins tx_mxfe_tpl_core/link_clk] [get_bd_pins util_mxfe_upack/clk]
  connect_bd_net -net tx_device_clk_rstgen_peripheral_aresetn [get_bd_pins mxfe_tx_data_offload/m_axis_aresetn] [get_bd_pins tx_device_clk_rstgen/peripheral_aresetn]
  connect_bd_net -net tx_device_clk_rstgen_peripheral_reset [get_bd_pins tx_device_clk_rstgen/peripheral_reset] [get_bd_pins upack_reset_sources/In0]
  connect_bd_net -net tx_mxfe_tpl_core_dac_enable_0 [get_bd_pins tx_mxfe_tpl_core/dac_enable_0] [get_bd_pins util_mxfe_upack/enable_0]
  connect_bd_net -net tx_mxfe_tpl_core_dac_enable_1 [get_bd_pins tx_mxfe_tpl_core/dac_enable_1] [get_bd_pins util_mxfe_upack/enable_1]
  connect_bd_net -net tx_mxfe_tpl_core_dac_rst [get_bd_pins tx_mxfe_tpl_core/dac_rst] [get_bd_pins upack_reset_sources/In1]
  connect_bd_net -net tx_mxfe_tpl_core_dac_sync_manual_req_out [get_bd_pins manual_sync_or/Op2] [get_bd_pins tx_mxfe_tpl_core/dac_sync_manual_req_out]
  connect_bd_net -net tx_mxfe_tpl_core_dac_valid_0 [get_bd_pins tx_mxfe_tpl_core/dac_valid_0] [get_bd_pins util_mxfe_upack/fifo_rd_en]
  connect_bd_net -net upack_reset_sources_dout [get_bd_pins upack_reset_sources/dout] [get_bd_pins upack_rst_logic/Op1]
  connect_bd_net -net upack_rst_logic_Res [get_bd_pins upack_rst_logic/Res] [get_bd_pins util_mxfe_upack/reset]
  connect_bd_net -net util_mxfe_cpack_packed_fifo_wr_data [get_bd_pins mxfe_rx_data_offload/s_axis_tdata] [get_bd_pins util_mxfe_cpack/packed_fifo_wr_data]
  connect_bd_net -net util_mxfe_cpack_packed_fifo_wr_en [get_bd_pins mxfe_rx_data_offload/s_axis_tvalid] [get_bd_pins util_mxfe_cpack/packed_fifo_wr_en]
  connect_bd_net -net util_mxfe_upack_fifo_rd_data_0 [get_bd_pins tx_mxfe_tpl_core/dac_data_0] [get_bd_pins util_mxfe_upack/fifo_rd_data_0]
  connect_bd_net -net util_mxfe_upack_fifo_rd_data_1 [get_bd_pins tx_mxfe_tpl_core/dac_data_1] [get_bd_pins util_mxfe_upack/fifo_rd_data_1]
  connect_bd_net -net util_mxfe_xcvr_rx_out_clk_0 [get_bd_ports link_clk_out] [get_bd_pins axi_mxfe_rx_jesd/link_clk] [get_bd_pins util_mxfe_xcvr/rx_clk_0] [get_bd_pins util_mxfe_xcvr/rx_clk_1] [get_bd_pins util_mxfe_xcvr/rx_clk_2] [get_bd_pins util_mxfe_xcvr/rx_clk_3] [get_bd_pins util_mxfe_xcvr/rx_clk_4] [get_bd_pins util_mxfe_xcvr/rx_clk_5] [get_bd_pins util_mxfe_xcvr/rx_clk_6] [get_bd_pins util_mxfe_xcvr/rx_clk_7] [get_bd_pins util_mxfe_xcvr/rx_out_clk_0]
  connect_bd_net -net util_mxfe_xcvr_tx_0_n [get_bd_ports tx_data_0_n] [get_bd_pins util_mxfe_xcvr/tx_0_n]
  connect_bd_net -net util_mxfe_xcvr_tx_0_p [get_bd_ports tx_data_0_p] [get_bd_pins util_mxfe_xcvr/tx_0_p]
  connect_bd_net -net util_mxfe_xcvr_tx_1_n [get_bd_ports tx_data_1_n] [get_bd_pins util_mxfe_xcvr/tx_1_n]
  connect_bd_net -net util_mxfe_xcvr_tx_1_p [get_bd_ports tx_data_1_p] [get_bd_pins util_mxfe_xcvr/tx_1_p]
  connect_bd_net -net util_mxfe_xcvr_tx_2_n [get_bd_ports tx_data_2_n] [get_bd_pins util_mxfe_xcvr/tx_2_n]
  connect_bd_net -net util_mxfe_xcvr_tx_2_p [get_bd_ports tx_data_2_p] [get_bd_pins util_mxfe_xcvr/tx_2_p]
  connect_bd_net -net util_mxfe_xcvr_tx_3_n [get_bd_ports tx_data_3_n] [get_bd_pins util_mxfe_xcvr/tx_3_n]
  connect_bd_net -net util_mxfe_xcvr_tx_3_p [get_bd_ports tx_data_3_p] [get_bd_pins util_mxfe_xcvr/tx_3_p]
  connect_bd_net -net util_mxfe_xcvr_tx_4_n [get_bd_ports tx_data_4_n] [get_bd_pins util_mxfe_xcvr/tx_4_n]
  connect_bd_net -net util_mxfe_xcvr_tx_4_p [get_bd_ports tx_data_4_p] [get_bd_pins util_mxfe_xcvr/tx_4_p]
  connect_bd_net -net util_mxfe_xcvr_tx_5_n [get_bd_ports tx_data_5_n] [get_bd_pins util_mxfe_xcvr/tx_5_n]
  connect_bd_net -net util_mxfe_xcvr_tx_5_p [get_bd_ports tx_data_5_p] [get_bd_pins util_mxfe_xcvr/tx_5_p]
  connect_bd_net -net util_mxfe_xcvr_tx_6_n [get_bd_ports tx_data_6_n] [get_bd_pins util_mxfe_xcvr/tx_6_n]
  connect_bd_net -net util_mxfe_xcvr_tx_6_p [get_bd_ports tx_data_6_p] [get_bd_pins util_mxfe_xcvr/tx_6_p]
  connect_bd_net -net util_mxfe_xcvr_tx_7_n [get_bd_ports tx_data_7_n] [get_bd_pins util_mxfe_xcvr/tx_7_n]
  connect_bd_net -net util_mxfe_xcvr_tx_7_p [get_bd_ports tx_data_7_p] [get_bd_pins util_mxfe_xcvr/tx_7_p]
  connect_bd_net -net util_mxfe_xcvr_tx_out_clk_0 [get_bd_pins axi_mxfe_tx_jesd/link_clk] [get_bd_pins util_mxfe_xcvr/tx_clk_0] [get_bd_pins util_mxfe_xcvr/tx_clk_1] [get_bd_pins util_mxfe_xcvr/tx_clk_2] [get_bd_pins util_mxfe_xcvr/tx_clk_3] [get_bd_pins util_mxfe_xcvr/tx_clk_4] [get_bd_pins util_mxfe_xcvr/tx_clk_5] [get_bd_pins util_mxfe_xcvr/tx_clk_6] [get_bd_pins util_mxfe_xcvr/tx_clk_7] [get_bd_pins util_mxfe_xcvr/tx_out_clk_0]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces axi_mxfe_rx_dma/m_dest_axi] [get_bd_addr_segs sys_ps8/SAXIGP3/HP1_DDR_LOW] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces axi_mxfe_rx_xcvr/m_axi] [get_bd_addr_segs sys_ps8/SAXIGP2/HP0_DDR_LOW] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces axi_mxfe_tx_dma/m_src_axi] [get_bd_addr_segs sys_ps8/SAXIGP4/HP2_DDR_LOW] -force
  assign_bd_address -offset 0x84A10000 -range 0x00002000 -target_address_space [get_bd_addr_spaces sys_ps8/Data] [get_bd_addr_segs rx_mxfe_tpl_core/adc_tpl_core/s_axi/axi_lite] -force
  assign_bd_address -offset 0x9C420000 -range 0x00001000 -target_address_space [get_bd_addr_spaces sys_ps8/Data] [get_bd_addr_segs axi_mxfe_rx_dma/s_axi/axi_lite] -force
  assign_bd_address -offset 0x84A60000 -range 0x00010000 -target_address_space [get_bd_addr_spaces sys_ps8/Data] [get_bd_addr_segs axi_mxfe_rx_xcvr/s_axi/axi_lite] -force
  assign_bd_address -offset 0x9C430000 -range 0x00001000 -target_address_space [get_bd_addr_spaces sys_ps8/Data] [get_bd_addr_segs axi_mxfe_tx_dma/s_axi/axi_lite] -force
  assign_bd_address -offset 0x84B60000 -range 0x00010000 -target_address_space [get_bd_addr_spaces sys_ps8/Data] [get_bd_addr_segs axi_mxfe_tx_xcvr/s_axi/axi_lite] -force
  assign_bd_address -offset 0x88000000 -range 0x00100000 -target_address_space [get_bd_addr_spaces sys_ps8/Data] [get_bd_addr_segs axi_slave_wishbone_c_0/S_AXI/reg0] -force
  assign_bd_address -offset 0x85000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces sys_ps8/Data] [get_bd_addr_segs axi_sysid_0/s_axi/axi_lite] -force
  assign_bd_address -offset 0x84B10000 -range 0x00002000 -target_address_space [get_bd_addr_spaces sys_ps8/Data] [get_bd_addr_segs tx_mxfe_tpl_core/dac_tpl_core/s_axi/axi_lite] -force
  assign_bd_address -offset 0x9C450000 -range 0x00010000 -target_address_space [get_bd_addr_spaces sys_ps8/Data] [get_bd_addr_segs mxfe_rx_data_offload/i_data_offload/s_axi/axi_lite] -force
  assign_bd_address -offset 0x9C440000 -range 0x00010000 -target_address_space [get_bd_addr_spaces sys_ps8/Data] [get_bd_addr_segs mxfe_tx_data_offload/i_data_offload/s_axi/axi_lite] -force
  assign_bd_address -offset 0x84A90000 -range 0x00004000 -target_address_space [get_bd_addr_spaces sys_ps8/Data] [get_bd_addr_segs axi_mxfe_rx_jesd/rx_axi/s_axi/axi_lite] -force
  assign_bd_address -offset 0x84B90000 -range 0x00004000 -target_address_space [get_bd_addr_spaces sys_ps8/Data] [get_bd_addr_segs axi_mxfe_tx_jesd/tx_axi/s_axi/axi_lite] -force

  # Exclude Address Segments
  exclude_bd_addr_seg -offset 0x000800000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces axi_mxfe_rx_dma/m_dest_axi] [get_bd_addr_segs sys_ps8/SAXIGP3/HP1_DDR_HIGH]
  exclude_bd_addr_seg -offset 0x000800000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces axi_mxfe_rx_xcvr/m_axi] [get_bd_addr_segs sys_ps8/SAXIGP2/HP0_DDR_HIGH]
  exclude_bd_addr_seg -offset 0x000800000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces axi_mxfe_tx_dma/m_src_axi] [get_bd_addr_segs sys_ps8/SAXIGP4/HP2_DDR_HIGH]


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


