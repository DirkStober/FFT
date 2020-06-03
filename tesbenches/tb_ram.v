

module tb_ram
#(
        parameter width = 64,
        parameter size = 1024,
        parameter log_s = 10

    )
    ();
    reg clk;
    reg wr_en;
    reg [log_s-1:0] addr_0;
    reg [log_s-1:0] addr_1;
    reg [width - 1:0] data_0_in;
    reg [width - 1:0] data_1_in ;
    wire [width - 1:0] data_0_out;
    wire [width - 1:0] data_1_out;
    reg ram_select;
    ram_block #(width,size,log_s) ram  (clk,wr_en,ram_select,addr_0,addr_1,data_0_in,data_1_in,
                                data_0_out,data_1_out);
    

      integer i;


    initial begin
        wr_en = 1;
        addr_0 = 0;
        addr_1 = 0;
        clk = 0;
        #20;
        clk = 1;
        #20 clk = 0;
        ram_select = 0;
        for(i = 0; i < size/2;i = i + 1) begin
            data_0_in = i*2;
            data_1_in = i;
            addr_0 = i;
            addr_1 = i + size/2;
            #20;
            clk = 1;
            #20;
            clk = 0;
        end
        clk = 0;
        #20;
        clk = 1;
        #20 clk = 0;
        ram_select = 1;
        for(i = 0; i < size/2;i = i + 1) begin
            data_0_in = data_0_out;
            data_1_in = data_1_out;
            addr_0 = i;
            addr_1 = i + size/2;
            #20;
            clk = 1;
            #5;
            clk = 0;
        end
    end

endmodule
