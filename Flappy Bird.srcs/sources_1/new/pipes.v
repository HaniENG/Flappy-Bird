module pipes(
    input clk,
    input reset,
    input frame_tick,
    input mode_frenzy,
    output reg [9:0] pipe_x0,
    output reg [9:0] pipe_x1,
    output reg [9:0] gap_top0,
    output reg [9:0] gap_bottom0,
    output reg [9:0] gap_top1,
    output reg [9:0] gap_bottom1
);

always @(posedge clk) begin
    if (reset) begin
        pipe_x0 <= 600;
        pipe_x1 <= 900;
        gap_top0 <= 150;
        gap_bottom0 <= 300;
        gap_top1 <= 200;
        gap_bottom1 <= 350;
    end else if (frame_tick) begin
        pipe_x0 <= pipe_x0 - 2;
        pipe_x1 <= pipe_x1 - 2;

        if (pipe_x0 < 0)
            pipe_x0 <= 640;

        if (pipe_x1 < 0)
            pipe_x1 <= 640;
    end
end

endmodule