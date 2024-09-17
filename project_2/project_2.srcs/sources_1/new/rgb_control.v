module rgb_control(
    input wire btn,        // Button input
    output wire RGB_R      // Red component of RGB LED
);
    assign RGB_R = btn;
endmodule
