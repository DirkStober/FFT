

module bit_reverse
#(
    parameter addr_width = 10
)
(
    input [addr_width - 1 : 0] addr_in,
    output [addr_width - 1 : 0] addr_out   
);

generate
    genvar i;
    for(i = 0; i < addr_width;i = i + 1) begin
        assign addr_out[i] = addr_in[addr_width - 1 - i];
    end
endgenerate


endmodule