



module AGU 
#(
    parameter addr_width = 10,
    parameter n_steps = 9
)
(
    input clk,
    input rst,
    input fft_start,
    output [addr_width - 1:0] mem_addr_0,
    output [addr_width - 1:0] mem_addr_1,
    output ram_select,
    output [n_steps-1:0] k,
    output [3: 0] n,
    output reg fft_done,
    output ex_en,
    output overflow_delay
);

reg ex_en = 0;
reg [n_steps-1:0] j = 0;
reg [3:0] i = 0;
reg overflow_delay = 0;
assign k = j;
assign n = i;

assign ram_select = !(i%2);
// counter j
always @(posedge clk) begin
    if(ex_en) begin
        if(overflow_delay == 0) begin
            if(j == 511) begin
                j <= 0;
                overflow_delay <= 1;
            end
            else begin
                j <= j +1;
            end
        end
        else begin
            overflow_delay <= overflow_delay + 1;
        end
    end
end

// counter i
always @(posedge clk) begin
    if(ex_en & (j == 511)) begin
        if( i == 9) begin
            i <= 0;
        end
        else begin
            i <= i +1;   
        end
    end
end

// offset 
wire [9:0] offset;
assign offset = 1'b1 << i;

// increment
reg [9:0] inc = 2'd2;
always @(posedge clk) begin
    if(ex_en & !overflow_delay ) begin
        if(j == 511) begin
            if(inc == 512) begin
                inc <= 1;
            end
            else begin
                inc <= inc << 1;
            end
        end
    end
end

reg [9:0] lower_addr = 0;
always @(posedge clk) begin
    if(ex_en & !overflow_delay) begin
            if(j == 511) begin
                lower_addr <= 0;
            end
            else begin
                lower_addr <= (lower_addr + inc ) % 1023;
            end
    end
end
assign mem_addr_0 = lower_addr;
assign mem_addr_1 = lower_addr + offset;

always @(posedge clk) begin
    if(fft_start) begin
        ex_en <= 1;
        fft_done <= 0;
    end
    else
    if(j == 511 & i == 9) begin
        ex_en <= 0;
        fft_done <= 1;
    end
end
initial begin
    fft_done <= 0;
end
endmodule
