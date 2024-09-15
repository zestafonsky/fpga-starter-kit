# On-board color LEDs (Red component)
set_property -dict {PACKAGE_PIN V6 IOSTANDARD LVCMOS33} [get_ports {RGB0_R}];   # RGB0_R

# On-board Button 0
set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS33} [get_ports {btn0}];     # btn0

# Virtual clock for timing analysis
create_clock -period 10 [get_ports btn0]
