`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2022 12:43:08 AM
// Design Name: 
// Module Name: SignExtender
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


module SignExtender( output [31:0] signExtImm, 
input [15:0] imm16, 
input signExtend_L
    );
    
assign signExtImm = (~signExtend_L)?({{16{imm16[15]}},imm16[15:0]}):({{16{1'b0}},imm16[15:0]});

    
endmodule
