module rgb_control #(
    parameter COLOR_CHANGE = 1  // Enable (1) or disable (0) color change functionality
)(
    input wire clk,             // Clock input
    input wire btn0,            // Button to toggle LED
    input wire btn1,            // Button to change color forward (optional)
    input wire btn3,            // Button to change color backward (optional)
    output reg RGB_R,           // Red component of RGB LED
    output reg RGB_G,           // Green component of RGB LED
    output reg RGB_B            // Blue component of RGB LED
);
    // Internal signals
    wire btn0_debounced;
    wire btn1_debounced;
    wire btn3_debounced;

    wire btn0_released; // One-clock pulse when btn0 is released
    wire btn1_released; // One-clock pulse when btn1 is released
    wire btn3_released; // One-clock pulse when btn3 is released

    reg toggle_state = 1'b0;    // Toggle state for the LED
    reg [1:0] color_state = 2'b00; // Current color state

    // Instantiate debounce modules
    debounce db0 (.clk(clk), .btn_in(btn0), .btn_out(btn0_debounced));
    generate
        if (COLOR_CHANGE) begin
            debounce db1 (.clk(clk), .btn_in(btn1), .btn_out(btn1_debounced));
            debounce db3 (.clk(clk), .btn_in(btn3), .btn_out(btn3_debounced));
        end else begin
            assign btn1_debounced = 1'b0;
            assign btn3_debounced = 1'b0;
        end
    endgenerate

    // Instantiate edge detectors
    edge_detector ed0 (.clk(clk), .signal_in(btn0_debounced), .rising_edge(), .falling_edge(btn0_released));
    generate
        if (COLOR_CHANGE) begin
            edge_detector ed1 (.clk(clk), .signal_in(btn1_debounced), .rising_edge(), .falling_edge(btn1_released));
            edge_detector ed3 (.clk(clk), .signal_in(btn3_debounced), .rising_edge(), .falling_edge(btn3_released));
        end else begin
            assign btn1_released = 1'b0;
            assign btn3_released = 1'b0;
        end
    endgenerate

    // Toggle state control
    always @(posedge clk) begin
        if (btn0_released) begin
            toggle_state <= ~toggle_state;
        end
    end

    // Detect rising edge of toggle_state to reset color_state
    reg toggle_state_prev;
    always @(posedge clk) begin
        toggle_state_prev <= toggle_state;
    end

    wire toggle_state_rising_edge = (~toggle_state_prev) & toggle_state;

    // Color state control
    always @(posedge clk) begin
        if (toggle_state_rising_edge) begin
            // LED is being turned on; reset color_state to red
            color_state <= 2'b00;
        end else if (toggle_state) begin
            // LED is on; handle color changes
            if (COLOR_CHANGE) begin
                if (btn1_released) begin
                    color_state <= (color_state == 2'b10) ? 2'b00 : color_state + 1;
                end else if (btn3_released) begin
                    color_state <= (color_state == 2'b00) ? 2'b10 : color_state - 1;
                end
            end
        end
    end

    // Drive the RGB outputs based on the current color state
    always @(posedge clk) begin
        if (toggle_state) begin
            if (COLOR_CHANGE) begin
                case (color_state)
                    2'b00: {RGB_R, RGB_G, RGB_B} <= 3'b100; // Red
                    2'b01: {RGB_R, RGB_G, RGB_B} <= 3'b010; // Green
                    2'b10: {RGB_R, RGB_G, RGB_B} <= 3'b001; // Blue
                    default: {RGB_R, RGB_G, RGB_B} <= 3'b000; // Off
                endcase
            end else begin
                {RGB_R, RGB_G, RGB_B} <= 3'b100; // Only Red component
            end
        end else begin
            {RGB_R, RGB_G, RGB_B} <= 3'b000; // LED Off
        end
    end
endmodule
