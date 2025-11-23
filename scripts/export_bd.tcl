set project_name "axi-master"
set project_dir [file normalize [file dirname [info script]]/../${project_name}]
set bd_dir [file normalize [file dirname [info script]]/../bd]

# Open project
puts "Opening project ${project_dir}/${project_name}.xpr..."
open_project ${project_dir}/${project_name}.xpr

# Get all block designs
set bd_files [get_files -filter {FILE_TYPE == "Block Designs"}]

if {[llength $bd_files] == 0} {
    puts "WARNING: No block designs found in project"
    exit 0
}

puts ""
puts "Found [llength $bd_files] block design(s)"
puts ""

# Export each block design
foreach bd_file $bd_files {
    set bd_name [file rootname [file tail $bd_file]]
    set export_path "${bd_dir}/${bd_name}/${bd_name}.tcl"
    
    puts "Exporting ${bd_name}..."
    puts "  From: ${bd_file}"
    puts "  To:   ${export_path}"
    
    open_bd_design $bd_file
    
    # Create directory if needed
    file mkdir [file dirname $export_path]
    
    # Export to TCL
    write_bd_tcl -force $export_path
    
    # Close the block design to clean up
    close_bd_design [get_bd_designs $bd_name]
    
    puts "  ✓ Exported successfully"
    puts ""
}

puts "=========================================="
puts "All block designs exported!"
puts "=========================================="
puts ""
puts "Remember to commit the TCL files to git:"
puts "  git add bd/"
puts "  git commit -m \"Update block design\""
puts ""
