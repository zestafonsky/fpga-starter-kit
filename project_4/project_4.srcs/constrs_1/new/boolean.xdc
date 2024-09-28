# On-board color LEDs (Red, Green, Blue components for RGB0 and RGB1)
set_property IOSTANDARD LVCMOS33 [get_ports {RGB0_R}];   # RGB0_R (Red component of RGB0)
set_property PACKAGE_PIN V6 [get_ports {RGB0_R}];

set_property IOSTANDARD LVCMOS33 [get_ports {RGB0_G}];   # RGB0_G (Green component of RGB0)
set_property PACKAGE_PIN V4 [get_ports {RGB0_G}];

set_property IOSTANDARD LVCMOS33 [get_ports {RGB0_B}];   # RGB0_B (Blue component of RGB0)
set_property PACKAGE_PIN U6 [get_ports {RGB0_B}];

set_property IOSTANDARD LVCMOS33 [get_ports {RGB1_R}];   # RGB1_R (Red component of RGB1)
set_property PACKAGE_PIN U3 [get_ports {RGB1_R}];

# On-board Buttons
set_property IOSTANDARD LVCMOS33 [get_ports {btn0}];     # btn0
set_property PACKAGE_PIN J2 [get_ports {btn0}];

set_property IOSTANDARD LVCMOS33 [get_ports {btn1}];     # btn1
set_property PACKAGE_PIN J5 [get_ports {btn1}];

set_property IOSTANDARD LVCMOS33 [get_ports {btn2}];     # btn2
set_property PACKAGE_PIN H2 [get_ports {btn2}];

set_property IOSTANDARD LVCMOS33 [get_ports {btn3}];     # btn3 (Newly added for reverse color control)
set_property PACKAGE_PIN J1 [get_ports {btn3}];

# On-board Clock Input
set_property IOSTANDARD LVCMOS33 [get_ports {clk}];      # clk
set_property PACKAGE_PIN F14 [get_ports {clk}];

# Create clock for timing analysis (assuming 100 MHz clock)
create_clock -period 10 [get_ports clk]
