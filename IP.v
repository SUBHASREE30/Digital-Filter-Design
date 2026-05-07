\TLV_version 1d: tl-x.org
\SV
// --- 4-TAP FIR FILTER MODULE ---
module fir_filter (
    input clk,
    input reset,
    input signed [7:0] x_in,   // 8-bit Signed Input
    output reg signed [15:0] y_out // 16-bit Signed Output
);
    // Filter Coefficients (Low-pass example)
    parameter signed [7:0] H0 = 8'd1;
    parameter signed [7:0] H1 = 8'd2;
    parameter signed [7:0] H2 = 8'd2;
    parameter signed [7:0] H3 = 8'd1;

    // Shift Register for Delay Taps
    reg signed [7:0] tap [0:3];

    always @(posedge clk) begin
        if (reset) begin
            y_out <= 16'd0;
            tap[0] <= 8'd0; tap[1] <= 8'd0; tap[2] <= 8'd0; tap[3] <= 8'd0;
        end else begin
            // Shift inputs (The "Pipeline" of the filter)
            tap[0] <= x_in;
            tap[1] <= tap[0];
            tap[2] <= tap[1];
            tap[3] <= tap[2];

            // Multiply and Accumulate (MAC)
            y_out <= (H0 * tap[0]) + (H1 * tap[1]) + (H2 * tap[2]) + (H3 * tap[3]);
        end
    end
endmodule

// Makerchip Top Module
module top (input clk, input reset, input [31:0] cyc_cnt, output passed, output failed);
    reg signed [7:0] x_in;
    wire signed [15:0] y_out;

    // Instantiate Filter
    fir_filter uut (
        .clk(clk),
        .reset(reset),
        .x_in(x_in),
        .y_out(y_out)
    );

    // Stimulus: Provide a varying signal
    always @(posedge clk) begin
        if (reset) x_in <= 8'd0;
        else begin
            // Pulse input to see the filter response
            if (cyc_cnt == 5)      x_in <= 8'd10;
            else if (cyc_cnt == 6) x_in <= 8'd20;
            else if (cyc_cnt == 7) x_in <= 8'd10;
            else                   x_in <= 8'd0;
        end
    end

    assign passed = (cyc_cnt > 32'd30);
    assign failed = 1'b0;
endmodule