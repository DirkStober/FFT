`timescale 1 ns / 1 ps
module sin_rom
#(
    parameter width  = 64,
    parameter size = 512,
    parameter a_width = 9
)
(
    input clk,
    input en,
    input [a_width - 1:0] addr,
    output reg [width - 1: 0] data
);

reg [width - 1:0] ram [0:size];

initial begin
    $readmemh("./sin_cos.dat",ram);
end
always @(posedge clk) 
begin
    if(en) begin
        data <= ram[addr];
    end
end

endmodule