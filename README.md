
# FPGA Development Series - Boolean Board (Spartan-7, FPGA)

This series of personal research projects is designed to guide users through developing FPGA designs using the Boolean Board (Spartan-7, FPGA) and Vivado 2024.1. The projects cover key topics such as synthesis, implementation, I/O control, clock-driven designs, button debouncing, and RGB LED management. Each project builds on the previous one, offering a structured approach for self-guided learning and experimentation with FPGA development.

## Supported Board
- **Boolean Spartan-7 development board**  
  - Part Number: xc7s50csga342-1
  - Family: Spartan-7
  - Package: ccsga324
  - Speed Grade: -1
  - Temperature Grade: C

## Reference Materials
- [Download Vivado 2024.1](https://www.xilinx.com/support/download.html)
- Vivado 2024.1 installation notes

## Setup Instructions
Clone or download this repository to your computer. It's recommended to store the files in a folder path containing only ASCII characters and avoid deeply nested paths, as Windows systems limit the maximum file path length to 260 characters.

## Hardware Setup
1. Connect "PROG UART" port on the Boolean Board to your computer with a micro-USB cable.
2. Turn on the board using the switch in the top-left corner. A green LED will light up when powered on.

---

## Projects Overview

### **Project 1: Simple LED Control with Button Press**
This project introduces the basics of using the Vivado IDE to create a simple HDL design where pressing Button 0 directly controls the state of an on-board LED. The red component of the RGB LED (RGB0_R) lights up when the button is pressed and turns off when the button is released. This project is ideal for understanding basic input/output interaction with the Boolean Board.


### **Project 2: Button-Controlled RGB LEDs**
Building on the first project, this design adds control for two on-board RGB LEDs (red components) using two buttons. The project introduces modular design, allowing for separate input/output control for each LED and button, making it a great next step for expanding I/O functionality.


### **Project 3: Debouncing and Toggle Mechanism**
This project introduces a clock-driven design for controlling two RGB LEDs using buttons, along with a simple debouncing mechanism. The design emphasizes toggling the state of the LEDs upon button press, ensuring stable input handling using clock-based debouncing.


### **Project 4: RGB LED Color Cycling with Reverse Control**
In this project, you will control RGB0's red, green, and blue colors through button presses, allowing for forward and reverse cycling. Button 0 toggles the LED, Button 1 cycles the color forward, and Button 3 cycles the color backward. RGB1 retains simple red LED control using Button 2.

