`timescale 1ns / 1ps

module top(
    // Clock Inputs
    input wire clk_100MHz,      // 100 MHz clock input

    // Button Inputs
    input wire btn0,            // Button 0: Toggle RGB0 LED
    input wire btn1,            // Button 1: Change RGB0 color forward / Increment BPM
    input wire btn2,            // Button 2: Toggle LED shifting and RGB1 LED
    input wire btn3,            // Button 3: Change RGB0 color backward / Decrement BPM

    // Switch Inputs
    input wire [15:0] sw,       // 16 Switch inputs

    // LED Outputs
    output wire [15:0] led,     // 16 LED outputs

    // RGB LED Outputs
    output wire RGB0_R,         // Red component of RGB0 LED
    output wire RGB0_G,         // Green component of RGB0 LED
    output wire RGB0_B,         // Blue component of RGB0 LED
    output wire RGB1_R,         // Red component of RGB1 LED

    // 7-Segment Display Outputs
    output wire [7:0] D0_seg,   // Segments for Display0
    output wire [3:0] D0_a,     // Anodes for Display0
    output wire [7:0] D1_seg,   // Segments for Display1
    output wire [3:0] D1_a      // Anodes for Display1
);
    // =========================================================================
    // Parameters
    // =========================================================================
    parameter integer CLK_FREQ          = 100_000_000;    // 100 MHz

    // 7-Segment Display Control Parameters
    localparam integer MUX_DIV_FACTOR    = 50_000;      // ~1 kHz for multiplexing
    localparam integer SCROLL_DIV_FACTOR = 100_000_000; // ~0.5 Hz for scrolling

    // =========================================================================
    // Internal Signals
    // =========================================================================
    reg [15:0] bpm_reg = 16'd1400;           // Initialize BPM to 140.0 (tenths of BPM)

    // =========================================================================
    // Clock Dividers
    // =========================================================================
    wire clk_mux, clk_scroll;

    // Clock Divider for 7-Segment Display Multiplexing (~1 kHz)
    clock_divider #(
        .DIV_FACTOR(MUX_DIV_FACTOR)
    ) clk_div_display_mux (
        .clk_in(clk_100MHz),
        .clk_out(clk_mux)
    );

    // Clock Divider for 7-Segment Display Scrolling (~0.5 Hz)
    clock_divider #(
        .DIV_FACTOR(SCROLL_DIV_FACTOR)
    ) clk_div_display_scroll (
        .clk_in(clk_100MHz),
        .clk_out(clk_scroll)
    );

    // =========================================================================
    // Debounce Modules
    // =========================================================================
    wire btn0_debounced, btn1_debounced, btn2_debounced, btn3_debounced;

    debounce_btn db_btn0 (
        .clk(clk_100MHz),
        .signal_in(btn0),
        .signal_out(btn0_debounced)
    );

    debounce_btn db_btn1 (
        .clk(clk_100MHz),
        .signal_in(btn1),
        .signal_out(btn1_debounced)
    );

    debounce_btn db_btn2 (
        .clk(clk_100MHz),
        .signal_in(btn2),
        .signal_out(btn2_debounced)
    );

    debounce_btn db_btn3 (
        .clk(clk_100MHz),
        .signal_in(btn3),
        .signal_out(btn3_debounced)
    );

    // Switch Debouncers
    wire [15:0] sw_debounced;
    debounce_bus #(
        .WIDTH(16),
        .CNT_MAX(1_000_000)
    ) debounce_switches (
        .clk(clk_100MHz),
        .signal_in(sw),
        .signal_out(sw_debounced)
    );

    // =========================================================================
    // BPM Adjustment Logic
    // =========================================================================
    parameter integer BPM_INITIAL_DELAY = 50_000_000; // 0.5 seconds at 100MHz
    parameter integer BPM_REPEAT_RATE   = 1_000_000;  // Adjust every 0.01 seconds

    reg [31:0] btn_hold_counter = 0;
    reg [31:0] btn_repeat_counter = 0;
    reg btn_active = 0;
    wire [3:0] mode_select = sw_debounced[3:0];

    always @(posedge clk_100MHz) begin
        if (mode_select == 4'd3) begin // Only adjust BPM in mode 3
            if (btn1_debounced && !btn3_debounced) begin
                // Increase BPM
                if (!btn_active) begin
                    btn_active <= 1;
                    btn_hold_counter <= 0;
                    btn_repeat_counter <= 0;
                    bpm_reg <= bpm_reg < 16'd9999 ? bpm_reg + 1 : bpm_reg;
                end else begin
                    if (btn_hold_counter < BPM_INITIAL_DELAY) begin
                        btn_hold_counter <= btn_hold_counter + 1;
                    end else begin
                        btn_repeat_counter <= btn_repeat_counter + 1;
                        if (btn_repeat_counter >= BPM_REPEAT_RATE) begin
                            btn_repeat_counter <= 0;
                            bpm_reg <= bpm_reg + 10 <= 16'd9999 ? bpm_reg + 10 : 16'd9999;
                        end
                    end
                end
            end else if (btn3_debounced && !btn1_debounced) begin
                // Decrease BPM
                if (!btn_active) begin
                    btn_active <= 1;
                    btn_hold_counter <= 0;
                    btn_repeat_counter <= 0;
                    bpm_reg <= bpm_reg > 16'd0 ? bpm_reg - 1 : bpm_reg;
                end else begin
                    if (btn_hold_counter < BPM_INITIAL_DELAY) begin
                        btn_hold_counter <= btn_hold_counter + 1;
                    end else begin
                        btn_repeat_counter <= btn_repeat_counter + 1;
                        if (btn_repeat_counter >= BPM_REPEAT_RATE) begin
                            btn_repeat_counter <= 0;
                            bpm_reg <= bpm_reg >= 10 ? bpm_reg - 10 : 16'd0;
                        end
                    end
                end
            end else begin
                // No button or both pressed
                btn_active <= 0;
                btn_hold_counter <= 0;
                btn_repeat_counter <= 0;
            end
        end
    end

    // =========================================================================
    // RGB LED Controls
    // =========================================================================
    rgb_control u_rgb0 (
        .clk(clk_100MHz),
        .btn0(btn0_debounced),
        .btn1(btn1_debounced),
        .btn3(btn3_debounced),
        .RGB_R(RGB0_R),
        .RGB_G(RGB0_G),
        .RGB_B(RGB0_B)
    );

    // =========================================================================
    // RGB1 and LED Shift Control
    // =========================================================================
    reg rgb1_state = 0;        // Single state register for RGB1 LED
    reg shift_enable = 0;      // Enable signal for LED shifting

    // Edge detection for btn2 in clk_100MHz domain
    reg btn2_dly = 0;
    wire btn2_pulse = btn2_debounced & ~btn2_dly;

    always @(posedge clk_100MHz) begin
        btn2_dly <= btn2_debounced;
    end

    // Single control block for RGB1 and shift enable
    always @(posedge clk_100MHz) begin
        if (btn2_pulse) begin  // Rising edge detection
            rgb1_state <= ~rgb1_state;
            shift_enable <= ~shift_enable;
        end
    end

    // Single driver for RGB1_R
    assign RGB1_R = rgb1_state;

    // =========================================================================
    // LED Shift Register
    // =========================================================================
    wire [15:0] shift_mask_led;
    wire shift_pulse;
    
    // Parameters
    parameter integer STEPS_PER_BEAT = 4; // Steps per beat
    
    // BPM-Based Shift Pulse Generator
    reg [63:0] shift_counter = 0;
    wire [63:0] shift_interval;
    
    // Compute actual BPM from bpm_reg (in tenths of BPM)
    wire [63:0] bpm_actual = bpm_reg / 10;
    
    // Avoid division by zero
    wire [63:0] bpm_actual_nonzero = (bpm_actual == 0) ? 1 : bpm_actual;
    
    // Compute shift_interval directly to avoid truncation errors
    assign shift_interval = (CLK_FREQ * 60) / (bpm_actual_nonzero * STEPS_PER_BEAT);
    
    // Generate shift pulse
    reg shift_pulse_reg = 0;
    always @(posedge clk_100MHz) begin
        if (shift_enable) begin
            if (shift_counter >= shift_interval - 1) begin
                shift_counter <= 0;
                shift_pulse_reg <= 1;
            end else begin
                shift_counter <= shift_counter + 1;
                shift_pulse_reg <= 0;
            end
        end else begin
            shift_counter <= 0;
            shift_pulse_reg <= 0;
        end
    end
    
    assign shift_pulse = shift_pulse_reg;
    
    // Instantiate led_shift_register_main
    led_shift_register_main u_led_shift_main (
        .clk(clk_100MHz),
        .enable(shift_enable),
        .shift_pulse(shift_pulse),
        .shift_mask(shift_mask_led)
    );

    // =========================================================================
    // LED Output Assignment
    // =========================================================================
    assign led = shift_enable
                ? (sw_debounced ^ shift_mask_led)
                : sw_debounced;

    // =========================================================================
    // 7-Segment Display Control
    // =========================================================================
    wire [15:0] combined_letter_reg_display0, combined_letter_reg_display1;

    scroll_message scroll_msg (
        .clk(clk_scroll),
        .combined_letter_reg_display0(combined_letter_reg_display0),
        .combined_letter_reg_display1(combined_letter_reg_display1)
    );

    // Synchronization into clk_mux domain
    reg [35:0] sync_bus_clk_mux = 36'd0;
    wire [35:0] async_bus_clk_mux = {sw_debounced, mode_select, bpm_reg};
    always @(posedge clk_mux) begin
        sync_bus_clk_mux <= async_bus_clk_mux;
    end

    // Extract synchronized signals
    wire [15:0] sw_debounced_sync = sync_bus_clk_mux[35:20];
    wire [3:0] mode_select_sync = sync_bus_clk_mux[19:16];
    wire [15:0] bpm_value_sync = sync_bus_clk_mux[15:0];

    // Synchronize combined_letter_reg into clk_mux domain
    reg [15:0] combined_letter_reg_display0_sync = 16'd0;
    reg [15:0] combined_letter_reg_display1_sync = 16'd0;
    always @(posedge clk_mux) begin
        combined_letter_reg_display0_sync <= combined_letter_reg_display0;
        combined_letter_reg_display1_sync <= combined_letter_reg_display1;
    end

    display_controller disp0 (
        .clk_mux(clk_mux),
        .sw_debounced(sw_debounced_sync),
        .combined_letter_reg(combined_letter_reg_display0_sync),
        .mode_select(mode_select_sync),
        .display_id(1'b0),
        .bpm_value(bpm_value_sync),
        .seg(D0_seg),
        .anode(D0_a)
    );

    display_controller disp1 (
        .clk_mux(clk_mux),
        .sw_debounced(sw_debounced_sync),
        .combined_letter_reg(combined_letter_reg_display1_sync),
        .mode_select(mode_select_sync),
        .display_id(1'b1),
        .bpm_value(bpm_value_sync),
        .seg(D1_seg),
        .anode(D1_a)
    );

endmodule


// =============================================================================
// Parameterized Clock Divider Module
// =============================================================================

module clock_divider #(
    parameter integer DIV_FACTOR = 1
)(
    input wire clk_in,
    output reg clk_out = 0
);
    reg [$clog2(DIV_FACTOR)-1:0] count = 0;

    always @(posedge clk_in) begin
        if (count >= (DIV_FACTOR - 1)) begin
            count <= 0;
            clk_out <= ~clk_out; // Toggle clock output
        end else begin
            count <= count + 1;
        end
    end
endmodule

// =============================================================================
// Debounce Modules
// =============================================================================

/// Debounce Module for Buttons
module debounce_btn(
    input wire clk,          // Clock input
    input wire signal_in,    // Raw button signal
    output reg signal_out    // Debounced signal
);
    reg [19:0] cnt = 0;                // 20-bit counter (~10 ms at 100 MHz)
    reg signal_sync_0 = 1'b0,
        signal_sync_1 = 1'b0;

    // Synchronize the input signal to prevent metastability
    always @(posedge clk) begin
        signal_sync_0 <= signal_in;
        signal_sync_1 <= signal_sync_0;
    end

    // Debounce Logic
    always @(posedge clk) begin
        if (signal_out == signal_sync_1) begin
            cnt <= 0;
        end else begin
            cnt <= cnt + 1;
            if (cnt == 20'd1_000_000) begin // Adjust debounce duration as needed
                signal_out <= signal_sync_1;
                cnt <= 0;
            end
        end
    end
endmodule

/// Debounce Module for Bus Signals
module debounce_bus #(
    parameter WIDTH = 16,
    parameter CNT_MAX = 1_000_000  // Adjust as needed
)(
    input wire clk,
    input wire [WIDTH-1:0] signal_in,
    output reg [WIDTH-1:0] signal_out
);
    reg [WIDTH-1:0] signal_sync_0 = {WIDTH{1'b0}};
    reg [WIDTH-1:0] signal_sync_1 = {WIDTH{1'b0}};
    reg [19:0] cnt [WIDTH-1:0];  // Assuming 20 bits is sufficient

    integer i;
    always @(posedge clk) begin
        signal_sync_0 <= signal_in;
        signal_sync_1 <= signal_sync_0;
        for (i = 0; i < WIDTH; i = i + 1) begin
            if (signal_out[i] == signal_sync_1[i]) begin
                cnt[i] <= 0;
            end else begin
                cnt[i] <= cnt[i] + 1;
                if (cnt[i] == CNT_MAX) begin
                    signal_out[i] <= signal_sync_1[i];
                    cnt[i] <= 0;
                end
            end
        end
    end
endmodule

// =============================================================================
// RGB Control Module
// =============================================================================

/// RGB Control Module
module rgb_control #(
    parameter COLOR_CHANGE = 1 // Enable (1) or disable (0) color change functionality
)(
    input wire clk,
    input wire btn0,            // Toggle signal
    input wire btn1,            // Color forward
    input wire btn3,            // Color backward
    output reg RGB_R,
    output reg RGB_G,
    output reg RGB_B
);
    // Internal Signals
    reg btn0_dly = 0, btn1_dly = 0, btn3_dly = 0;
    wire btn0_pulse = btn0 & ~btn0_dly;
    wire btn1_pulse = btn1 & ~btn1_dly;
    wire btn3_pulse = btn3 & ~btn3_dly;

    // Update delay registers
    always @(posedge clk) begin
        btn0_dly <= btn0;
        btn1_dly <= btn1;
        btn3_dly <= btn3;
    end

    // Toggle and Color State
    reg toggle = 1'b0;
    reg [1:0] color = 2'b00;

    always @(posedge clk) begin
        // Toggle RGB0 LED
        if (btn0_pulse)
            toggle <= ~toggle;

        // Handle Color Changes
        if (toggle) begin
            if (COLOR_CHANGE) begin
                if (btn1_pulse)
                    color <= (color == 2'b10) ? 2'b00 : color + 1;
                if (btn3_pulse)
                    color <= (color == 2'b00) ? 2'b10 : color - 1;
            end else begin
                color <= 2'b00; // Fixed color if COLOR_CHANGE is disabled
            end
        end else begin
            color <= 2'b00; // Reset color when toggled off
        end
    end

    // RGB Output Control
    always @(posedge clk) begin
        if (toggle) begin
            case (color)
                2'b00: {RGB_R, RGB_G, RGB_B} <= 3'b100; // Red
                2'b01: {RGB_R, RGB_G, RGB_B} <= 3'b010; // Green
                2'b10: {RGB_R, RGB_G, RGB_B} <= 3'b001; // Blue
                default: {RGB_R, RGB_G, RGB_B} <= 3'b000; // Off
            endcase
        end else begin
            {RGB_R, RGB_G, RGB_B} <= 3'b000; // LED Off
        end
    end
endmodule

// =============================================================================
// LED Shift Register Module for Main LEDs
// =============================================================================

/// LED Shift Register Module (Right Shift)
module led_shift_register_main(
    input wire clk,
    input wire enable,
    input wire shift_pulse,
    output reg [15:0] shift_mask = 16'h0000
);
    always @(posedge clk) begin
        if (!enable) begin
            shift_mask <= 16'h0000;  // Clear mask when disabled
        end else if (shift_pulse) begin
            if (shift_mask == 16'h0000) begin
                shift_mask <= 16'h8000;  // Start with MSB
            end else begin
                shift_mask <= {shift_mask[0], shift_mask[15:1]}; // Rotate right
            end
        end
    end
endmodule

// =============================================================================
// Scroll Message Module
// =============================================================================

/// Scroll Message Module
module scroll_message(
    input clk,
    output reg [15:0] combined_letter_reg_display0,
    output reg [15:0] combined_letter_reg_display1
);
    // Scroll Buffer Parameters
    reg [3:0] scroll_buffer [0:19]; // 20-character buffer
    reg [4:0] scroll_index = 0;     // Scroll index (0-19)
    integer i;

    // Initialize the scroll buffer with character codes directly
    initial begin
        // Character Mapping:
        // A=0, b=1, C=2, d=3, E=4, F=5, H=6, I=7, L=8, P=9, U=10, O=11,
        // Space=12, Dot=13, W=14, R=15
        scroll_buffer[0]  = 4'd6;   // H
        scroll_buffer[1]  = 4'd4;   // E
        scroll_buffer[2]  = 4'd8;   // L
        scroll_buffer[3]  = 4'd8;   // L
        scroll_buffer[4]  = 4'd11;  // O
        scroll_buffer[5]  = 4'd12;  // Space
        scroll_buffer[6]  = 4'd9;   // P
        scroll_buffer[7]  = 4'd4;   // E
        scroll_buffer[8]  = 4'd11;  // O
        scroll_buffer[9]  = 4'd9;   // P
        scroll_buffer[10] = 4'd8;   // L
        scroll_buffer[11] = 4'd4;   // E
        scroll_buffer[12] = 4'd13;  // Dot
        scroll_buffer[13] = 4'd13;  // Dot
        scroll_buffer[14] = 4'd13;  // Dot
        scroll_buffer[15] = 4'd13;  // Dot
        scroll_buffer[16] = 4'd12;  // Space
        scroll_buffer[17] = 4'd12;  // Space
        scroll_buffer[18] = 4'd12;  // Space
        scroll_buffer[19] = 4'd12;  // Space
    end

    reg [3:0] char [0:7];

    always @(posedge clk) begin
        // Increment scroll index with wrap-around
        if (scroll_index >= 19)
            scroll_index <= 0;
        else
            scroll_index <= scroll_index + 1;

        // Populate characters for display
        for (i = 0; i < 8; i = i + 1) begin
            if ((scroll_index + i) <= 19)
                char[i] <= scroll_buffer[scroll_index + i];
            else
                char[i] <= scroll_buffer[scroll_index + i - 20];
        end

        // Combine characters for Display0 and Display1
        combined_letter_reg_display0 <= {char[0], char[1], char[2], char[3]};
        combined_letter_reg_display1 <= {char[4], char[5], char[6], char[7]};
    end
endmodule

// =============================================================================
// Display Controller Module
// =============================================================================

/// Display Controller Module
module display_controller(
    input clk_mux,
    input [15:0] sw_debounced,
    input [15:0] combined_letter_reg,
    input [3:0] mode_select,
    input display_id,              // 0 for Display0, 1 for Display1
    input [15:0] bpm_value,        // BPM value input
    output [7:0] seg,
    output [3:0] anode
);
    // Internal Signals
    reg [15:0] display_number, display_letters;
    reg mode; // 0 = number mode, 1 = letter mode
    reg [3:0] point_location;
    reg enable_display;

    // Binary value limited to 9999
    wire [13:0] binary_value = sw_debounced[13:0];
    wire [13:0] binary_value_limited = (binary_value > 14'd9999) ? 14'd9999 : binary_value;

    // Convert binary to BCD
    wire [15:0] BCD_value;
    binary_to_BCD bin2bcd (
        .binary_in(binary_value_limited),
        .BCD_out(BCD_value)
    );

    // Limit bpm_value to 14 bits
    wire [13:0] bpm_value_limited = (bpm_value > 14'd9999) ? 14'd9999 : bpm_value[13:0];

    // Convert bpm_value to BCD
    wire [15:0] bpm_BCD_value;
    binary_to_BCD bin2bcd_bpm (
        .binary_in(bpm_value_limited),
        .BCD_out(bpm_BCD_value)
    );

    always @(*) begin
        // Default assignments
        display_number    = 16'hFFFF;
        display_letters   = 16'hFFFF;
        mode              = 1'b0;
        point_location    = 4'b0000;
        enable_display    = 1'b1; // Default enable

        if (display_id == 1'b0) begin
            // Display0 Modes
            case (mode_select)
                4'd5: begin
                    display_letters = combined_letter_reg;
                    mode = 1'b1; // Letter mode
                end
                default: begin
                    display_number = BCD_value;
                end
            endcase
        end else begin
            // Display1 Modes
            case (mode_select)
                4'd0: enable_display = 1'b0; // Disable display
                4'd1: display_number = 16'h0000; // Display '0000'
                4'd2: begin
                    display_letters = {4'd12, 4'd8, 4'd11, 4'd8}; // 'OLOL'
                    mode = 1'b1;
                end
                4'd3: begin
                    display_number = bpm_BCD_value; // Display BPM value
                    point_location = 4'b0010;   // Decimal point on second digit
                end
                4'd4, 4'd5: begin
                    display_letters = combined_letter_reg;
                    mode = 1'b1;
                end
                default: enable_display = 1'b0; // Blank display
            endcase
        end
    end

    // Instantiate Seven Segment Display Module
    seven_segment_display ssd (
        .clk_mux(clk_mux),
        .number(display_number),
        .letters(display_letters),
        .mode(mode),
        .point_location(point_location),
        .enable(enable_display),
        .seg(seg),
        .anode(anode)
    );

endmodule

// =============================================================================
// Binary to BCD Conversion Module
// =============================================================================

/// Binary to BCD Conversion Module
module binary_to_BCD(
    input [13:0] binary_in,    // 14-bit binary input
    output reg [15:0] BCD_out  // 4 BCD digits (each 4 bits)
);
    integer i;
    reg [29:0] shift_reg; // 30-bit shift register

    always @(*) begin
        // Initialize shift register with binary input
        shift_reg = 30'd0;
        shift_reg[13:0] = binary_in;

        // Perform double Dabble algorithm for binary to BCD conversion
        for (i = 0; i < 14; i = i + 1) begin
            if (shift_reg[17:14] >= 5)
                shift_reg[17:14] = shift_reg[17:14] + 3;
            if (shift_reg[21:18] >= 5)
                shift_reg[21:18] = shift_reg[21:18] + 3;
            if (shift_reg[25:22] >= 5)
                shift_reg[25:22] = shift_reg[25:22] + 3;
            if (shift_reg[29:26] >= 5)
                shift_reg[29:26] = shift_reg[29:26] + 3;
            shift_reg = shift_reg << 1;
        end

        // Assign BCD output
        BCD_out[15:12] = shift_reg[29:26]; // Thousands
        BCD_out[11:8]  = shift_reg[25:22]; // Hundreds
        BCD_out[7:4]   = shift_reg[21:18]; // Tens
        BCD_out[3:0]   = shift_reg[17:14]; // Ones
    end
endmodule

// =============================================================================
// Seven Segment Display Module
// =============================================================================

/// Seven Segment Display Module
module seven_segment_display(
    input clk_mux,                // Multiplexing clock signal (~1 kHz)
    input [15:0] number,          // BCD number to display
    input [15:0] letters,         // Letters to display
    input mode,                   // Mode: 0 = digits, 1 = letters
    input [3:0] point_location,   // Decimal point locations
    input enable,                 // Enable display
    output reg [7:0] seg,         // Segment outputs
    output reg [3:0] anode        // Anode outputs
);
    // Internal Registers
    reg [1:0] anode_sel = 0;
    reg [7:0] seg_code;
    reg [3:0] digit, letter_code;

    always @(posedge clk_mux) begin
        anode_sel <= anode_sel + 1;

        if (enable) begin
            // Select the active anode
            case (anode_sel)
                2'b00: anode <= 4'b1110;
                2'b01: anode <= 4'b1101;
                2'b10: anode <= 4'b1011;
                2'b11: anode <= 4'b0111;
            endcase

            if (mode) begin
                // Letter Mode
                case (anode_sel)
                    2'b00: letter_code = letters[3:0];
                    2'b01: letter_code = letters[7:4];
                    2'b10: letter_code = letters[11:8];
                    2'b11: letter_code = letters[15:12];
                endcase

                // Segment Code for Letters
                case (letter_code)
                    4'd0:  seg_code = 8'b10001000; // A
                    4'd1:  seg_code = 8'b10000011; // b
                    4'd2:  seg_code = 8'b11000110; // C
                    4'd3:  seg_code = 8'b10100001; // d
                    4'd4:  seg_code = 8'b10000110; // E
                    4'd5:  seg_code = 8'b10001110; // F
                    4'd6:  seg_code = 8'b10001001; // H
                    4'd7:  seg_code = 8'b11111001; // I
                    4'd8:  seg_code = 8'b11000111; // L
                    4'd9:  seg_code = 8'b10001100; // P
                    4'd10: seg_code = 8'b11000001; // U
                    4'd11: seg_code = 8'b11000000; // O
                    4'd12: seg_code = 8'b11111111; // Space
                    4'd13: seg_code = 8'b11111111; // Dot (DP handled separately)
                    4'd14: seg_code = 8'b10001101; // W
                    4'd15: seg_code = 8'b10100100; // R
                    default: seg_code = 8'b11111111; // Blank
                endcase

                // Handle Decimal Point for 'Dot'
                if (letter_code == 4'd13)
                    seg_code[7] = 1'b0; // Turn on decimal point
                else
                    seg_code[7] = 1'b1; // Turn off decimal point

            end else begin
                // Number Mode
                case (anode_sel)
                    2'b00: digit = number[3:0];
                    2'b01: digit = number[7:4];
                    2'b10: digit = number[11:8];
                    2'b11: digit = number[15:12];
                endcase

                // Segment Code for Numbers
                case (digit)
                    4'd0: seg_code = 8'b11000000; // 0
                    4'd1: seg_code = 8'b11111001; // 1
                    4'd2: seg_code = 8'b10100100; // 2
                    4'd3: seg_code = 8'b10110000; // 3
                    4'd4: seg_code = 8'b10011001; // 4
                    4'd5: seg_code = 8'b10010010; // 5
                    4'd6: seg_code = 8'b10000010; // 6
                    4'd7: seg_code = 8'b11111000; // 7
                    4'd8: seg_code = 8'b10000000; // 8
                    4'd9: seg_code = 8'b10010000; // 9
                    default: seg_code = 8'b11111111; // Blank
                endcase

                // Handle Decimal Points
                case (anode_sel)
                    2'b00: seg_code[7] = point_location[0] ? 1'b0 : 1'b1;
                    2'b01: seg_code[7] = point_location[1] ? 1'b0 : 1'b1;
                    2'b10: seg_code[7] = point_location[2] ? 1'b0 : 1'b1;
                    2'b11: seg_code[7] = point_location[3] ? 1'b0 : 1'b1;
                endcase
            end

            // Assign segment code to output
            seg <= seg_code;
        end else begin
            // Disable all displays if not enabled
            anode <= 4'b1111;
            seg <= 8'b11111111;
        end
    end
endmodule
