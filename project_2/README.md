
# FPGA - Second Demo Project

This project is a continuation of the Boolean Board, Spartan-7, FPGA demonstration using Vivado 2024.1. It expands on the basic I/O control functionality by adding control for two on-board RGB LEDs (red components) using two buttons. The project emphasizes modular design and the use of multiple inputs and outputs, making it a great next step for those who have completed the first demo.

## Project Overview

The project includes the following files and directories:

### Main Files:

- **project_2.xpr**:  
  The Vivado 2024.1 project file. Open this file in Vivado to view and manage the project, including synthesizing and implementing the design.

### Source Files:

- **sources_1/new/rgb_control.v**:  
  This Verilog file contains the logic to control the red components of the on-board RGB LEDs. It takes input from the buttons and controls the red component of each LED accordingly.

  ```verilog
  module rgb_control (
      input wire btn,         // Button input
      output wire RGB_R       // Red component of RGB LED
  );
      assign RGB_R = btn;      // Button controls the red LED
  endmodule
  ```

  - **Purpose**: Demonstrates modular design by allowing each button to control the red component of a different RGB LED.
  - **When to use**: Use this code to extend your project to include multiple LEDs and inputs.

- **sources_1/new/top_module.v**:  
  This is the top-level Verilog module that instantiates two instances of the `rgb_control` module. It maps Button 0 to the red component of RGB0 and Button 2 to the red component of RGB1.

  ```verilog
  module top (
      input wire btn0,          // Button 0 input
      input wire btn2,          // Button 2 input
      output wire RGB0_R,       // Red component of RGB0 LED
      output wire RGB1_R        // Red component of RGB1 LED
  );
      // Instantiate the rgb_control module for RGB0
      rgb_control u_rgb_control_0 (
          .btn(btn0),
          .RGB_R(RGB0_R)
      );

      // Instantiate the rgb_control module for RGB1
      rgb_control u_rgb_control_1 (
          .btn(btn2),
          .RGB_R(RGB1_R)
      );
  endmodule
  ```

  - **Purpose**: Provides a top-level wrapper for the project, organizing the input/output signals for multiple LEDs and buttons.
  - **When to use**: Use this module as the top hierarchy of the design for projects involving multiple components and controls.

### Constraints Files:

- **constrs_1/new/test.xdc**:  
  This XDC (Xilinx Design Constraints) file defines the physical mapping between the logical signals in the Verilog code and the actual hardware pins on the Boolean Board.

  ```xdc
  # On-board color LEDs (Red component)
  set_property -dict {PACKAGE_PIN V6 IOSTANDARD LVCMOS33} [get_ports {RGB0_R}];   # RGB0_R
  set_property -dict {PACKAGE_PIN U3 IOSTANDARD LVCMOS33} [get_ports {RGB1_R}];   # RGB1_R

  # On-board Button 0
  set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS33} [get_ports {btn0}];     # btn0

  # On-board Button 2
  set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33} [get_ports {btn2}];     # btn2

  # Virtual clock for timing analysis
  create_clock -period 10 [get_ports btn0]
  create_clock -period 10 [get_ports btn2]
  ```

  - **Purpose**: Maps input/output signals (e.g., buttons and LEDs) to the correct FPGA pins.
  - **When to use**: Use this file when configuring your FPGA for specific pin assignments and I/O standards.

## Project Structure

```
project_2/
├── project_2.cache/
├── project_2.hw/
├── project_2.runs/
├── project_2.srcs/
│   ├── constrs_1/new/test.xdc    # Constraints file
│   └── sources_1/new/
│       ├── rgb_control.v         # Verilog source for RGB control
│       └── top_module.v          # Top-level Verilog module
├── README.md                     # Project documentation
└── project_2.xpr                 # Vivado 2024.1 project file
```

## How to Use

1. **Open the project**:  
   Open `project_2.xpr` in Vivado 2024.1 to view and manage the project.

2. **Run Synthesis and Implementation**:  
   Use Vivado to synthesize and implement the project. After successful implementation, generate the bitstream and program the FPGA.

3. **Test the design**:  
   Once programmed, press Button 0 to turn on the red LED (RGB0_R) and Button 2 to control the red LED (RGB1_R).
