# Push Buttons
set_property -dict { PACKAGE_PIN R14   IOSTANDARD LVCMOS33 } [get_ports { leds_4bits[0] }]; ## LD0
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { leds_4bits[1] }]; ## LD1
set_property -dict { PACKAGE_PIN N16   IOSTANDARD LVCMOS33 } [get_ports { leds_4bits[2] }]; ## LD2
set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { leds_4bits[3] }]; ## LD3

# Sliding Switches
set_property -dict { PACKAGE_PIN M20   IOSTANDARD LVCMOS33 } [get_ports { switches[0] }]; ## SW0
set_property -dict { PACKAGE_PIN M19   IOSTANDARD LVCMOS33 } [get_ports { switches[1] }]; ## SW1

# RGB LEDs (LD4, LD5)
# LD4
set_property -dict { PACKAGE_PIN L15   IOSTANDARD LVCMOS33 } [get_ports { rgb_leds[0] }]; ## LD4_R
set_property -dict { PACKAGE_PIN M15   IOSTANDARD LVCMOS33 } [get_ports { rgb_leds[1] }]; ## LD4_G
set_property -dict { PACKAGE_PIN L14   IOSTANDARD LVCMOS33 } [get_ports { rgb_leds[2] }]; ## LD4_B
# LD5
set_property -dict { PACKAGE_PIN N18   IOSTANDARD LVCMOS33 } [get_ports { rgb_leds[3] }]; ## LD5_R
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports { rgb_leds[4] }]; ## LD5_G
set_property -dict { PACKAGE_PIN M17   IOSTANDARD LVCMOS33 } [get_ports { rgb_leds[5] }]; ## LD5_B
