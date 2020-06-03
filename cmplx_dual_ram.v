


module cmplx_dual_ram
#(
    parameter width = 64,
    parameter size = 1024,
    parameter addr_size = 10
)
(
    input clk,
    input wr_en_0,
    input wr_en_1,
    input [addr_size - 1:0] addr_0,
    input [addr_size - 1:0] addr_1,
    input [width - 1: 0] data_0_in,
    input [width - 1: 0] data_1_in,
    output [width - 1: 0] data_0_out,
    output [width - 1: 0] data_1_out
);
wire [(width/2) - 1:0] data_0_real_in,data_0_imag_in,data_1_real_in,data_1_imag_in;
wire [(width/2) - 1:0] data_0_real_out,data_0_imag_out,data_1_real_out,data_1_imag_out;

assign {data_0_real_in,data_0_imag_in} = data_0_in;
assign {data_1_real_in,data_1_imag_in} = data_1_in;

assign data_0_out = {data_0_real_out,data_0_imag_out};
assign data_1_out = {data_1_real_out,data_1_imag_out};

dual_ram #(width/2,size,addr_size) ram_real(clk,wr_en_0,wr_en_1,addr_0,addr_1,data_0_real_in,data_1_real_in,
                                    data_0_real_out,data_1_real_out);
dual_ram #(width/2,size,addr_size) ram_imag(clk,wr_en_0,wr_en_1,addr_0,addr_1, data_0_imag_in, data_1_imag_in,
                                     data_0_imag_out, data_1_imag_out);


endmodule