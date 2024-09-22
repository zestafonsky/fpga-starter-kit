
# FPGA - Third Demo Project

This project further expands on the Boolean Board, Spartan-7, FPGA demonstration using Vivado 2024.1 by adding clock-based control for two on-board RGB LEDs (red components) using two buttons. It introduces a simple debounce mechanism and toggling functionality for the LEDs, which makes it a valuable learning step for clock-driven designs and button debouncing.

## Project Overview

The project includes the following files and directories:

### Main Files:

- **project_3.xpr**:  
  The Vivado 2024.1 project file. Open this file in Vivado to view and manage the project, including synthesizing and implementing the design.

### Source Files:

- **sources_1/new/rgb_control.v**:  
  This Verilog file contains the logic to control the red components of the on-board RGB LEDs. It introduces a button debouncing mechanism using a clock input, and toggles the LED state upon button press.

  ```verilog
  module rgb_control(
      input wire clk,          // Clock input
      input wire btn,          // Button input
      output reg RGB_R         // Red component of RGB LED
  );
      // Internal signal declarations
      reg btn_state = 1'b0;     // Tracks the debounced state of the button
      reg toggle_state = 1'b0;  // Toggle state for the LED
      reg [15:0] debounce_cnt = 16'b0; // Debouncing counter
      
      // Debouncing logic: when the button state changes, debounce the signal
      always @(posedge clk) begin
          if (btn_state == btn) begin
              debounce_cnt <= 16'b0;  // Reset counter if button state is stable
          end else begin
              debounce_cnt <= debounce_cnt + 1;
              if (debounce_cnt == 16'hFFFF) begin  // Max debounce count reached
                  btn_state <= btn;  // Button state has stabilized
                  if (btn_state == 1'b1) begin     // Button is released
                      toggle_state <= ~toggle_state;  // Toggle the LED state
                  end
              end
          end
      end

      // Drive the RGB_R output with the toggle state
      always @(posedge clk) begin
          RGB_R <= toggle_state;
      end
  endmodule
  ```

  - **Purpose**: Demonstrates clock-driven design with debouncing and LED control.
  - **When to use**: Use this code to handle button presses more reliably and toggle the state of the LED.

- **sources_1/new/top_module.v**:  
  This is the top-level Verilog module that instantiates two instances of the `rgb_control` module. It connects Button 0 to the red component of RGB0 and Button 2 to the red component of RGB1, both driven by the on-board clock.

  ```verilog
  module top(
      input wire clk,           // Clock input
      input wire btn0,          // Button 0 input
      input wire btn2,          // Button 2 input
      output wire RGB0_R,       // Red component of RGB0 LED
      output wire RGB1_R        // Red component of RGB1 LED
  );
      // Instantiate the rgb_control module for RGB0
      rgb_control u_rgb_control_0 (
          .clk(clk),
          .btn(btn0),
          .RGB_R(RGB0_R)
      );

      // Instantiate the rgb_control module for RGB1
      rgb_control u_rgb_control_1 (
          .clk(clk),
          .btn(btn2),
          .RGB_R(RGB1_R)
      );
  endmodule
  ```

  - **Purpose**: Provides a top-level wrapper for the project, organizing clock-driven input/output signals for multiple LEDs and buttons.
  - **When to use**: Use this module as the top hierarchy of the design for clock-based control of multiple components.

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

  # On-board Clock Input (replace with actual clock pin)
  set_property -dict {PACKAGE_PIN F14 IOSTANDARD LVCMOS33} [get_ports {clk}];     # clk

  # Create clock for timing analysis (assuming 100 MHz clock)
  create_clock -period 10 [get_ports clk]
  ```

  - **Purpose**: Maps input/output signals (e.g., buttons, LEDs, and clock) to the correct FPGA pins.
  - **When to use**: Use this file when configuring your FPGA for specific pin assignments and I/O standards.

## Project Structure

```
project_3/
├── project_3.cache/
├── project_3.hw/
├── project_3.runs/
├── project_3.srcs/
│   ├── constrs_1/new/boolean.xdc    # Constraints file
│   └── sources_1/new/
│       ├── rgb_control.v         # Verilog source for RGB control with clock and debounce
│       └── top_module.v          # Top-level Verilog module
├── README.md                     # Project documentation
└── project_3.xpr                 # Vivado 2024.1 project file
```

## How to Use

1. **Open the project**:  
   Open `project_3.xpr` in Vivado 2024.1 to view and manage the project.

2. **Run Synthesis and Implementation**:  
   Use Vivado to synthesize and implement the project. After successful implementation, generate the bitstream and program the FPGA.

3. **Test the design**:  
   Once programmed, press Button 0 to toggle the red LED (RGB0_R) and Button 2 to toggle the red LED (RGB1_R). The clock will ensure that button presses are debounced and the LEDs change state accordingly.
