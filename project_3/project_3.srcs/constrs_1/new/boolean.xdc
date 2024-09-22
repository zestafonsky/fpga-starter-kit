# On-board color LEDs (Red component)
set_property -dict {PACKAGE_PIN V6 IOSTANDARD LVCMOS33} [get_ports {RGB0_R}];   # RGB0_R
set_property -dict {PACKAGE_PIN U3 IOSTANDARD LVCMOS33} [get_ports {RGB1_R}];   # RGB1_R

# On-board Button 0
set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS33} [get_ports {btn0}];     # btn0

# On-board Button 2
set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33} [get_ports {btn2}];     # btn2

# On-board Clock Input (replace with actual clock pin)
set_property -dict {PACKAGE_PIN F14 IOSTANDARD LVCMOS33} [get_ports {clk}];     # clk

# Create clock for timing analysis (assuming 100 MHz clock)
create_clock -period 10 [get_ports clk]
