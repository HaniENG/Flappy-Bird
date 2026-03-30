module bird(
    input clk,
    input reset,
    input frame_tick,
    input btn_up,
    input hit,
    input game_over,
    output reg [9:0] bird_x,
    output reg [9:0] bird_y,
    output reg [1:0] sprite_state
);

localparam [9:0] PLAYFIELD_HEIGHT = 10'd380;
localparam [9:0] BIRD_SIZE = 10'd16;
localparam [9:0] START_Y = 10'd182;
localparam [9:0] JUMP_STEP = 10'd4;
localparam [9:0] FALL_STEP = 10'd2;
localparam [9:0] MAX_Y = PLAYFIELD_HEIGHT - BIRD_SIZE;

always @(posedge clk) begin
    if (reset) begin
        bird_x <= 100;
        bird_y <= START_Y;
        sprite_state <= 0;
    end else if (frame_tick) begin
        bird_x <= 100;
        sprite_state <= 0;
        if (hit) begin
            bird_y <= START_Y;
        end else if (!game_over) begin
            if (btn_up) begin
                if (bird_y < JUMP_STEP)
                    bird_y <= 0;
                else
                    bird_y <= bird_y - JUMP_STEP;
            end else begin
                if (bird_y >= MAX_Y - FALL_STEP)
                    bird_y <= MAX_Y;
                else
                    bird_y <= bird_y + FALL_STEP;
            end
        end
    end
end

endmodule
