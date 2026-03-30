module renderer(
    input [9:0] hcount,
    input [9:0] vcount,
    input active,
    input [9:0] bird_x,
    input [9:0] bird_y,
    input bird_visible,
    input [1:0] sprite_state,
    input [1:0] lives,
    input life_mode_en,
    input [3:0] score_thousands,
    input [3:0] score_hundreds,
    input [3:0] score_tens,
    input [3:0] score_ones,
    input mode_colour,
    input mode_sprite,
    input [9:0] pipe_x0, pipe_x0_right,
    input [9:0] pipe_x1, pipe_x1_right,
    input [9:0] pipe_x2, pipe_x2_right,
    input [9:0] pipe_x3, pipe_x3_right,
    input [9:0] gap_top0, gap_bottom0,
    input [9:0] gap_top1, gap_bottom1,
    input [9:0] gap_top2, gap_bottom2,
    input [9:0] gap_top3, gap_bottom3,
    output reg [11:0] colour
);

localparam [9:0] HUD_HEIGHT    = 10'd100;
localparam [9:0] BIRD_SIZE     = 10'd16;
localparam [9:0] DIGIT_W       = 10'd32;
localparam [9:0] DIGIT_H       = 10'd56;
localparam [9:0] DIGIT_T       = 10'd6;
localparam [9:0] DIGIT_Y       = 10'd22;
localparam [9:0] DIGIT0_X      = 10'd238;
localparam [9:0] DIGIT1_X      = 10'd282;
localparam [9:0] DIGIT2_X      = 10'd326;
localparam [9:0] DIGIT3_X      = 10'd370;

localparam [9:0] LABEL_X       = 10'd34;
localparam [9:0] LABEL_Y       = 10'd12;
localparam [9:0] LETTER_W      = 10'd10;
localparam [9:0] LETTER_H      = 10'd14;
localparam [9:0] LETTER_GAP    = 10'd2;
localparam [9:0] ICON_Y        = 10'd44;
localparam [9:0] ICON0_X       = 10'd36;
localparam [9:0] ICON1_X       = 10'd60;
localparam [9:0] ICON2_X       = 10'd84;
localparam [9:0] ICON_W        = 10'd16;
localparam [9:0] ICON_H        = 10'd16;

localparam [11:0] HUD_BG       = 12'h134;
localparam [11:0] HUD_RULE     = 12'h7CF;
localparam [11:0] HUD_TEXT     = 12'hFD0;
localparam [11:0] HUD_DIM      = 12'h567;
localparam [11:0] LIFE_ON      = 12'hFC0;
localparam [11:0] LIFE_OFF     = 12'h234;
localparam [11:0] LIFE_DIM     = 12'h456;
localparam [11:0] BIRD_COLOUR  = 12'hFFF;
localparam [11:0] PIPE_COLOUR  = 12'h0F0;

function [6:0] digit_segments;
    input [3:0] digit;
    begin
        case (digit)
            4'd0: digit_segments = 7'b1111110;
            4'd1: digit_segments = 7'b0110000;
            4'd2: digit_segments = 7'b1101101;
            4'd3: digit_segments = 7'b1111001;
            4'd4: digit_segments = 7'b0110011;
            4'd5: digit_segments = 7'b1011011;
            4'd6: digit_segments = 7'b1011111;
            4'd7: digit_segments = 7'b1110000;
            4'd8: digit_segments = 7'b1111111;
            4'd9: digit_segments = 7'b1111011;
            default: digit_segments = 7'b0000001;
        endcase
    end
endfunction

function digit_pixel;
    input [6:0] segments;
    input [9:0] local_x;
    input [9:0] local_y;
    begin
        digit_pixel =
            (segments[6] && (local_y < DIGIT_T) &&
             (local_x >= DIGIT_T) && (local_x < DIGIT_W - DIGIT_T)) ||
            (segments[5] && (local_x >= DIGIT_W - DIGIT_T) &&
             (local_y >= DIGIT_T) && (local_y < 10'd25)) ||
            (segments[4] && (local_x >= DIGIT_W - DIGIT_T) &&
             (local_y >= 10'd31) && (local_y < DIGIT_H - DIGIT_T)) ||
            (segments[3] && (local_y >= DIGIT_H - DIGIT_T) &&
             (local_x >= DIGIT_T) && (local_x < DIGIT_W - DIGIT_T)) ||
            (segments[2] && (local_x < DIGIT_T) &&
             (local_y >= 10'd31) && (local_y < DIGIT_H - DIGIT_T)) ||
            (segments[1] && (local_x < DIGIT_T) &&
             (local_y >= DIGIT_T) && (local_y < 10'd25)) ||
            (segments[0] && (local_y >= 10'd25) && (local_y < 10'd31) &&
             (local_x >= DIGIT_T) && (local_x < DIGIT_W - DIGIT_T));
    end
endfunction

function [4:0] lives_letter_row;
    input [2:0] letter_idx;
    input [2:0] row_idx;
    begin
        case (letter_idx)
            3'd0: begin
                case (row_idx)
                    3'd0, 3'd1, 3'd2, 3'd3, 3'd4, 3'd5: lives_letter_row = 5'b10000;
                    3'd6: lives_letter_row = 5'b11111;
                    default: lives_letter_row = 5'b00000;
                endcase
            end
            3'd1: begin
                case (row_idx)
                    3'd0, 3'd6: lives_letter_row = 5'b11111;
                    3'd1, 3'd2, 3'd3, 3'd4, 3'd5: lives_letter_row = 5'b00100;
                    default: lives_letter_row = 5'b00000;
                endcase
            end
            3'd2: begin
                case (row_idx)
                    3'd0, 3'd1, 3'd2, 3'd3: lives_letter_row = 5'b10001;
                    3'd4, 3'd5: lives_letter_row = 5'b01010;
                    3'd6: lives_letter_row = 5'b00100;
                    default: lives_letter_row = 5'b00000;
                endcase
            end
            3'd3: begin
                case (row_idx)
                    3'd0: lives_letter_row = 5'b11111;
                    3'd1, 3'd2: lives_letter_row = 5'b10000;
                    3'd3: lives_letter_row = 5'b11110;
                    3'd4, 3'd5: lives_letter_row = 5'b10000;
                    3'd6: lives_letter_row = 5'b11111;
                    default: lives_letter_row = 5'b00000;
                endcase
            end
            3'd4: begin
                case (row_idx)
                    3'd0: lives_letter_row = 5'b01111;
                    3'd1, 3'd2: lives_letter_row = 5'b10000;
                    3'd3: lives_letter_row = 5'b01110;
                    3'd4, 3'd5: lives_letter_row = 5'b00001;
                    3'd6: lives_letter_row = 5'b11110;
                    default: lives_letter_row = 5'b00000;
                endcase
            end
            default: lives_letter_row = 5'b00000;
        endcase
    end
endfunction

function label_pixel;
    input [2:0] letter_idx;
    input [9:0] local_x;
    input [9:0] local_y;
    reg [2:0] row_idx;
    reg [2:0] col_idx;
    reg [4:0] row_bits;
    begin
        row_idx = local_y[3:1];
        col_idx = local_x[3:1];
        row_bits = lives_letter_row(letter_idx, row_idx);
        label_pixel = row_bits[4 - col_idx];
    end
endfunction

function life_icon_pixel;
    input [9:0] local_x;
    input [9:0] local_y;
    begin
        life_icon_pixel =
            ((local_y >= 10'd4) && (local_y < 10'd12) &&
             (local_x >= 10'd2) && (local_x < 10'd12)) ||
            ((local_y >= 10'd6) && (local_y < 10'd10) &&
             (local_x >= 10'd12) && (local_x < 10'd15)) ||
            ((local_y >= 10'd1) && (local_y < 10'd4) &&
             (local_x >= 10'd5) && (local_x < 10'd9)) ||
            ((local_y >= 10'd10) && (local_y < 10'd15) &&
             (local_x >= 10'd0) && (local_x < 10'd5));
    end
endfunction

wire hud_active = active && (vcount < HUD_HEIGHT);
wire playfield_active = active && (vcount >= HUD_HEIGHT);
wire divider_pixel = active && (vcount >= HUD_HEIGHT - 10'd2) && (vcount < HUD_HEIGHT);
wire [9:0] playfield_y = vcount - HUD_HEIGHT;

wire bird_pixel = playfield_active && bird_visible &&
                  (hcount >= bird_x) && (hcount < bird_x + BIRD_SIZE) &&
                  (playfield_y >= bird_y) && (playfield_y < bird_y + BIRD_SIZE);

wire pipe0_col = (hcount >= pipe_x0) && (hcount < pipe_x0_right);
wire pipe1_col = (hcount >= pipe_x1) && (hcount < pipe_x1_right);
wire pipe2_col = (hcount >= pipe_x2) && (hcount < pipe_x2_right);
wire pipe3_col = (hcount >= pipe_x3) && (hcount < pipe_x3_right);

wire pipe_pixel =
    (playfield_active && pipe0_col &&
     ((playfield_y < gap_top0) || (playfield_y >= gap_bottom0))) ||
    (playfield_active && pipe1_col &&
     ((playfield_y < gap_top1) || (playfield_y >= gap_bottom1))) ||
    (playfield_active && pipe2_col &&
     ((playfield_y < gap_top2) || (playfield_y >= gap_bottom2))) ||
    (playfield_active && pipe3_col &&
     ((playfield_y < gap_top3) || (playfield_y >= gap_bottom3)));

wire [6:0] segments_thousands = digit_segments(score_thousands);
wire [6:0] segments_hundreds = digit_segments(score_hundreds);
wire [6:0] segments_tens = digit_segments(score_tens);
wire [6:0] segments_ones = digit_segments(score_ones);

wire digit0_box = hud_active &&
                  (hcount >= DIGIT0_X) && (hcount < DIGIT0_X + DIGIT_W) &&
                  (vcount >= DIGIT_Y) && (vcount < DIGIT_Y + DIGIT_H);
wire digit1_box = hud_active &&
                  (hcount >= DIGIT1_X) && (hcount < DIGIT1_X + DIGIT_W) &&
                  (vcount >= DIGIT_Y) && (vcount < DIGIT_Y + DIGIT_H);
wire digit2_box = hud_active &&
                  (hcount >= DIGIT2_X) && (hcount < DIGIT2_X + DIGIT_W) &&
                  (vcount >= DIGIT_Y) && (vcount < DIGIT_Y + DIGIT_H);
wire digit3_box = hud_active &&
                  (hcount >= DIGIT3_X) && (hcount < DIGIT3_X + DIGIT_W) &&
                  (vcount >= DIGIT_Y) && (vcount < DIGIT_Y + DIGIT_H);

wire digit0_pixel = digit0_box &&
                    digit_pixel(segments_thousands, hcount - DIGIT0_X, vcount - DIGIT_Y);
wire digit1_pixel = digit1_box &&
                    digit_pixel(segments_hundreds, hcount - DIGIT1_X, vcount - DIGIT_Y);
wire digit2_pixel = digit2_box &&
                    digit_pixel(segments_tens, hcount - DIGIT2_X, vcount - DIGIT_Y);
wire digit3_pixel = digit3_box &&
                    digit_pixel(segments_ones, hcount - DIGIT3_X, vcount - DIGIT_Y);

wire score_pixel = digit0_pixel || digit1_pixel || digit2_pixel || digit3_pixel;

wire label0_box = hud_active &&
                  (hcount >= LABEL_X) && (hcount < LABEL_X + LETTER_W) &&
                  (vcount >= LABEL_Y) && (vcount < LABEL_Y + LETTER_H);
wire label1_box = hud_active &&
                  (hcount >= LABEL_X + LETTER_W + LETTER_GAP) &&
                  (hcount < LABEL_X + (LETTER_W * 2) + LETTER_GAP) &&
                  (vcount >= LABEL_Y) && (vcount < LABEL_Y + LETTER_H);
wire label2_box = hud_active &&
                  (hcount >= LABEL_X + ((LETTER_W + LETTER_GAP) * 2)) &&
                  (hcount < LABEL_X + ((LETTER_W + LETTER_GAP) * 2) + LETTER_W) &&
                  (vcount >= LABEL_Y) && (vcount < LABEL_Y + LETTER_H);
wire label3_box = hud_active &&
                  (hcount >= LABEL_X + ((LETTER_W + LETTER_GAP) * 3)) &&
                  (hcount < LABEL_X + ((LETTER_W + LETTER_GAP) * 3) + LETTER_W) &&
                  (vcount >= LABEL_Y) && (vcount < LABEL_Y + LETTER_H);
wire label4_box = hud_active &&
                  (hcount >= LABEL_X + ((LETTER_W + LETTER_GAP) * 4)) &&
                  (hcount < LABEL_X + ((LETTER_W + LETTER_GAP) * 4) + LETTER_W) &&
                  (vcount >= LABEL_Y) && (vcount < LABEL_Y + LETTER_H);

wire label0_pixel = label0_box &&
                    label_pixel(3'd0, hcount - LABEL_X, vcount - LABEL_Y);
wire label1_pixel = label1_box &&
                    label_pixel(3'd1, hcount - (LABEL_X + LETTER_W + LETTER_GAP), vcount - LABEL_Y);
wire label2_pixel = label2_box &&
                    label_pixel(3'd2, hcount - (LABEL_X + ((LETTER_W + LETTER_GAP) * 2)), vcount - LABEL_Y);
wire label3_pixel = label3_box &&
                    label_pixel(3'd3, hcount - (LABEL_X + ((LETTER_W + LETTER_GAP) * 3)), vcount - LABEL_Y);
wire label4_pixel = label4_box &&
                    label_pixel(3'd4, hcount - (LABEL_X + ((LETTER_W + LETTER_GAP) * 4)), vcount - LABEL_Y);

wire lives_label_pixel = label0_pixel || label1_pixel || label2_pixel || label3_pixel || label4_pixel;

wire [1:0] lives_display = life_mode_en ? lives : 2'd3;
wire life0_on = (lives_display > 2'd0);
wire life1_on = (lives_display > 2'd1);
wire life2_on = (lives_display > 2'd2);

wire icon0_box = hud_active &&
                 (hcount >= ICON0_X) && (hcount < ICON0_X + ICON_W) &&
                 (vcount >= ICON_Y) && (vcount < ICON_Y + ICON_H);
wire icon1_box = hud_active &&
                 (hcount >= ICON1_X) && (hcount < ICON1_X + ICON_W) &&
                 (vcount >= ICON_Y) && (vcount < ICON_Y + ICON_H);
wire icon2_box = hud_active &&
                 (hcount >= ICON2_X) && (hcount < ICON2_X + ICON_W) &&
                 (vcount >= ICON_Y) && (vcount < ICON_Y + ICON_H);

wire icon0_pixel = icon0_box && life_icon_pixel(hcount - ICON0_X, vcount - ICON_Y);
wire icon1_pixel = icon1_box && life_icon_pixel(hcount - ICON1_X, vcount - ICON_Y);
wire icon2_pixel = icon2_box && life_icon_pixel(hcount - ICON2_X, vcount - ICON_Y);

wire lives_icon_pixel = icon0_pixel || icon1_pixel || icon2_pixel;

always @(*) begin
    if (!active)
        colour = 12'h000;
    else if (divider_pixel)
        colour = HUD_RULE;
    else if (lives_label_pixel)
        colour = life_mode_en ? HUD_TEXT : HUD_DIM;
    else if (icon0_pixel)
        colour = life_mode_en ? (life0_on ? LIFE_ON : LIFE_OFF) : LIFE_DIM;
    else if (icon1_pixel)
        colour = life_mode_en ? (life1_on ? LIFE_ON : LIFE_OFF) : LIFE_DIM;
    else if (icon2_pixel)
        colour = life_mode_en ? (life2_on ? LIFE_ON : LIFE_OFF) : LIFE_DIM;
    else if (score_pixel)
        colour = HUD_TEXT;
    else if (hud_active)
        colour = HUD_BG;
    else if (bird_pixel)
        colour = BIRD_COLOUR;
    else if (pipe_pixel)
        colour = PIPE_COLOUR;
    else
        colour = mode_colour ? 12'hF00 : 12'h00F;
end

endmodule
