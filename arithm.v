
`define DefaultW 32
`define DefaultP 16


module cmplx_add
#(
    parameter width = `DefaultW,
    parameter prec = `DefaultP
)
(
    input [2*width - 1:0] a,
    input [2*width - 1:0] b,
    output [2*width - 1:0] r
);

assign r[2*width - 1: width] = a[2*width - 1: width] + b[2*width - 1: width];
assign r[width - 1: 0] = a[width - 1: 0] + b[width - 1: 0];

endmodule


module cmplx_sub
#(
    parameter width = `DefaultW,
    parameter prec = `DefaultP
)
(
    input [2*width - 1:0] a,
    input [2*width - 1:0] b,
    output [2*width - 1:0] r
);

assign r[2*width - 1: width] = a[2*width - 1: width] - b[2*width - 1: width];
assign r[width - 1: 0] = a[width - 1: 0] - b[width - 1: 0];

endmodule

module cmplx_mul
   #(
    parameter W = `DefaultW,
    parameter P = `DefaultP,
    localparam FW = 2*W
   )
   (
    input  [FW-1:0] a,
    input  [FW-1:0] b,
    output [FW-1:0] result
    );

wire [W-1:0] r1, j1, r2, j2;
assign {r1, j1} = a;
assign {r2, j2} = b;
wire [W-1:0] result_r_0,result_r_1;
wire [W-1:0] result_j_0,result_j_1;
qmult #(W,P) mul0(r1,r2,result_r_0);
qmult #(W,P) mul1(j1,j2,result_r_1);
qmult #(W,P) mul2(r1,j2,result_j_0);
qmult #(W,P) mul3(j1,r2,result_j_1);

assign result[FW-1:W] = result_r_0 - result_r_1;
assign result[W-1:0] = result_j_0 + result_j_1;
// result = (ar + aj*j) * (br + bj*j)
// real r_r = ar*br - aj*bj;
// imag rj = ar*bj *j + aj*br*j;
endmodule 

module qmult 
    #(
	parameter N = 32,
	parameter Q = 16
	)
	(
	 input			[N-1:0]	i_multiplicand,
	 input			[N-1:0]	i_multiplier,
	 output			[N-1:0]	o_result
	 );
	reg [2*N-1:0]	r_result;	
	reg [N-1:0]		r_RetVal;
	
	assign o_result = r_RetVal;
	always @(i_multiplicand, i_multiplier)	begin						
		r_result <= i_multiplicand[N-2:0] * i_multiplier[N-2:0];	
		end
	
	always @(r_result) begin		
	   if (r_result == 0) begin
	   			r_RetVal[N-1:0] <= 0;
	   end
	   else begin 				
		r_RetVal[N-1] <= i_multiplicand[N-1] ^ i_multiplier[N-1];	
		r_RetVal[N-2:0] <= r_result[N-2+Q:Q];	
	   end
	end					
endmodule

