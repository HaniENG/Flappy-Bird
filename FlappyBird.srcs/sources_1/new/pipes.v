module pipes(
    input clk,
    input reset,
    input frame_tick,
    input mode_frenzy,
    input [9:0] vcount,
    output reg [9:0] pipe_x0, pipe_x0_right,
    output reg [9:0] pipe_x1, pipe_x1_right,
    output reg [9:0] pipe_x2, pipe_x2_right,
    output reg [9:0] gap_top0, gap_bottom0,
    output reg [9:0] gap_top1, gap_bottom1,
    output reg [9:0] gap_top2, gap_bottom2
);

// 12-bit signed: covers -2048..2047 (x2 starts at 1176, needs > 1023)
reg signed [11:0] x0, x1, x2;
wire signed [11:0] right0 = x0 + 12'sd32;
wire signed [11:0] right1 = x1 + 12'sd32;
wire signed [11:0] right2 = x2 + 12'sd32;

// 16-bit Fibonacci LFSR — runs every clock, used as random source on pipe reset
reg [15:0] lfsr = 16'hACE1;
always @(posedge clk)
    lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};

// Random gap_top in [80..207]; gap_bottom = gap_top + 150 → [230..357], both within 480
wire [9:0] rand_top = 10'd80 + {3'b0, lfsr[6:0]};

reg updated_this_blank;

always @(posedge clk) begin
    if (reset) begin
        // Three pipes spaced 268 px apart, all starting off-screen right
        x0 <= 12'sd640;
        x1 <= 12'sd908;    // 640 + 268
        x2 <= 12'sd1176;   // 640 + 536
        pipe_x0 <= 10'd700; pipe_x0_right <= 10'd700;
        pipe_x1 <= 10'd700; pipe_x1_right <= 10'd700;
        pipe_x2 <= 10'd700; pipe_x2_right <= 10'd700;
        gap_top0 <= 10'd150; gap_bottom0 <= 10'd300;
        gap_top1 <= 10'd150; gap_bottom1 <= 10'd300;
        gap_top2 <= 10'd150; gap_bottom2 <= 10'd300;
        updated_this_blank <= 1'b0;
    end else begin
        // ---- Output clamping (every cycle, no tearing) ----
        // x >= 640 : off screen right → hide
        // right <= 0: off screen left  → hide
        // x < 0, right > 0: partially visible at left edge
        // else: normal

        // Pipe 0
        if (right0 <= 12'sd0 || x0 >= 12'sd640) begin
            pipe_x0 <= 10'd700; pipe_x0_right <= 10'd700;
        end else if (x0 < 12'sd0) begin
            pipe_x0 <= 10'd0;   pipe_x0_right <= right0[9:0];
        end else begin
            pipe_x0 <= x0[9:0]; pipe_x0_right <= right0[9:0];
        end

        // Pipe 1
        if (right1 <= 12'sd0 || x1 >= 12'sd640) begin
            pipe_x1 <= 10'd700; pipe_x1_right <= 10'd700;
        end else if (x1 < 12'sd0) begin
            pipe_x1 <= 10'd0;   pipe_x1_right <= right1[9:0];
        end else begin
            pipe_x1 <= x1[9:0]; pipe_x1_right <= right1[9:0];
        end

        // Pipe 2
        if (right2 <= 12'sd0 || x2 >= 12'sd640) begin
            pipe_x2 <= 10'd700; pipe_x2_right <= 10'd700;
        end else if (x2 < 12'sd0) begin
            pipe_x2 <= 10'd0;   pipe_x2_right <= right2[9:0];
        end else begin
            pipe_x2 <= x2[9:0]; pipe_x2_right <= right2[9:0];
        end

        // ---- Position update: vblank only, once per frame ----
        if (vcount < 10'd480) begin
            updated_this_blank <= 1'b0;
        end else if (!updated_this_blank) begin
            updated_this_blank <= 1'b1;

            x0 <= x0 - 12'sd2;
            x1 <= x1 - 12'sd2;
            x2 <= x2 - 12'sd2;

            // When right edge of a pipe would be fully off screen next step,
            // reset it to 268 px ahead of the furthest remaining pipe
            if (right0 - 12'sd2 <= 12'sd0) begin
                x0          <= ((x1 > x2) ? x1 : x2) + 12'sd268;
                gap_top0    <= rand_top;
                gap_bottom0 <= rand_top + 10'd150;
            end
            if (right1 - 12'sd2 <= 12'sd0) begin
                x1          <= ((x0 > x2) ? x0 : x2) + 12'sd268;
                gap_top1    <= rand_top;
                gap_bottom1 <= rand_top + 10'd150;
            end
            if (right2 - 12'sd2 <= 12'sd0) begin
                x2          <= ((x0 > x1) ? x0 : x1) + 12'sd268;
                gap_top2    <= rand_top;
                gap_bottom2 <= rand_top + 10'd150;
            end
        end
    end
end

endmodule
