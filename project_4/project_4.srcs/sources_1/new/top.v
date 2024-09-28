`timescale 1ns / 1ps

module top(
    input wire clk,           // Clock input
    input wire btn0,          // Button 0 input (toggle RGB0 LED)
    input wire btn1,          // Button 1 input (change RGB0 color forward)
    input wire btn2,          // Button 2 input (toggle RGB1 LED)
    input wire btn3,          // Button 3 input (change RGB0 color backward)
    output wire RGB0_R,       // Red component of RGB0 LED
    output wire RGB0_G,       // Green component of RGB0 LED
    output wire RGB0_B,       // Blue component of RGB0 LED
    output wire RGB1_R        // Red component of RGB1 LED
);
    // Instantiate the rgb_control module for RGB0 with color control
    rgb_control u_rgb_control_0 (
        .clk(clk),
        .btn0(btn0),
        .btn1(btn1),
        .btn3(btn3),          // Added btn3 for reverse color control
        .RGB_R(RGB0_R),
        .RGB_G(RGB0_G),
        .RGB_B(RGB0_B)
    );

    // Instantiate the rgb_control module for RGB1 (only red control, no color change)
    rgb_control u_rgb_control_1 (
        .clk(clk),
        .btn0(btn2),
        .btn1(1'b0),          // No color change functionality for RGB1
        .btn3(1'b0),          // No reverse color change functionality for RGB1
        .RGB_R(RGB1_R),
        .RGB_G(),             // Unused
        .RGB_B()              // Unused
    );
endmodule