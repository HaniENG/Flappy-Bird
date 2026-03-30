module collision(
    input clk,
    input reset,
    input frame_tick,
    input [9:0] bird_x,
    input [9:0] bird_y,
    input [9:0] pipe_x0, pipe_x0_right,
    input [9:0] pipe_x1, pipe_x1_right,
    input [9:0] pipe_x2, pipe_x2_right,
    input [9:0] pipe_x3, pipe_x3_right,
    input [9:0] gap_top0, gap_bottom0,
    input [9:0] gap_top1, gap_bottom1,
    input [9:0] gap_top2, gap_bottom2,
    input [9:0] gap_top3, gap_bottom3,
    output reg hit,
    output reg [1:0] lives,
    output reg game_over
);

reg in_collision;

// Horizontal overlap: bird right edge past pipe left AND bird left edge before pipe right
wire h0 = (bird_x + 10'd16 > pipe_x0) && (bird_x < pipe_x0_right);
wire h1 = (bird_x + 10'd16 > pipe_x1) && (bird_x < pipe_x1_right);
wire h2 = (bird_x + 10'd16 > pipe_x2) && (bird_x < pipe_x2_right);
wire h3 = (bird_x + 10'd16 > pipe_x3) && (bird_x < pipe_x3_right);

// Vertical violation: bird outside the gap
wire v0 = (bird_y < gap_top0) || (bird_y + 10'd16 > gap_bottom0);
wire v1 = (bird_y < gap_top1) || (bird_y + 10'd16 > gap_bottom1);
wire v2 = (bird_y < gap_top2) || (bird_y + 10'd16 > gap_bottom2);
wire v3 = (bird_y < gap_top3) || (bird_y + 10'd16 > gap_bottom3);

wire collision = (h0 && v0) || (h1 && v1) || (h2 && v2) || (h3 && v3);

always @(posedge clk) begin
    if (reset) begin
        lives        <= 2'd3;
        hit          <= 1'b0;
        in_collision <= 1'b0;
        game_over    <= 1'b0;
    end else if (frame_tick) begin
        if (collision && !in_collision && !game_over) begin
            // Leading edge of a new collision
            hit          <= 1'b1;
            lives        <= (lives > 2'd0) ? lives - 2'd1 : 2'd0;
            game_over    <= 1'b1;
            in_collision <= 1'b1;
        end else if (!collision) begin
            // No collision — clear state
            in_collision <= 1'b0;
            hit          <= 1'b0;
        end else begin
            // Ongoing collision — don't re-trigger
            hit <= 1'b0;
        end
    end
end

endmodule
