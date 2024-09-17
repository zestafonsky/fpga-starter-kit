
# FPGA - Second Demo Project (Boolean Board, Spartan-7, Vivado 2024.1)

## Overview

This project is an extension of the first demo, providing additional I/O control functionality for the Boolean Board (Spartan-7, FPGA). In this project, we control two on-board RGB LEDs (red components) using two separate buttons. Button 0 controls the red component of RGB0, and Button 2 controls the red component of RGB1. This project is suitable for those who have completed the first demo and want to expand their knowledge by working with multiple inputs and outputs.

### Key Features:
- Button 0 turns on the red component of RGB LED 0 (RGB0_R).
- Button 2 turns on the red component of RGB LED 1 (RGB1_R).
- Demonstrates the instantiation of multiple instances of a module (`rgb_control`) for modular design.

## Project Structure

```
second_project/
├── second_project.cache/
├── second_project.hw/
├── second_project.runs/
├── second_project.srcs/
│   ├── constrs_1/new/test.xdc    # Constraints file for pin assignments
│   └── sources_1/new/
│       ├── rgb_control.v         # Verilog source for RGB LED control logic
│       └── top_module.v          # Top-level Verilog module
├── README.md                     # Project documentation
└── second_project.xpr            # Vivado 2024.1 project file
```

### Main Files:

- **`rgb_control.v`**: 
  - A reusable module that controls the red component of an RGB LED based on button input. It assigns the state of the button to the LED.
  
  **Purpose**: Modularizes the control logic for each LED.
  
- **`top_module.v`**: 
  - The top-level Verilog file that instantiates two instances of `rgb_control` for controlling two separate LEDs with two separate buttons.
  
  **Purpose**: Connects button inputs to LED outputs in a scalable, modular design.

- **`test.xdc`**: 
  - This Xilinx Design Constraints (XDC) file maps the logical signals in the Verilog code to specific hardware pins on the Boolean Board.

  **Purpose**: Ensures the correct physical connections between the FPGA and board components (buttons and LEDs).

## How to Use

### 1. Open the Project
- Open `second_project.xpr` in Vivado 2024.1 to view and manage the project.

### 2. Run Synthesis and Implementation
- Use Vivado to synthesize and implement the design.
- After successful implementation, generate the bitstream and program the FPGA.

### 3. Test the Design
- Once programmed, press Button 0 on the Boolean Board to turn on the red component of RGB0.
- Press Button 2 to turn on the red component of RGB1.
