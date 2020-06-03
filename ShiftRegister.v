`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/02/2020 02:11:35 PM
// Design Name: 
// Module Name: ShiftRegister
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ShiftRegister(
    input shift_In,
    input clk,
    input reset,
    input en,
    output  [7:0] shift_out 
    );
    reg [7:0] bit ;
    always@(posedge clk) begin
        if(reset)
            bit <= 8'b00000000;
        else begin
        if(en == 1'b1)
        begin
        
        bit<=bit>>1;// MSB to LSB , ">>" shift right operator (<<
        bit[7]<= shift_In; // the input is the MSB
        end
        end   
    end
     assign shift_out=bit;
endmodule
