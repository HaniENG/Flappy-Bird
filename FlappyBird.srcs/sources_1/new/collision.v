module collision(
    input clk,
    input reset,
    input frame_tick,
    input [9:0] bird_x,
    input [9:0] bird_y,
    input [9:0] pipe_x0, pipe_x0_right,
    input [9:0] pipe_x1, pipe_x1_right,
    input [9:0] pipe_x2, pipe_x2_right,
    input [9:0] gap_top0, gap_bottom0,
    input [9:0] gap_top1, gap_bottom1,
    input [9:0] gap_top2, gap_bottom2,
    output reg hit,
    output reg [1:0] lives
);

always @(posedge clk) begin
    if (reset) begin
        lives <= 3;
        hit <= 0;
    end else if (frame_tick) begin
        hit <= 0;
    end
end

endmodule
