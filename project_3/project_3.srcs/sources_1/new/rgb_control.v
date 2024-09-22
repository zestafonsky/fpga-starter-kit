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