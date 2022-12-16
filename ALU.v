`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/28/2022 11:17:38 AM
// Design Name: 
// Module Name: ALU
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

`define AND 4'b0000
`define OR 4'b0001
`define ADD 4'b0010
`define SLL 4'b0011
`define SRL 4'b0100
`define SUB 4'b0110
`define SLT 4'b0111
`define ADDU 4'b1000
`define SUBU 4'b1001
`define XOR 4'b1010
`define SLTU 4'b1011
`define NOR 4'b1100
`define SRA 4'b1101
`define LUI 4'b1110
module ALU(BusW, Zero, BusA, BusB, ALUCtrl
    );
input wire [31:0] BusA, BusB;
output reg [31:0] BusW;
input wire [3:0] ALUCtrl ;
output wire Zero ;

wire less;
wire [63:0] Bus64;
assign Zero = BusW?0:1;
assign less = ({1'b0,BusA} < {1'b0,BusB}  ? 1'b1 : 1'b0);
//assign Bus64 = BusA >>> BusB;
always@(*)begin	
	
	case (ALUCtrl)
	`AND:   BusW <= BusA & BusB;
	`OR:    BusW <= BusA | BusB;
	`ADD:   BusW <= BusA + BusB;
	`ADDU:  BusW <= BusA + BusB; //same as ADD
	`SLL:   BusW <= BusB<<BusA;
	`SRL:   BusW <= BusB>>BusA;
	`SUB:   BusW <= BusA + (~BusB +1); // same as addition with 2's complemennt
	`SUBU:  BusW <= BusA + (~BusB +1); //same as SUB
	`XOR:   BusW <= BusA^BusB;
	`NOR:   BusW <= ~(BusA|BusB);
	`SLT:   begin 
	        if ($signed(BusA) < $signed(BusB)) begin   //$signed is synthesizable 
		           BusW <= 1;
		    end else begin
		           BusW <= 0;
		    end
		    end
	`SLTU:  BusW <= less;
	`SRA:   BusW <= $signed(BusB)>>>BusA; // >>> is arithmatic shift operator in verilog
	`LUI:   BusW <= BusB<<16; // left shifting by 16 will load the BusB in upper half word of BusW
	default:BusW <= BusA;
	endcase
end
endmodule

