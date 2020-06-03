module ram_block
#(
    parameter width = 64,
    parameter size = 1024,
    parameter addr_size = 10
)
(
    input clk,
    input wr_en_0_a,
    input wr_en_0_b,
    input wr_en_1_a,
    input wr_en_1_b,
    input ram_select,
    input [addr_size - 1:0] addr_write_0,
    input [addr_size - 1:0] addr_write_1,
    input [addr_size - 1:0] addr_read_0,
    input [addr_size - 1:0] addr_read_1,
    input [width - 1: 0] data_0_in,
    input [width - 1: 0] data_1_in,
    output [width - 1: 0] data_0_out,
    output [width - 1: 0] data_1_out
);
wire wr_en_0_0,wr_en_0_1,wr_en_1_0,wr_en_1_1;
wire [width - 1:0] data_0_0_out,data_0_1_out;
wire [width - 1:0] data_1_0_out,data_1_1_out;
wire [addr_size - 1: 0] addr_0_0,addr_0_1;
wire [addr_size - 1: 0] addr_1_0,addr_1_1;



assign wr_en_0_0 = ram_select ? 1'b0 : wr_en_0_a;
assign wr_en_0_1 = ram_select ? 1'b0 : wr_en_0_b;

assign wr_en_1_0 = ram_select ? wr_en_1_a : 1'b0;
assign wr_en_1_1 = ram_select ? wr_en_1_b : 1'b0;

assign addr_0_0 = ram_select ? addr_read_0 : addr_write_0;
assign addr_0_1 = ram_select ? addr_read_1 : addr_write_1;

assign addr_1_0 = ram_select ? addr_write_0 : addr_read_0;
assign addr_1_1 = ram_select ? addr_write_1 : addr_read_1;



dual_ram #(width,size,addr_size) ram_0(clk,wr_en_0_0,wr_en_0_1,addr_0_0,addr_0_1,data_0_in,data_1_in,
                                    data_0_0_out,data_0_1_out);
dual_ram #(width,size,addr_size) ram_1(clk,wr_en_1_0,wr_en_1_1,addr_1_0,addr_1_1, data_0_in, data_1_in,
                                      data_1_0_out,data_1_1_out);
                                      
assign data_0_out = ram_select ?  data_0_0_out : data_1_0_out;
assign data_1_out = ram_select ?  data_0_1_out : data_1_1_out;
endmodule