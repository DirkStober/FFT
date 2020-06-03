// reg [DATA_WIDTH-1 : 0] mem_A [0 : SIZE-1];


module dual_ram
#(
    parameter width = 32,
    parameter size = 512,
    parameter addr_size = 9
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
reg [width - 1: 0] data_0_out,data_1_out;
reg [width - 1:0] mem [0: size - 1];
integer j;
initial begin
  for(j = 0; j < size; j = j+1) 
   //mem[j] = j ;
    mem[j] ={16'd0,16'd0,16'd1,16'd0} ;
end



always @(posedge clk) begin
    if(wr_en_0 == 1) begin
        mem[addr_0] <= data_0_in;
    end
    
    data_0_out <= mem[addr_0];
end

always @(posedge clk) begin
    if(wr_en_1 == 1 ) begin
        mem[addr_1] <= data_1_in;
    end
    data_1_out <= mem[addr_1];
end


endmodule