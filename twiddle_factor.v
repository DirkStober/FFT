


module twiddle_factor
#(
    parameter width  = 64,
    parameter size = 512,
    parameter n_steps = 9
)
(
    input clk,
    input en,
    input [n_steps-1:0] k,
    input [3: 0] n,
    output [width - 1: 0] omega
);
wire [n_steps-1:0] t0;
wire [n_steps-1:0] addr;
assign t0 = 18'b111111111_000000000 >> n;
assign addr = t0 &k;
sin_rom #(width,512,9) rom(clk,en,addr,omega);

endmodule
