
module butterfly
    #(
        parameter width = 32,
        parameter precision = 16,
        localparam dw = 2*width
    )
    (
        input [dw - 1: 0] even_i,
        input [dw - 1: 0] odd_i,
        input [dw - 1: 0] twiddle,
        output [dw - 1: 0] even_o,
        output [dw - 1: 0] odd_o
    );
    wire [dw - 1: 0] rot;
    // multiply odd with twiddle 
    cmplx_mul #(width,precision) mul(odd_i,twiddle,rot);

    // add and sub
    cmplx_add #(width,precision) add(even_i,rot,even_o);
    cmplx_sub #(width,precision) sub(even_i,rot,odd_o);

endmodule




