module top(
    input clk,
    input reset,
    input btn_up,
    input [3:0] sw,
    output [3:0] VGA_R,
    output [3:0] VGA_G,
    output [3:0] VGA_B,
    output VGA_HS,
    output VGA_VS
);

// CPU_RESETN is active-low; invert so internal reset is active-high
wire rst = ~reset;

// internal wires
wire frame_tick;

wire [9:0] hcount, vcount;
wire active;
wire hsync, vsync;

wire [9:0] bird_x, bird_y;
wire [1:0] sprite_state;

wire [9:0] pipe_x0, pipe_x0_right;
wire [9:0] pipe_x1, pipe_x1_right;
wire [9:0] pipe_x2, pipe_x2_right;
wire [9:0] pipe_x3, pipe_x3_right;
wire [9:0] gap_top0, gap_bottom0;
wire [9:0] gap_top1, gap_bottom1;
wire [9:0] gap_top2, gap_bottom2;
wire [9:0] gap_top3, gap_bottom3;

wire hit;
wire [1:0] lives;
wire game_over;
wire pipe_score_pulse;
wire bird_visible;

wire [11:0] colour;
reg [3:0] score_thousands;
reg [3:0] score_hundreds;
reg [3:0] score_tens;
reg [3:0] score_ones;

// 25 MHz pixel tick: pulse every 4 cycles of 100 MHz clock
reg [1:0] pixel_cnt = 0;
wire pixel_tick;
always @(posedge clk) pixel_cnt <= pixel_cnt + 1;
assign pixel_tick = (pixel_cnt == 2'b11);

always @(posedge clk) begin
    if (rst) begin
        score_thousands <= 4'd0;
        score_hundreds  <= 4'd0;
        score_tens      <= 4'd0;
        score_ones      <= 4'd0;
    end else if (pipe_score_pulse) begin
        if (score_ones == 4'd9) begin
            score_ones <= 4'd0;
            if (score_tens == 4'd9) begin
                score_tens <= 4'd0;
                if (score_hundreds == 4'd9) begin
                    score_hundreds <= 4'd0;
                    if (score_thousands == 4'd9)
                        score_thousands <= 4'd0;
                    else
                        score_thousands <= score_thousands + 4'd1;
                end else begin
                    score_hundreds <= score_hundreds + 4'd1;
                end
            end else begin
                score_tens <= score_tens + 4'd1;
            end
        end else begin
            score_ones <= score_ones + 4'd1;
        end
    end
end

clock_divider clk_div(.clk(clk), .reset(rst), .frame_tick(frame_tick));

vga_controller vga(
    .clk(clk), .pixel_tick(pixel_tick), .reset(rst),
    .hcount(hcount), .vcount(vcount),
    .hsync(hsync), .vsync(vsync), .active(active)
);

bird b(
    .clk(clk), .reset(rst),
    .frame_tick(frame_tick),
    .btn_up(btn_up),
    .hit(hit),
    .game_over(game_over),
    .bird_x(bird_x),
    .bird_y(bird_y),
    .sprite_state(sprite_state)
);

pipes p(
    .clk(clk), .reset(rst),
    .frame_tick(frame_tick),
    .mode_frenzy(sw[0]),
    .game_over(game_over),
    .bird_x(bird_x),
    .vcount(vcount),
    .pipe_x0(pipe_x0), .pipe_x0_right(pipe_x0_right),
    .pipe_x1(pipe_x1), .pipe_x1_right(pipe_x1_right),
    .pipe_x2(pipe_x2), .pipe_x2_right(pipe_x2_right),
    .pipe_x3(pipe_x3), .pipe_x3_right(pipe_x3_right),
    .gap_top0(gap_top0), .gap_bottom0(gap_bottom0),
    .gap_top1(gap_top1), .gap_bottom1(gap_bottom1),
    .gap_top2(gap_top2), .gap_bottom2(gap_bottom2),
    .gap_top3(gap_top3), .gap_bottom3(gap_bottom3),
    .score_pulse(pipe_score_pulse)
);

collision c(
    .clk(clk), .reset(rst),
    .frame_tick(frame_tick),
    .life_mode_en(sw[3]),
    .bird_x(bird_x), .bird_y(bird_y),
    .pipe_x0(pipe_x0), .pipe_x0_right(pipe_x0_right),
    .pipe_x1(pipe_x1), .pipe_x1_right(pipe_x1_right),
    .pipe_x2(pipe_x2), .pipe_x2_right(pipe_x2_right),
    .pipe_x3(pipe_x3), .pipe_x3_right(pipe_x3_right),
    .gap_top0(gap_top0), .gap_bottom0(gap_bottom0),
    .gap_top1(gap_top1), .gap_bottom1(gap_bottom1),
    .gap_top2(gap_top2), .gap_bottom2(gap_bottom2),
    .gap_top3(gap_top3), .gap_bottom3(gap_bottom3),
    .hit(hit),
    .lives(lives),
    .game_over(game_over),
    .bird_visible(bird_visible)
);

renderer r(
    .hcount(hcount), .vcount(vcount),
    .active(active),
    .bird_x(bird_x), .bird_y(bird_y),
    .bird_visible(bird_visible),
    .sprite_state(sprite_state),
    .lives(lives),
    .life_mode_en(sw[3]),
    .score_thousands(score_thousands),
    .score_hundreds(score_hundreds),
    .score_tens(score_tens),
    .score_ones(score_ones),
    .mode_colour(sw[2]),
    .mode_sprite(sw[1]),
    .pipe_x0(pipe_x0), .pipe_x0_right(pipe_x0_right),
    .pipe_x1(pipe_x1), .pipe_x1_right(pipe_x1_right),
    .pipe_x2(pipe_x2), .pipe_x2_right(pipe_x2_right),
    .pipe_x3(pipe_x3), .pipe_x3_right(pipe_x3_right),
    .gap_top0(gap_top0), .gap_bottom0(gap_bottom0),
    .gap_top1(gap_top1), .gap_bottom1(gap_bottom1),
    .gap_top2(gap_top2), .gap_bottom2(gap_bottom2),
    .gap_top3(gap_top3), .gap_bottom3(gap_bottom3),
    .colour(colour)
);

// VGA output split
assign VGA_R = colour[11:8];
assign VGA_G = colour[7:4];
assign VGA_B = colour[3:0];

assign VGA_HS = hsync;
assign VGA_VS = vsync;

endmodule
