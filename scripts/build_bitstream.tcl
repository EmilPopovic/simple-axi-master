set project_name "axi-master"
set project_path "[pwd]/${project_name}/${project_name}.xpr"

puts "--- Opening Project: ${project_path} ---"
open_project ${project_path}

puts "--- Generating Block Design Products ---"
set bd_files [get_files *.bd]

if {[llength $bd_files] == 0} {
    puts "ERROR: No .bd file found!"
    exit 1
}

# 1. Open the Design
open_bd_design [lindex $bd_files 0]

# 2. Assign Addresses
puts "--- Assigning Addresses ---"
assign_bd_address

# 3. CRITICAL: Validate the design to propagate the map
validate_bd_design -force

# 4. Save the BD to lock the addresses
save_bd_design

# 5. Verify Address Editor state (Optional debug print)
set segs [get_bd_addr_segs -hierarchical]
if {[llength $segs] == 0} {
    puts "ERROR: No address segments found after validation!"
    exit 1
}

# 6. Generate Output Products
generate_target all [get_files *.bd] -force
puts "--- Block Design Generation Complete ---"

puts "--- Starting Synthesis ---"
reset_run synth_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1

if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
    puts "ERROR: Synthesis failed!"
    exit 1
}

puts "--- Starting Implementation & Bitstream ---"
reset_run impl_1
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
    puts "ERROR: Bitstream generation failed!"
    exit 1
} else {
    puts "SUCCESS: Bitstream generated successfully."
    
    set xsa_path "[pwd]/${project_name}.xsa"
    puts "--- Exporting XSA to: ${xsa_path} ---"
    
    write_hw_platform -fixed -include_bit -force -file ${xsa_path}
    
    puts "SUCCESS: Hardware Platform (XSA) exported."
}
