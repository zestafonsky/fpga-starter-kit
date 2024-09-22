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