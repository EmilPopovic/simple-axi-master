# Complete build flow
set project_file [file normalize [file dirname [info script]]/../axi-master/axi-master.xpr]

open_project ${project_file}

# Reset runs
reset_run synth_1
reset_run impl_1

# Run synthesis
puts "Starting synthesis..."
launch_runs synth_1 -jobs 4
wait_on_run synth_1

if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
    error "Synthesis failed!"
}
puts "Synthesis complete!"

# Run implementation
puts "Starting implementation..."
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
    error "Implementation failed!"
}
puts "Implementation complete!"

# Generate reports
open_run impl_1
report_timing_summary -file impl_1_timing_summary.rpt
report_utilization -file impl_1_utilization.rpt
report_power -file impl_1_power.rpt

puts "=========================================="
puts "Build complete!"
puts "Bitstream: [glob axi-master/axi-master.runs/impl_1/*.bit]"
puts "Reports: impl_1_*.rpt"
puts "=========================================="
