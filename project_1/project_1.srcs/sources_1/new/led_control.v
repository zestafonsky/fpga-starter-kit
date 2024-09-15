module led_control(
    input wire btn0,        // Button 0 input
    output wire RGB0_R      // Red component of RGB0 LED
);
    assign RGB0_R = btn0;
endmodule
