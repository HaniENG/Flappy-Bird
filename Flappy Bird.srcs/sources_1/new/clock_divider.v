module clock_divider(
    input clk,
    input reset,
    output reg frame_tick
);

reg [21:0] counter;

always @(posedge clk) begin
    if (reset) begin
        counter <= 0;
        frame_tick <= 0;
    end else begin
        if (counter == 1666666) begin
            counter <= 0;
            frame_tick <= 1;
        end else begin
            counter <= counter + 1;
            frame_tick <= 0;
        end
    end
end

endmodule