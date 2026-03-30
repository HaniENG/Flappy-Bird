module vga_controller(
    input clk,
    input reset,
    output reg [9:0] hcount,
    output reg [9:0] vcount,
    output reg hsync,
    output reg vsync,
    output reg active
);

always @(posedge clk) begin
    if (reset) begin
        hcount <= 0;
        vcount <= 0;
    end else begin
        if (hcount == 799) begin
            hcount <= 0;
            if (vcount == 524)
                vcount <= 0;
            else
                vcount <= vcount + 1;
        end else begin
            hcount <= hcount + 1;
        end
    end
end

always @(*) begin
    hsync = ~(hcount >= 656 && hcount < 752);
    vsync = ~(vcount >= 490 && vcount < 492);
    active = (hcount < 640 && vcount < 480);
end

endmodule