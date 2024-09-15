
# FPGA - First Demo Project

This project is a simple demonstration for the **Boolean Board, Spartan-7, FPGA** using Vivado 2024.1. It showcases basic I/O control functionality, such as turning on an LED when a button is pressed. This project is ideal for beginners who want to learn how to interface with the hardware components on the Boolean Board, including buttons and LEDs.

## Project Overview

The project includes the following files and directories:

### Main Files:
- **`project_1.xpr`**:  
  The Vivado 2024.1 project file. Open this file in Vivado to view and manage the project, including synthesizing and implementing the design.

### Source Files:
1. **`sources_1/new/led_control.v`**:  
   This Verilog file contains the logic to control the LEDs based on button input. It is a simple module that assigns the value of the button (`btn0`) to the red component of an on-board RGB LED (`RGB0_R`). 
   - **Purpose**: Demonstrates basic input/output logic, where pressing a button lights up an LED.
   - **When to use**: Use this code when starting with basic I/O interaction on the Boolean Board.

   ```verilog
   module led_control(
       input wire btn0,        // Button 0 input
       output wire RGB0_R      // Red component of RGB0 LED
   );
       assign RGB0_R = btn0;
   endmodule
   ```

2. **`sources_1/new/top_module.v`**:  
   This is the top-level Verilog module that instantiates the `led_control` module. It serves as the entry point for the project, ensuring that button inputs are mapped to the correct LED outputs.
   - **Purpose**: Provides a top-level wrapper for the project, linking hardware inputs (buttons) and outputs (LEDs).
   - **When to use**: This module serves as the top hierarchy of the design, organizing sub-modules like `led_control.v`.

   ```verilog
   module top(
       input wire btn0,          // Button 0 input
       output wire RGB0_R        // Red component of RGB0 LED
   );
       // Instantiate the led_control module
       led_control u_led_control (
           .btn0(btn0),
           .RGB0_R(RGB0_R)
       );
   endmodule
   ```

### Constraints Files:
1. **`constrs_1/new/test.xdc`**:  
   This XDC (Xilinx Design Constraints) file defines the physical mapping between the logical signals in the Verilog code and the actual hardware pins on the Boolean Board.
   - **Purpose**: Maps input/output signals (e.g., buttons and LEDs) to the correct FPGA pins.
   - **When to use**: Use this file when configuring your FPGA for specific pin assignments and I/O standards. Without this file, the design would not properly interface with the board’s hardware.

   ```tcl
   # On-board color LEDs (Red component)
   set_property -dict {PACKAGE_PIN V6 IOSTANDARD LVCMOS33} [get_ports {RGB0_R}];   # RGB0_R

   # On-board Button 0
   set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS33} [get_ports {btn0}];     # btn0

   # Virtual clock for timing analysis
   create_clock -period 10 [get_ports btn0]
   ```

## Project Structure

The project is structured as follows:

```
project_1/
├── project_1.cache/
├── project_1.hw/
├── project_1.runs/
├── project_1.srcs/
│   ├── constrs_1/new/test.xdc    # Constraints file
│   └── sources_1/new/
│       ├── led_control.v         # Verilog source for LED control
│       └── top_module.v          # Top-level Verilog module
├── LICENSE                       # License for the project
├── README.md                     # Project documentation
└── project_1.xpr                 # Vivado 2024.1 project file
```

## How to Use

1. **Open the project**:  
   Open `project_1.xpr` in Vivado 2024.1 to view and manage the project.

2. **Run Synthesis and Implementation**:  
   Use Vivado to synthesize and implement the project. After successful implementation, generate the bitstream and program the FPGA.

3. **Test the design**:  
   Once programmed, press Button 0 on the Boolean Board, and you should see the red LED (`RGB0_R`) turn on when the button is pressed.
