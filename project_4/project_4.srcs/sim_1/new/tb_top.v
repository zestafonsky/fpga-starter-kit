`timescale 1ns / 1ps

module tb_top;
    // Parameters for simulation
    parameter CLK_PERIOD = 10;  // Clock period in nanoseconds (e.g., 10 ns for 100 MHz)
    parameter SIMULATION_TIME = 1_000_000;  // Total simulation time in nanoseconds

    // Testbench signals
    reg clk;
    reg btn0;
    reg btn1;
    reg btn2;
    reg btn3;

    wire RGB0_R;
    wire RGB0_G;
    wire RGB0_B;
    wire RGB1_R;

    // Instantiate the top module
    top uut (
        .clk(clk),
        .btn0(btn0),
        .btn1(btn1),
        .btn2(btn2),
        .btn3(btn3),
        .RGB0_R(RGB0_R),
        .RGB0_G(RGB0_G),
        .RGB0_B(RGB0_B),
        .RGB1_R(RGB1_R)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;  // Toggle clock every half period
    end

    // Simulation of button presses and behavior
    initial begin
        // Initialize buttons to low state
        btn0 = 0;
        btn1 = 0;
        btn2 = 0;
        btn3 = 0;

        // Wait for some time before starting the test
        #(CLK_PERIOD * 10);

        // Test Case 1: Toggle RGB0 on and off using btn0
        press_button(btn0, 50);  // Press btn0 for 50 clock cycles
        #(CLK_PERIOD * 100);     // Wait for 100 clock cycles
        release_button(btn0);
        #(CLK_PERIOD * 100);

        // Test Case 2: Cycle RGB0 color forward using btn1
        press_button(btn1, 50);
        #(CLK_PERIOD * 100);
        release_button(btn1);
        #(CLK_PERIOD * 100);

        // Test Case 3: Cycle RGB0 color backward using btn3
        press_button(btn3, 50);
        #(CLK_PERIOD * 100);
        release_button(btn3);
        #(CLK_PERIOD * 100);

        // Test Case 4: Toggle RGB1 on and off using btn2
        press_button(btn2, 50);
        #(CLK_PERIOD * 100);
        release_button(btn2);
        #(CLK_PERIOD * 100);

        // Test Case 5: Rapid button presses on btn0
        repeat (5) begin
            press_button(btn0, 10);
            #(CLK_PERIOD * 20);
            release_button(btn0);
            #(CLK_PERIOD * 20);
        end

        // End simulation after a specified time
        #(SIMULATION_TIME);
        $finish;
    end

    // Task to simulate button press (holding for a duration)
    task press_button;
        inout reg btn;
        input integer duration;
        begin
            btn = 1;
            #(CLK_PERIOD * duration);  // Hold the button for the given duration
        end
    endtask

    // Task to simulate button release
    task release_button;
        inout reg btn;
        begin
            btn = 0;
        end
    endtask

    // Monitor outputs for debugging
    initial begin
        $monitor("Time: %dns | RGB0_R: %b, RGB0_G: %b, RGB0_B: %b | RGB1_R: %b",
                 $time, RGB0_R, RGB0_G, RGB0_B, RGB1_R);
    end

    // Dump waveforms for analysis
    initial begin
        $dumpfile("tb_top.vcd");
        $dumpvars(0, tb_top);
    end
endmodule