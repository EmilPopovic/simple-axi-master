open_project [file normalize [file dirname [info script]]/../axi-master/axi-master.xpr]

reset_run synth_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1

if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
    error "Synthesis failed!"
}

puts "Synthesis completed successfully!"
