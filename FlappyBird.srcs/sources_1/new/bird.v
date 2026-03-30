module bird(
    input clk,
    input reset,
    input frame_tick,
    input btn_up,
    input hit,
    output reg [9:0] bird_x,
    output reg [9:0] bird_y,
    output reg [1:0] sprite_state
);

always @(posedge clk) begin
    if (reset) begin
        bird_x <= 100;
        bird_y <= 232;
        sprite_state <= 0;
    end else if (frame_tick) begin
        bird_x <= 100;
        sprite_state <= 0;
        if (btn_up) begin
            if (bird_y < 5)
                bird_y <= 0;
            else
                bird_y <= bird_y - 5;
        end else begin
            if (bird_y > 477)
                bird_y <= 479;
            else
                bird_y <= bird_y + 2;
        end
    end
end

endmodule
