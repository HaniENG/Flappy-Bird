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
    input [9:0] pipe_x1,
    input [9:0] gap_top0,
    input [9:0] gap_bottom0,
    input [9:0] gap_top1,
    input [9:0] gap_bottom1,
    output reg [11:0] colour
);

wire bird_pixel = (hcount >= bird_x) && (hcount < bird_x + 16) &&
                  (vcount >= bird_y) && (vcount < bird_y + 16);

always @(*) begin
    if (!active)
        colour = 12'h000;
    else if (bird_pixel)
        colour = 12'hFFF;
    else
        colour = mode_colour ? 12'hF00 : 12'h00F;
end

endmodule