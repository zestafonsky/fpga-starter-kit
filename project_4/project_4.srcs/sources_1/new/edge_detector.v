`timescale 1ns / 1ps

module edge_detector(
    input wire clk,           // Clock input
    input wire signal_in,     // Input signal to detect edges on
    output reg rising_edge,   // High for one clock cycle on rising edge
    output reg falling_edge   // High for one clock cycle on falling edge
);
    reg signal_delay;

    always @(posedge clk) begin
        signal_delay <= signal_in;
        rising_edge <= signal_in & ~signal_delay;
        falling_edge <= ~signal_in & signal_delay;
    end
endmodule
