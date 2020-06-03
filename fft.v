

module fft
(
    input clk,
    input rst,
    
    // AXI-Stream Slave
    output wire  s00_axis_tready,
    input wire [64-1 : 0] s00_axis_tdata,
    input wire  s00_axis_tlast,
    input wire  s00_axis_tvalid,

    // AXI-Stream Master
    output wire  m00_axis_tvalid,
    output wire [64-1 : 0] m00_axis_tdata,
    output wire [(64/8)-1 : 0] m00_axis_tstrb,
    output wire  m00_axis_tlast,
    input wire  m00_axis_tready,


    // individual signals
    input start,
    output done
    
);
parameter addr_width = 10;
parameter width = 64;
parameter n_steps = 9;
assign m00_axis_tstrb = 8'hff;   // always f; byte-enable signal;

wire ex_en;

wire [addr_width - 1:0] mem_addr_0;
wire [addr_width - 1:0] mem_addr_1;
wire ram_select;
wire [n_steps-1:0] k;
wire [3: 0] n;
wire [width - 1: 0] omega;

wire [width - 1: 0] even_in;
wire [width - 1: 0] odd_in;
wire [width - 1: 0] even_out;
wire [width - 1: 0] odd_out;

wire mem_wr_en; 
wire [addr_width-1: 0] addr_write_0, addr_write_1, addr_read_0, addr_read_1;
wire [width - 1: 0] mem_data_0_in,mem_data_1_in;
wire [width - 1: 0] mem_data_0_out,mem_data_1_out;
wire overflow_delay;


reg transfer;
wire transfer_in;
reg last_transfer;
reg start_transfer;
reg [addr_width -1:0 ] addr_stream_in;
reg [addr_width-1 : 0] addr_stream_out;


wire [addr_width - 1: 0]agu_addr_write_0,agu_addr_write_1;
wire [addr_width - 1: 0] agu_addr_read_0,agu_addr_read_1;

wire agu_mem_wr_en;
wire mem_wr_en_0_a,mem_wr_en_0_b,mem_wr_en_1;
wire agu_mem_wr_en_0,agu_mem_wr_en_1;

wire [width-1:0] bf_data_0_in,bf_data_1_in;

wire [addr_width - 1: 0] addr_stream_in_rev;


wire ram_select_mem;

/// Twiddle rom
wire rom_en = 1;
twiddle_factor #(64,512,9) tw_f (clk,rom_en,k,n,omega);
/// AGU k = j ; n = i
AGU #(10,9) agu (clk,rst,start,mem_addr_0,mem_addr_1,ram_select,k,n,done,ex_en,overflow_delay);



/// Butterfly 
butterfly  bf(even_in,odd_in,omega,even_out,odd_out);
//assign odd_out = odd_in;
//assign even_out = even_in;
// write and read address
delay #(addr_width,1) del_addr0 (clk,mem_addr_0,agu_addr_write_0);


delay #(addr_width,1) del_addr1 (clk,mem_addr_1,agu_addr_write_1);

assign agu_addr_read_0 = mem_addr_0;
assign agu_addr_read_1 = mem_addr_1;


wire ram_del;
// delay wr_en
delay #(1,1) del_wren(clk,ex_en,agu_mem_wr_en);
delay #(1,1) del_ram_sel(clk,ram_select,ram_del);


assign agu_mem_wr_en_0 = ram_del ? 1'b0 : agu_mem_wr_en;
assign agu_mem_wr_en_1 = ram_del ? agu_mem_wr_en : 1'b0 ;

/// 
ram_block mem( clk,mem_wr_en_0_a,mem_wr_en_0_b,mem_wr_en_1,mem_wr_en_1,
                ram_select_mem,addr_write_0, addr_write_1,addr_read_0,
                addr_read_1, mem_data_0_in,mem_data_1_in,mem_data_0_out,
                mem_data_1_out);

assign even_in = mem_data_0_out;
assign odd_in = mem_data_1_out;

assign bf_data_0_in = even_out;
assign bf_data_1_in = odd_out;

assign ram_select_mem = transfer_in ? 0 : ram_del;

// Bit reversal
bit_reverse br (addr_stream_in, addr_stream_in_rev);

assign mem_wr_en_0_a = transfer_in ? s00_axis_tvalid : agu_mem_wr_en_0;
assign mem_wr_en_0_b = transfer_in ? 1'b0 : agu_mem_wr_en_0;

assign mem_wr_en_1 = transfer_in ? 1'b0 : agu_mem_wr_en_1;

assign mem_data_0_in = transfer_in ? s00_axis_tdata : bf_data_0_in;
assign mem_data_1_in = transfer_in ? s00_axis_tdata : bf_data_1_in;
assign addr_write_0 = transfer_in ? addr_stream_in_rev : agu_addr_write_0;
assign addr_write_1 = transfer_in ? addr_stream_in_rev : agu_addr_write_1;


assign addr_read_0 = transfer ? addr_stream_out :  agu_addr_read_0;
assign addr_read_1 = agu_addr_read_1;
// AXI-Control

assign s00_axis_tready = !ex_en & !transfer;
assign transfer_in = s00_axis_tready;
//always @(posedge clk) begin
//    if(!rst ||s00_axis_tlast) begin
//        transfer_in <= 0;
//    end
//    else if ( s00_axis_tready  ) begin 
//        transfer_in <= 1;
//    end
//end



always @ (posedge clk) begin

    if (!rst || s00_axis_tlast)

        addr_stream_in <= 0;

    else if (s00_axis_tready && s00_axis_tvalid ) // TODO: When should the address change? refer to the AXI-Stream Slave protocol and the control flags.

        addr_stream_in <= addr_stream_in +1; // TODO: what should the next address be?

end


// Stream out data via master

assign m00_axis_tdata = mem_data_0_out;
assign m00_axis_tlast =last_transfer; 
assign m00_axis_tvalid = transfer||start_transfer;


always @ (posedge clk) begin
    if (!rst || m00_axis_tlast ) 

        addr_stream_out <= 0;

    else if (done || transfer) 

        addr_stream_out <=addr_stream_out +1 ;
end


always @ (posedge clk) begin

    if (!rst)

        start_transfer <= 0;

    else

        start_transfer <=done ; 
end

always @ (posedge clk) begin
        if (!rst || last_transfer )
            transfer <= 0;
        else if (done) 
            transfer <= 1;
end

always @ (posedge clk) begin
    if (!rst)
        last_transfer <= 0;
    else
        last_transfer <= ((addr_stream_out) == (1024 - 1)); 
end
endmodule