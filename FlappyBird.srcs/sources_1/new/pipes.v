module pipes(
    input clk,
    input reset,
    input frame_tick,
    input mode_frenzy,
    input [9:0] vcount,
    output reg [9:0] pipe_x0,
    output reg [9:0] pipe_x0_right,
    output reg [9:0] pipe_x1,
    output reg [9:0] pipe_x1_right,
    output reg [9:0] gap_top0,
    output reg [9:0] gap_bottom0,
    output reg [9:0] gap_top1,
    output reg [9:0] gap_bottom1
);

// 11-bit signed so we can track positions below zero without wrapping
reg signed [10:0] x0;
reg signed [10:0] x1;

// Right edge = left + 32, computed as signed so we can detect fully off-screen
wire signed [10:0] right0 = x0 + 11'sd32;
wire signed [10:0] right1 = x1 + 11'sd32;

// One-shot flag: update exactly once per vertical blank period
reg updated_this_blank;

always @(posedge clk) begin
    if (reset) begin
        x0                 <= 11'sd640;
        x1                 <= 11'sd975;   // 640 + 335 spacing
        pipe_x0            <= 10'd640;
        pipe_x0_right      <= 10'd672;
        pipe_x1            <= 10'd975;
        pipe_x1_right      <= 10'd1007;
        gap_top0           <= 10'd150;
        gap_bottom0        <= 10'd300;
        gap_top1           <= 10'd150;
        gap_bottom1        <= 10'd300;
        updated_this_blank <= 1'b0;
    end else begin
        // --------------------------------------------------
        // Smooth left-edge exit via right-edge clipping:
        //   right <= 0 : fully off left screen  -> hide (700)
        //   x < 0, right > 0 : partially visible -> left=0, right=right
        //   x >= 0 : normal
        // --------------------------------------------------
        pipe_x0       <= (right0 <= 11'sd0) ? 10'd700 :
                         (x0     <  11'sd0) ? 10'd0   : x0[9:0];
        pipe_x0_right <= (right0 <= 11'sd0) ? 10'd700 : right0[9:0];

        pipe_x1       <= (right1 <= 11'sd0) ? 10'd700 :
                         (x1     <  11'sd0) ? 10'd0   : x1[9:0];
        pipe_x1_right <= (right1 <= 11'sd0) ? 10'd700 : right1[9:0];

        // --------------------------------------------------
        // Move pipes ONLY during vertical blanking (vcount >= 480)
        // Ensures pipe_x never changes while screen is being drawn
        // --------------------------------------------------
        if (vcount < 10'd480) begin
            updated_this_blank <= 1'b0;
        end else if (!updated_this_blank) begin
            updated_this_blank <= 1'b1;

            // Default: move both left by 2
            x0 <= x0 - 11'sd2;
            x1 <= x1 - 11'sd2;

            // Reset pipe0 once fully off-screen, relative to pipe1
            // Threshold: next step would make right edge <= 0
            if (x0 - 11'sd2 + 11'sd32 <= 11'sd0) begin
                x0          <= x1 + 11'sd335;
                gap_top0    <= 10'd150;
                gap_bottom0 <= 10'd300;
            end

            // Reset pipe1 once fully off-screen, relative to pipe0
            if (x1 - 11'sd2 + 11'sd32 <= 11'sd0) begin
                x1          <= x0 + 11'sd335;
                gap_top1    <= 10'd150;
                gap_bottom1 <= 10'd300;
            end
        end
    end
end

endmodule
