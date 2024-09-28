
# FPGA - Fourth Demo Project

This project builds upon the previous Boolean Board (Spartan-7, FPGA) demonstration in Vivado 2024.1 by introducing multi-color control for RGB0 (Red, Green, Blue) and basic red control for RGB1. Additionally, it supports reverse color cycling for RGB0 and includes debouncing and edge detection for cleaner input handling.

## Project Overview

### Main Files:
- **project_4.xpr**:  
  Open this Vivado project file to work with the design.

### Source Files:
- **sources_1/new/top.v**:  
  The top-level Verilog module controls the RGB LEDs using buttons for toggling and color cycling, including reverse cycling.

  ```verilog
  module top(
      input wire clk,
      input wire btn0, btn1, btn2, btn3,
      output wire RGB0_R, RGB0_G, RGB0_B, RGB1_R
  );
  ```

- **sources_1/new/rgb_control.v**:  
  Controls the RGB0 and RGB1 LEDs' toggling and color cycling behavior, with debouncing and edge detection for button presses.

  ```verilog
  module rgb_control #(
      parameter COLOR_CHANGE = 1
  )(
      input wire clk, btn0, btn1, btn3,
      output reg RGB_R, RGB_G, RGB_B
  );
  ```

- **sources_1/new/debounce.v**:  
  Debouncing logic to ensure clean button inputs.

  ```verilog
  module debounce(
      input wire clk,
      input wire btn_in,
      output reg btn_out
  );
  ```

- **sources_1/new/edge_detector.v**:  
  Detects rising and falling edges of button signals.

  ```verilog
  module edge_detector(
      input wire clk,
      input wire signal_in,
      output reg rising_edge,
      output reg falling_edge
  );
  ```

### Constraints Files:
- **constrs_1/new/boolean.xdc**:  
  Maps the Verilog signals to FPGA pins, ensuring correct hardware connections for LEDs, buttons, and the clock.

## Project Structure

```
project_4/
├── project_4.xpr                 # Vivado project file
├── README.md                     # Project documentation
├── sources_1/new/
│   ├── top.v                     # Top-level Verilog module
│   ├── rgb_control.v             # RGB control with color and toggle
│   ├── debounce.v                # Debouncing module
│   └── edge_detector.v           # Edge detection module
└── constrs_1/new/boolean.xdc     # Constraints file
```

## How to Use

1. **Open the project**:  
   Load `project_4.xpr` in Vivado 2024.1 to access and manage the design.

2. **Run Synthesis and Implementation**:  
   Use Vivado to synthesize and implement the design. After implementation, generate the bitstream and program the FPGA.

3. **Test the design**:  
   - Press Button 0 to toggle the RGB0 LED.
   - Press Button 1 to cycle RGB0 colors forward (red, green, blue).
   - Press Button 3 to cycle colors backward.
   - Press Button 2 to toggle the red component of RGB1.
