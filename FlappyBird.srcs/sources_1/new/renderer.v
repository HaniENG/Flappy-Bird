module renderer(
    input [9:0] hcount,
    input [9:0] vcount,
    input active,
    input [9:0] bird_x,
    input [9:0] bird_y,
    input [1:0] sprite_state,
    input [1:0] lives,
    input mode_colour,
    input mode_sprite,
    input [9:0] pipe_x0,
    input [9:0] pipe_x0_right,
    input [9:0] pipe_x1,
    input [9:0] pipe_x1_right,
    input [9:0] gap_top0,
    input [9:0] gap_bottom0,
    input [9:0] gap_top1,
    input [9:0] gap_bottom1,
    output reg [11:0] colour
);

wire bird_pixel = (hcount >= bird_x) && (hcount < bird_x + 16) &&
                  (vcount >= bird_y) && (vcount < bird_y + 16);

wire pipe0_col = (hcount >= pipe_x0) && (hcount < pipe_x0_right);
wire pipe1_col = (hcount >= pipe_x1) && (hcount < pipe_x1_right);

wire pipe_pixel = (pipe0_col && (vcount < gap_top0 || vcount > gap_bottom0)) ||
                  (pipe1_col && (vcount < gap_top1 || vcount > gap_bottom1));

always @(*) begin
    if (!active)
        colour = 12'h000;
    else if (bird_pixel)
        colour = 12'hFFF;
    else if (pipe_pixel)
        colour = 12'h0F0;
    else
        colour = mode_colour ? 12'hF00 : 12'h00F;
end

endmodule
