`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/21/2022 11:09:23 AM
// Design Name: 
// Module Name: RegisterFile
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


module RegisterFile( 
output [31:0] BusA , 
output [31:0] BusB , 
input [31:0] BusW , 
input [4:0] RA, 
input [4:0] RB , 
input [4:0] RW, 
input RegWr , 
input Clk 
    );

reg [31:0] RF[31:0];



always @(posedge Clk) begin

if (RegWr) begin
//if writing, will not write at zero location, it is hardcoded to 0
    if (RW != 5'b00000) begin
        RF[RW] <= BusW;     
        end
end 
end
//permanently assigning register zero to 0 as mentioned in guidelines
//reading
assign BusA = RA?RF[RA]:0;
assign BusB = RB?RF[RB]:0;



endmodule
