open_project [file normalize [file dirname [info script]]/../axi-master/axi-master.xpr]

reset_run impl_1
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
    error "Bitstream generation failed!"
}

puts "Bitstream generated successfully!"

# Report timing
open_run impl_1
report_timing_summary -file timing_summary.rpt
report_utilization -file utilization.rpt

puts "Reports generated: timing_summary.rpt, utilization.rpt"
