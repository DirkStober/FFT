

module delay
#(
    parameter width = 64,
    parameter n = 1
)
(
    input clk,
    input [width - 1:0] data_in,
    output [width - 1:0] data_out
);
    reg [width - 1:0] regs [0:n - 1] ;
    integer i;
    integer j;
    initial begin
      for(j = 0; j < n - 1; j = j+1) begin
        regs[j] = {width{1'b0}};
      end
    end
    always@(posedge clk) begin
        regs[0] <= data_in;
        for(i = 1; i < n ; i = i + 1) begin
            regs[i]  <= regs[i - 1];
        end
    end
     assign data_out=regs[n - 1];

endmodule