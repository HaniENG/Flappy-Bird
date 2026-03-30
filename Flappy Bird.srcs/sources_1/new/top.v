module top(
    input clk,
    input reset,
    input btn_up,
    input [2:0] sw,
    output [3:0] VGA_R,
    output [3:0] VGA_G,
    output [3:0] VGA_B,
    output VGA_HS,
    output VGA_VS
);

// internal wires
wire frame_tick;

wire [9:0] hcount, vcount;
wire active;
wire hsync, vsync;

wire [9:0] bird_x, bird_y;
wire [1:0] sprite_state;

wire [9:0] pipe_x0, pipe_x1;
wire [9:0] gap_top0, gap_bottom0;
wire [9:0] gap_top1, gap_bottom1;

wire hit;
wire [1:0] lives;

wire [11:0] colour;

// modules (empty for now)
clock_divider clk_div(.clk(clk), .reset(reset), .frame_tick(frame_tick));

vga_controller vga(
    .clk(clk), .reset(reset),
    .hcount(hcount), .vcount(vcount),
    .hsync(hsync), .vsync(vsync), .active(active)
);

bird b(
    .clk(clk), .reset(reset),
    .frame_tick(frame_tick),
    .btn_up(btn_up),
    .hit(hit),
    .bird_x(bird_x),
    .bird_y(bird_y),
    .sprite_state(sprite_state)
);

pipes p(
    .clk(clk), .reset(reset),
    .frame_tick(frame_tick),
    .mode_frenzy(sw[0]),
    .pipe_x0(pipe_x0), .pipe_x1(pipe_x1),
    .gap_top0(gap_top0), .gap_bottom0(gap_bottom0),
    .gap_top1(gap_top1), .gap_bottom1(gap_bottom1)
);

collision c(
    .clk(clk), .reset(reset),
    .frame_tick(frame_tick),
    .bird_x(bird_x), .bird_y(bird_y),
    .pipe_x0(pipe_x0), .pipe_x1(pipe_x1),
    .gap_top0(gap_top0), .gap_bottom0(gap_bottom0),
    .gap_top1(gap_top1), .gap_bottom1(gap_bottom1),
    .hit(hit),
    .lives(lives)
);

renderer r(
    .hcount(hcount), .vcount(vcount),
    .active(active),
    .bird_x(bird_x), .bird_y(bird_y),
    .sprite_state(sprite_state),
    .lives(lives),
    .mode_colour(sw[2]),
    .mode_sprite(sw[1]),
    .pipe_x0(pipe_x0), .pipe_x1(pipe_x1),
    .gap_top0(gap_top0), .gap_bottom0(gap_bottom0),
    .gap_top1(gap_top1), .gap_bottom1(gap_bottom1),
    .colour(colour)
);

// VGA output split
assign VGA_R = colour[11:8];
assign VGA_G = colour[7:4];
assign VGA_B = colour[3:0];

assign VGA_HS = hsync;
assign VGA_VS = vsync;

endmodule