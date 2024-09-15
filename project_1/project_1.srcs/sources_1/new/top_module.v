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
