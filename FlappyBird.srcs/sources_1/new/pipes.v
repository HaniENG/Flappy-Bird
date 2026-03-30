module pipes(
    input clk,
    input reset,
    input frame_tick,
    input mode_frenzy,
    input [9:0] vcount,
    output reg [9:0] pipe_x0, pipe_x0_right,
    output reg [9:0] pipe_x1, pipe_x1_right,
    output reg [9:0] pipe_x2, pipe_x2_right,
    output reg [9:0] pipe_x3, pipe_x3_right,
    output reg [9:0] gap_top0, gap_bottom0,
    output reg [9:0] gap_top1, gap_bottom1,
    output reg [9:0] gap_top2, gap_bottom2,
    output reg [9:0] gap_top3, gap_bottom3
);

// 12-bit signed: covers -2048..2047
reg signed [11:0] x0, x1, x2, x3;
wire signed [11:0] right0 = x0 + 12'sd32;
wire signed [11:0] right1 = x1 + 12'sd32;
wire signed [11:0] right2 = x2 + 12'sd32;
wire signed [11:0] right3 = x3 + 12'sd32;

// Global max of all four positions.
// The exiting pipe is always the minimum so max_all == max of the other three.
wire signed [11:0] m01    = (x0 > x1) ? x0 : x1;
wire signed [11:0] m23    = (x2 > x3) ? x2 : x3;
wire signed [11:0] max_all = (m01 > m23) ? m01 : m23;

// 16-bit Fibonacci LFSR — random source for gap positions
reg [15:0] lfsr = 16'hACE1;
always @(posedge clk)
    lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};

// gap_top in [80..207]; gap_bottom = gap_top + 150 → [230..357]
wire [9:0] rand_top = 10'd80 + {3'b0, lfsr[6:0]};

// Spawn position: natural = max_all + 160, but clamp to minimum 640 so pipes
// always enter from off-screen right and slide in smoothly (no pop-in).
wire signed [11:0] next_spawn = (next_spawn < 12'sd640) ? 12'sd640 : next_spawn;

reg updated_this_blank;

always @(posedge clk) begin
    if (reset) begin
        x0 <= 12'sd640;
        x1 <= 12'sd800;
        x2 <= 12'sd960;
        x3 <= 12'sd1120;
        pipe_x0 <= 10'd700; pipe_x0_right <= 10'd700;
        pipe_x1 <= 10'd700; pipe_x1_right <= 10'd700;
        pipe_x2 <= 10'd700; pipe_x2_right <= 10'd700;
        pipe_x3 <= 10'd700; pipe_x3_right <= 10'd700;
        gap_top0 <= 10'd150; gap_bottom0 <= 10'd300;
        gap_top1 <= 10'd150; gap_bottom1 <= 10'd300;
        gap_top2 <= 10'd150; gap_bottom2 <= 10'd300;
        gap_top3 <= 10'd150; gap_bottom3 <= 10'd300;
        updated_this_blank <= 1'b0;
    end else begin
        // ---- Output clamping (every cycle) ----
        if (right0 <= 12'sd0 || x0 >= 12'sd640) begin
            pipe_x0 <= 10'd700; pipe_x0_right <= 10'd700;
        end else if (x0 < 12'sd0) begin
            pipe_x0 <= 10'd0;   pipe_x0_right <= right0[9:0];
        end else begin
            pipe_x0 <= x0[9:0]; pipe_x0_right <= right0[9:0];
        end

        if (right1 <= 12'sd0 || x1 >= 12'sd640) begin
            pipe_x1 <= 10'd700; pipe_x1_right <= 10'd700;
        end else if (x1 < 12'sd0) begin
            pipe_x1 <= 10'd0;   pipe_x1_right <= right1[9:0];
        end else begin
            pipe_x1 <= x1[9:0]; pipe_x1_right <= right1[9:0];
        end

        if (right2 <= 12'sd0 || x2 >= 12'sd640) begin
            pipe_x2 <= 10'd700; pipe_x2_right <= 10'd700;
        end else if (x2 < 12'sd0) begin
            pipe_x2 <= 10'd0;   pipe_x2_right <= right2[9:0];
        end else begin
            pipe_x2 <= x2[9:0]; pipe_x2_right <= right2[9:0];
        end

        if (right3 <= 12'sd0 || x3 >= 12'sd640) begin
            pipe_x3 <= 10'd700; pipe_x3_right <= 10'd700;
        end else if (x3 < 12'sd0) begin
            pipe_x3 <= 10'd0;   pipe_x3_right <= right3[9:0];
        end else begin
            pipe_x3 <= x3[9:0]; pipe_x3_right <= right3[9:0];
        end

        // ---- Position update: vblank only, once per frame ----
        if (vcount < 10'd480) begin
            updated_this_blank <= 1'b0;
        end else if (!updated_this_blank) begin
            updated_this_blank <= 1'b1;

            x0 <= x0 - 12'sd2;
            x1 <= x1 - 12'sd2;
            x2 <= x2 - 12'sd2;
            x3 <= x3 - 12'sd2;

            if (right0 - 12'sd2 <= 12'sd0) begin
                x0          <= next_spawn;
                gap_top0    <= rand_top;
                gap_bottom0 <= rand_top + 10'd150;
            end
            if (right1 - 12'sd2 <= 12'sd0) begin
                x1          <= next_spawn;
                gap_top1    <= rand_top;
                gap_bottom1 <= rand_top + 10'd150;
            end
            if (right2 - 12'sd2 <= 12'sd0) begin
                x2          <= next_spawn;
                gap_top2    <= rand_top;
                gap_bottom2 <= rand_top + 10'd150;
            end
            if (right3 - 12'sd2 <= 12'sd0) begin
                x3          <= next_spawn;
                gap_top3    <= rand_top;
                gap_bottom3 <= rand_top + 10'd150;
            end
        end
    end
end

endmodule
