# scripts/create_project.tcl
# This script recreates the Vivado project from source files

# Project settings
set project_name "axi-master"
set project_dir "[file normalize [file dirname [info script]]/../${project_name}]"
set rtl_dir "[file normalize [file dirname [info script]]/../rtl]"
set constraints_dir "[file normalize [file dirname [info script]]/../constraints]"
set ip_dir "[file normalize [file dirname [info script]]/../ip]"
set bd_dir "[file normalize [file dirname [info script]]/../bd]"
set sim_dir "[file normalize [file dirname [info script]]/../sim]"

# Device part for PYNQ-Z2
set part "xc7z020clg400-1"

# Close any open project
catch {close_project}

# Create project
puts "Creating project ${project_name} in ${project_dir}..."
create_project ${project_name} ${project_dir} -part ${part} -force

# Set project properties
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]
set_property default_lib xil_defaultlib [current_project]

# Add RTL sources (WITHOUT copying)
puts "Adding RTL sources from ${rtl_dir}..."
add_files -norecurse -fileset sources_1 [glob -nocomplain ${rtl_dir}/*.v ${rtl_dir}/*.sv]

# Add constraint files (WITHOUT copying)
if {[file exists ${constraints_dir}]} {
    puts "Adding constraints from ${constraints_dir}..."
    add_files -norecurse -fileset constrs_1 [glob -nocomplain ${constraints_dir}/*.xdc]
}

# Add IP cores (WITHOUT copying)
if {[file exists ${ip_dir}]} {
    puts "Adding IP from ${ip_dir}..."
    foreach ip_xci [glob -nocomplain ${ip_dir}/*/*.xci] {
        add_files -norecurse -fileset sources_1 ${ip_xci}
    }
}

# Source block design from TCL
if {[file exists ${bd_dir}/design_1.tcl]} {
    puts "Creating block design from ${bd_dir}/design_1.tcl..."
    source ${bd_dir}/design_1.tcl
} else {
    puts "WARNING: Block design TCL not found at ${bd_dir}/design_1.tcl"
    puts "         Create block design in Vivado and export with:"
    puts "         write_bd_tcl bd/design_1.tcl"
}

# Create HDL wrapper if block design exists
if {[file exists ${bd_dir}/design_1/design_1.bd]} {
    puts "Generating HDL wrapper for block design..."
    make_wrapper -files [get_files ${bd_dir}/design_1/design_1.bd] -top -import
    set_property top design_1_wrapper [current_fileset]
    puts "Top-level set to design_1_wrapper"
}

# Add simulation sources
if {[file exists ${sim_dir}]} {
    puts "Adding simulation sources from ${sim_dir}..."
    foreach sim_file [glob -nocomplain ${sim_dir}/tb_*.v ${sim_dir}/tb_*.sv] {
        add_files -norecurse -fileset sim_1 ${sim_file}
    }
    
    # Set simulation top
    set_property top tb_simple_axi_master [get_filesets sim_1]
    set_property top_lib xil_defaultlib [get_filesets sim_1]
    
    # Simulation settings
    set_property -name {xsim.simulate.runtime} -value {1000ns} -objects [get_filesets sim_1]
    puts "Simulation configured"
}

puts ""
puts "=========================================="
puts "Project created successfully!"
puts "=========================================="
puts ""
