open_project [file normalize [file dirname [info script]]/../axi-master/axi-master.xpr]

reset_run impl_1
launch_runs impl_1 -jobs 4
wait_on_run impl_1

if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
    error "Implementation failed!"
}

puts "Implementation completed successfully!"
