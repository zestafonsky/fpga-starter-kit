`timescale 1ns / 1ps

module debounce(
    input wire clk,      // Clock input
    input wire btn_in,   // Raw button input
    output reg btn_out   // Debounced button output
);
    reg [15:0] cnt;
    reg btn_sync_0;
    reg btn_sync_1;

    // Synchronize the button input to the clock domain
    always @(posedge clk) begin
        btn_sync_0 <= btn_in;
        btn_sync_1 <= btn_sync_0;
    end

    // Debounce logic
    always @(posedge clk) begin
        if (btn_out == btn_sync_1) begin
            cnt <= 0;
        end else begin
            cnt <= cnt + 1;
            if (cnt == 16'hFFFF) begin
                btn_out <= btn_sync_1;
            end
        end
    end
endmodule
