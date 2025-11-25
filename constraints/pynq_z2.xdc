## This is a placeholder
## If external I/O needed, get full constraints at
## https://gist.githubusercontent.com/fcayci/eb913f5f17cbf107d624448a7282b631/raw/fad9c36ad6f7b638437871c320f8a578c73d5707/pynq-z2.xdc

set_property -dict { PACKAGE_PIN R14   IOSTANDARD LVCMOS33 } [get_ports { leds_4bits[0] }];
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { leds_4bits[1] }];
set_property -dict { PACKAGE_PIN N16   IOSTANDARD LVCMOS33 } [get_ports { leds_4bits[2] }];
set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { leds_4bits[3] }];
