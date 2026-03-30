module sprite_rom(
    input [1:0] sprite_id,
    input [3:0] x,
    input [3:0] y,
    output reg [11:0] pixel
);

always @(*) begin
    pixel = 12'hFFF;
end

endmodule