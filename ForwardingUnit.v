`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2022 10:45:53 PM
// Design Name: 
// Module Name: ForwardingUnit
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


module ForwardingUnit ( UseShamt , UseImmed , ID_Rs, ID_Rt, EX_Rw, MEM_Rw,
EX_RegWrite, MEM_RegWrite, AluOpCtrlA, AluOpCtrlB, DataMemForwardCtrl_EX ,
DataMemForwardCtrl_MEM ) ;
input UseShamt , UseImmed ;
input [4:0] ID_Rs, ID_Rt, EX_Rw, MEM_Rw;
input EX_RegWrite, MEM_RegWrite ;
output reg [1:0] AluOpCtrlA, AluOpCtrlB ;
output DataMemForwardCtrl_EX, DataMemForwardCtrl_MEM ;

//generate alu input 1 mux select signal
always @(*)
begin
if(UseShamt)
	 AluOpCtrlA<=2'b00;
else if((ID_Rs==EX_Rw) && EX_RegWrite && (EX_Rw!=0))
	 AluOpCtrlA<=2'b10;
else if ((MEM_Rw==ID_Rs) && MEM_RegWrite && (MEM_Rw!=0))
	 AluOpCtrlA<=2'b01;
else
	AluOpCtrlA<=2'b11;
end

//generate alu input 2 mux select signal
always @(*)
begin
if(UseImmed)
	 AluOpCtrlB<=2'b00;
else if(EX_Rw==ID_Rt && EX_RegWrite && (EX_Rw!=0))
	 AluOpCtrlB<=2'b10;
else if (MEM_Rw==ID_Rt && MEM_RegWrite && (MEM_Rw!=0))
	 AluOpCtrlB<=2'b01;
else
     AluOpCtrlB<=2'b11;
		
end

//generating the data memory input mux select signals
assign DataMemForwardCtrl_EX = (MEM_Rw==ID_Rt) && MEM_RegWrite && (MEM_Rw!=0);
assign DataMemForwardCtrl_MEM = (EX_Rw==ID_Rt) && EX_RegWrite && (EX_Rw!=0);

endmodule
