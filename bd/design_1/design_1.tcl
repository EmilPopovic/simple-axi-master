
################################################################
# This is a generated script based on design: design_1
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
set scripts_vivado_version 2022.2
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
# source design_1_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# simple_axi_master_wrapper

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z020clg400-1
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name design_1

# This script was generated for a remote BD. To create a non-remote design,
# change the variable <run_remote_bd_flow> to <0>.

set run_remote_bd_flow 1
if { $run_remote_bd_flow == 1 } {
  # Set the reference directory for source file relative paths (by default 
  # the value is script directory path)
  set origin_dir ./bd

  # Use origin directory path location variable, if specified in the tcl shell
  if { [info exists ::origin_dir_loc] } {
     set origin_dir $::origin_dir_loc
  }

  set str_bd_folder [file normalize ${origin_dir}]
  set str_bd_filepath ${str_bd_folder}/${design_name}/${design_name}.bd

  # Check if remote design exists on disk
  if { [file exists $str_bd_filepath ] == 1 } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2030 -severity "ERROR" "The remote BD file path <$str_bd_filepath> already exists!"}
     common::send_gid_msg -ssname BD::TCL -id 2031 -severity "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0>."
     common::send_gid_msg -ssname BD::TCL -id 2032 -severity "INFO" "Also make sure there is no design <$design_name> existing in your current project."

     return 1
  }

  # Check if design exists in memory
  set list_existing_designs [get_bd_designs -quiet $design_name]
  if { $list_existing_designs ne "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2033 -severity "ERROR" "The design <$design_name> already exists in this project! Will not create the remote BD <$design_name> at the folder <$str_bd_folder>."}

     common::send_gid_msg -ssname BD::TCL -id 2034 -severity "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0> or please set a different value to variable <design_name>."

     return 1
  }

  # Check if design exists on disk within project
  set list_existing_designs [get_files -quiet */${design_name}.bd]
  if { $list_existing_designs ne "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2035 -severity "ERROR" "The design <$design_name> already exists in this project at location:
    $list_existing_designs"}
     catch {common::send_gid_msg -ssname BD::TCL -id 2036 -severity "ERROR" "Will not create the remote BD <$design_name> at the folder <$str_bd_folder>."}

     common::send_gid_msg -ssname BD::TCL -id 2037 -severity "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0> or please set a different value to variable <design_name>."

     return 1
  }

  # Now can create the remote BD
  # NOTE - usage of <-dir> will create <$str_bd_folder/$design_name/$design_name.bd>
  create_bd_design -dir $str_bd_folder $design_name
} else {

  # Create regular design
  if { [catch {create_bd_design $design_name} errmsg] } {
     common::send_gid_msg -ssname BD::TCL -id 2038 -severity "INFO" "Please set a different value to variable <design_name>."

     return 1
  }
}

current_bd_design $design_name

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:axi_gpio:2.0\
xilinx.com:ip:processing_system7:5.5\
xilinx.com:ip:xlslice:1.0\
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

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
simple_axi_master_wrapper\
"

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
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
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]

  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]


  # Create ports
  set leds_4bits [ create_bd_port -dir O -from 3 -to 0 leds_4bits ]
  set rgb_leds [ create_bd_port -dir O -from 5 -to 0 rgb_leds ]
  set switches [ create_bd_port -dir I -from 1 -to 0 switches ]

  # Create instance: axi_master, and set properties
  set block_name simple_axi_master_wrapper
  set block_cell_name axi_master
  if { [catch {set axi_master [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $axi_master eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [list \
    CONFIG.DEBUG {1} \
    CONFIG.WIDTH {32} \
  ] $axi_master


  # Create instance: concat_lsb_to_msb_wdei, and set properties
  set concat_lsb_to_msb_wdei [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 concat_lsb_to_msb_wdei ]
  set_property CONFIG.NUM_PORTS {4} $concat_lsb_to_msb_wdei


  # Create instance: gpio_addr, and set properties
  set gpio_addr [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 gpio_addr ]
  set_property CONFIG.C_ALL_OUTPUTS {1} $gpio_addr


  # Create instance: gpio_ctrl, and set properties
  set gpio_ctrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 gpio_ctrl ]
  set_property -dict [list \
    CONFIG.C_ALL_INPUTS {0} \
    CONFIG.C_ALL_INPUTS_2 {1} \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_GPIO2_WIDTH {4} \
    CONFIG.C_GPIO_WIDTH {7} \
    CONFIG.C_IS_DUAL {1} \
  ] $gpio_ctrl


  # Create instance: gpio_devices, and set properties
  set gpio_devices [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 gpio_devices ]
  set_property -dict [list \
    CONFIG.C_ALL_INPUTS_2 {1} \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_GPIO2_WIDTH {2} \
    CONFIG.C_GPIO_WIDTH {6} \
    CONFIG.C_IS_DUAL {1} \
  ] $gpio_devices


  # Create instance: gpio_interconnect, and set properties
  set gpio_interconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 gpio_interconnect ]
  set_property CONFIG.NUM_MI {5} $gpio_interconnect


  # Create instance: gpio_latency, and set properties
  set gpio_latency [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 gpio_latency ]
  set_property CONFIG.C_ALL_INPUTS {1} $gpio_latency


  # Create instance: gpio_rdata, and set properties
  set gpio_rdata [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 gpio_rdata ]
  set_property CONFIG.C_ALL_INPUTS {1} $gpio_rdata


  # Create instance: gpio_wdata, and set properties
  set gpio_wdata [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 gpio_wdata ]
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_INTERRUPT_PRESENT {0} \
  ] $gpio_wdata


  # Create instance: master_interconnect, and set properties
  set master_interconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 master_interconnect ]
  set_property CONFIG.NUM_MI {2} $master_interconnect


  # Create instance: ps, and set properties
  set ps [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 ps ]
  set_property -dict [list \
    CONFIG.PCW_ACT_APU_PERIPHERAL_FREQMHZ {666.666687} \
    CONFIG.PCW_ACT_CAN_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_DCI_PERIPHERAL_FREQMHZ {10.158730} \
    CONFIG.PCW_ACT_ENET0_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_ENET1_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ {100.000000} \
    CONFIG.PCW_ACT_FPGA1_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_FPGA2_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_FPGA3_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_PCAP_PERIPHERAL_FREQMHZ {200.000000} \
    CONFIG.PCW_ACT_QSPI_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_SDIO_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_SMC_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_SPI_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_TPIU_PERIPHERAL_FREQMHZ {200.000000} \
    CONFIG.PCW_ACT_TTC0_CLK0_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC0_CLK1_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC0_CLK2_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC1_CLK0_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC1_CLK1_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC1_CLK2_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_UART_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_WDT_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_CLK0_FREQ {100000000} \
    CONFIG.PCW_CLK1_FREQ {10000000} \
    CONFIG.PCW_CLK2_FREQ {10000000} \
    CONFIG.PCW_CLK3_FREQ {10000000} \
    CONFIG.PCW_DDR_RAM_HIGHADDR {0x1FFFFFFF} \
    CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100} \
    CONFIG.PCW_FPGA_FCLK0_ENABLE {1} \
    CONFIG.PCW_S_AXI_HP0_DATA_WIDTH {64} \
    CONFIG.PCW_UIPARAM_ACT_DDR_FREQ_MHZ {533.333374} \
    CONFIG.PCW_USE_S_AXI_HP0 {1} \
  ] $ps


  # Create instance: slice_clear_5_downto_5, and set properties
  set slice_clear_5_downto_5 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_clear_5_downto_5 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {5} \
    CONFIG.DIN_TO {5} \
    CONFIG.DIN_WIDTH {6} \
  ] $slice_clear_5_downto_5


  # Create instance: slice_rstn_6_downto_6, and set properties
  set slice_rstn_6_downto_6 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_rstn_6_downto_6 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {6} \
    CONFIG.DIN_TO {6} \
    CONFIG.DIN_WIDTH {7} \
  ] $slice_rstn_6_downto_6


  # Create instance: slice_rw_4_downto_3, and set properties
  set slice_rw_4_downto_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_rw_4_downto_3 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {4} \
    CONFIG.DIN_TO {3} \
    CONFIG.DIN_WIDTH {6} \
  ] $slice_rw_4_downto_3


  # Create instance: slice_size_2_downto_1, and set properties
  set slice_size_2_downto_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_size_2_downto_1 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {2} \
    CONFIG.DIN_TO {0} \
    CONFIG.DIN_WIDTH {6} \
  ] $slice_size_2_downto_1


  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins gpio_interconnect/S00_AXI] [get_bd_intf_pins ps/M_AXI_GP0]
  connect_bd_intf_net -intf_net axi_interconnect_1_M00_AXI [get_bd_intf_pins gpio_interconnect/M00_AXI] [get_bd_intf_pins gpio_wdata/S_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_1_M01_AXI [get_bd_intf_pins gpio_interconnect/M01_AXI] [get_bd_intf_pins gpio_rdata/S_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_1_M02_AXI [get_bd_intf_pins gpio_addr/S_AXI] [get_bd_intf_pins gpio_interconnect/M02_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_1_M03_AXI [get_bd_intf_pins gpio_ctrl/S_AXI] [get_bd_intf_pins gpio_interconnect/M03_AXI]
  connect_bd_intf_net -intf_net axi_master_m_axi [get_bd_intf_pins axi_master/m_axi] [get_bd_intf_pins master_interconnect/S00_AXI]
  connect_bd_intf_net -intf_net gpio_interconnect_M04_AXI [get_bd_intf_pins gpio_interconnect/M04_AXI] [get_bd_intf_pins gpio_latency/S_AXI]
  connect_bd_intf_net -intf_net master_interconnect_M00_AXI [get_bd_intf_pins master_interconnect/M00_AXI] [get_bd_intf_pins ps/S_AXI_HP0]
  connect_bd_intf_net -intf_net master_interconnect_M01_AXI [get_bd_intf_pins gpio_devices/S_AXI] [get_bd_intf_pins master_interconnect/M01_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins ps/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins ps/FIXED_IO]

  # Create port connections
  connect_bd_net -net axi_gpio_0_gpio_io_o [get_bd_pins axi_master/i_wdata] [get_bd_pins gpio_wdata/gpio_io_o]
  connect_bd_net -net axi_gpio_0_gpio_io_o1 [get_bd_ports rgb_leds] [get_bd_pins gpio_devices/gpio_io_o]
  connect_bd_net -net axi_gpio_2_gpio_io_o [get_bd_pins axi_master/i_addr] [get_bd_pins gpio_addr/gpio_io_o]
  connect_bd_net -net axi_gpio_3_gpio_io_o [get_bd_pins gpio_ctrl/gpio_io_o] [get_bd_pins slice_clear_5_downto_5/Din] [get_bd_pins slice_rstn_6_downto_6/Din] [get_bd_pins slice_rw_4_downto_3/Din] [get_bd_pins slice_size_2_downto_1/Din]
  connect_bd_net -net axi_master_o_debug_latency [get_bd_pins axi_master/o_debug_latency] [get_bd_pins gpio_latency/gpio_io_i]
  connect_bd_net -net axi_master_o_debug_state [get_bd_ports leds_4bits] [get_bd_pins axi_master/o_debug_state]
  connect_bd_net -net gpio2_io_i_0_1 [get_bd_ports switches] [get_bd_pins gpio_devices/gpio2_io_i]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins axi_master/i_clk] [get_bd_pins gpio_addr/s_axi_aclk] [get_bd_pins gpio_ctrl/s_axi_aclk] [get_bd_pins gpio_devices/s_axi_aclk] [get_bd_pins gpio_interconnect/ACLK] [get_bd_pins gpio_interconnect/M00_ACLK] [get_bd_pins gpio_interconnect/M01_ACLK] [get_bd_pins gpio_interconnect/M02_ACLK] [get_bd_pins gpio_interconnect/M03_ACLK] [get_bd_pins gpio_interconnect/M04_ACLK] [get_bd_pins gpio_interconnect/S00_ACLK] [get_bd_pins gpio_latency/s_axi_aclk] [get_bd_pins gpio_rdata/s_axi_aclk] [get_bd_pins gpio_wdata/s_axi_aclk] [get_bd_pins master_interconnect/ACLK] [get_bd_pins master_interconnect/M00_ACLK] [get_bd_pins master_interconnect/M01_ACLK] [get_bd_pins master_interconnect/S00_ACLK] [get_bd_pins ps/FCLK_CLK0] [get_bd_pins ps/M_AXI_GP0_ACLK] [get_bd_pins ps/S_AXI_HP0_ACLK]
  connect_bd_net -net ps_FCLK_RESET0_N [get_bd_pins gpio_addr/s_axi_aresetn] [get_bd_pins gpio_ctrl/s_axi_aresetn] [get_bd_pins gpio_interconnect/ARESETN] [get_bd_pins gpio_interconnect/M00_ARESETN] [get_bd_pins gpio_interconnect/M01_ARESETN] [get_bd_pins gpio_interconnect/M02_ARESETN] [get_bd_pins gpio_interconnect/M03_ARESETN] [get_bd_pins gpio_interconnect/M04_ARESETN] [get_bd_pins gpio_interconnect/S00_ARESETN] [get_bd_pins gpio_latency/s_axi_aresetn] [get_bd_pins gpio_rdata/s_axi_aresetn] [get_bd_pins gpio_wdata/s_axi_aresetn] [get_bd_pins ps/FCLK_RESET0_N]
  connect_bd_net -net simple_axi_master_wr_0_o_done [get_bd_pins axi_master/o_done] [get_bd_pins concat_lsb_to_msb_wdei/In1]
  connect_bd_net -net simple_axi_master_wr_0_o_error [get_bd_pins axi_master/o_error] [get_bd_pins concat_lsb_to_msb_wdei/In2]
  connect_bd_net -net simple_axi_master_wr_0_o_invalid [get_bd_pins axi_master/o_invalid] [get_bd_pins concat_lsb_to_msb_wdei/In3]
  connect_bd_net -net simple_axi_master_wr_0_o_rdata [get_bd_pins axi_master/o_rdata] [get_bd_pins gpio_rdata/gpio_io_i]
  connect_bd_net -net simple_axi_master_wr_0_o_wait [get_bd_pins axi_master/o_wait] [get_bd_pins concat_lsb_to_msb_wdei/In0]
  connect_bd_net -net slice_rstn_6_downto_6_Dout [get_bd_pins axi_master/i_rstn] [get_bd_pins gpio_devices/s_axi_aresetn] [get_bd_pins master_interconnect/ARESETN] [get_bd_pins master_interconnect/M00_ARESETN] [get_bd_pins master_interconnect/M01_ARESETN] [get_bd_pins master_interconnect/S00_ARESETN] [get_bd_pins slice_rstn_6_downto_6/Dout]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins concat_lsb_to_msb_wdei/dout] [get_bd_pins gpio_ctrl/gpio2_io_i]
  connect_bd_net -net xlslice_0_Dout [get_bd_pins axi_master/i_size] [get_bd_pins slice_size_2_downto_1/Dout]
  connect_bd_net -net xlslice_1_Dout [get_bd_pins axi_master/i_clear] [get_bd_pins slice_clear_5_downto_5/Dout]
  connect_bd_net -net xlslice_2_Dout [get_bd_pins axi_master/i_rw] [get_bd_pins slice_rw_4_downto_3/Dout]

  # Create address segments
  assign_bd_address -offset 0x40000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces axi_master/m_axi] [get_bd_addr_segs gpio_devices/S_AXI/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces axi_master/m_axi] [get_bd_addr_segs ps/S_AXI_HP0/HP0_DDR_LOWOCM] -force
  assign_bd_address -offset 0x41200000 -range 0x00010000 -target_address_space [get_bd_addr_spaces ps/Data] [get_bd_addr_segs gpio_addr/S_AXI/Reg] -force
  assign_bd_address -offset 0x41210000 -range 0x00010000 -target_address_space [get_bd_addr_spaces ps/Data] [get_bd_addr_segs gpio_ctrl/S_AXI/Reg] -force
  assign_bd_address -offset 0x41240000 -range 0x00010000 -target_address_space [get_bd_addr_spaces ps/Data] [get_bd_addr_segs gpio_latency/S_AXI/Reg] -force
  assign_bd_address -offset 0x41220000 -range 0x00010000 -target_address_space [get_bd_addr_spaces ps/Data] [get_bd_addr_segs gpio_rdata/S_AXI/Reg] -force
  assign_bd_address -offset 0x41230000 -range 0x00010000 -target_address_space [get_bd_addr_spaces ps/Data] [get_bd_addr_segs gpio_wdata/S_AXI/Reg] -force


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


