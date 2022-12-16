`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////
////////
// Company:
// Engineer:
//
// Create Date:    12:23:34 03/10/2009
// Design Name:
// Module Name:    PipelinedControl
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////
////////
`define RTYPEOPCODE 6'b000000
`define LWOPCODE        6'b100011
`define SWOPCODE        6'b101011
`define BEQOPCODE       6'b000100
`define JOPCODE     6'b000010
`define ORIOPCODE       6'b001101
`define ADDIOPCODE  6'b001000
`define ADDIUOPCODE 6'b001001
`define ANDIOPCODE  6'b001100
`define LUIOPCODE       6'b001111
`define SLTIOPCODE  6'b001010
`define SLTIUOPCODE 6'b001011
`define XORIOPCODE  6'b001110
`define JALOPCODE 6'b000011

`define SLLFunc 6'b000000
`define SRLFunc 6'b000010
`define SRAFunc 6'b000011
`define JRFunc 6'b001000
`define AND     4'b0000
`define OR      4'b0001
`define ADD     4'b0010
`define SLL     4'b0011
`define SRL     4'b0100
`define SUB     4'b0110
`define SLT     4'b0111
`define ADDU    4'b1000
`define SUBU    4'b1001
`define XOR     4'b1010
`define SLTU    4'b1011
`define NOR     4'b1100
`define SRA     4'b1101
`define LUI     4'b1110
`define FUNC    4'b1111
module PipelinedControl(RegDst, ALUSrc1, ALUSrc2, MemToReg, RegWrite, MemRead, 
MemWrite, Branch, Jump, SignExtend, ALUOp, Opcode, func, Jal, Jr);
input [5:0] Opcode;
input [5:0] func;

output RegDst;
output ALUSrc1, ALUSrc2;
output MemToReg;
output RegWrite;
output MemRead;
output MemWrite;
output Branch;
output Jump;
output SignExtend;
output [3:0] ALUOp;
output Jal, Jr;
reg Jal, Jr;
reg RegDst, ALUSrc1, MemToReg, RegWrite, MemRead, MemWrite, Branch, ALUSrc2, Jump, SignExtend;
reg  [3:0] ALUOp;
always @ (Opcode or func) begin
/*if(bubble) begin
            RegDst <= #2 0; 
            ALUSrc1 <= #2 0;
            ALUSrc2 <= #2 0;
            MemToReg <= #2 0;
            RegWrite <= #2 0;
            MemRead <= #2 0;
            MemWrite <= #2 0;
            Branch <= #2 0;
            Jump <= #2 0;
            SignExtend <= #2 1'b0;
            ALUOp <= #2 `FUNC;
end
else begin*/
case(Opcode)
          `RTYPEOPCODE: begin
            RegDst <= #2 1'b1; 
            ALUSrc1 <= #2 1'b0;
            //for shift operations
            if ((func == 6'b000000) || (func == 6'b000010) || (func == 6'b000011))
                ALUSrc2 <= #2 1'b1;
            else
                ALUSrc2 <= #2 1'b0;
            MemToReg <= #2 1'b0;
            RegWrite <= #2 1'b1;
            MemRead <= #2 1'b0;
            MemWrite <= #2 1'b0;
            Branch <= #2 1'b0;
            SignExtend <= #2 1'b0;
            ALUOp <= #2 `FUNC;
            Jal <= #2 1'b0;
            if (func == 6'b001000) begin 
                Jr <= 1'b1;
                Jump <= 1'b1;
            end else begin
                Jr <= 1'b0;
                Jump <= 1'b0;
                end
            end
           `LWOPCODE: begin
            RegDst <= #2 1'b0;
            ALUSrc1 <= #2 1'b1;
            ALUSrc2 <= #2 1'b0;
            MemToReg <= #2 1'b1;
            RegWrite <= #2 1'b1;
            MemRead <= #2 1'b1;
            MemWrite <= #2 1'b0;
            Branch <= #2 1'b0;
            Jump <= #2 1'b0;
            SignExtend <= #2 1'b1;
            ALUOp <= #2 `ADD;
            Jr <= 1'b0;
            Jal <= 1'b0;
            end        
           `SWOPCODE: begin
            RegDst <= #2 1'b0;
            ALUSrc1 <= #2 1'b1;
            ALUSrc2 <= #2 1'b0;
            MemToReg <= #2 1'b1;
            RegWrite <= #2 1'b0;
            MemRead <= #2 1'b0;
            MemWrite <= #2 1'b1;
            Branch <= #2 1'b0;
            Jump <= #2 1'b0;
            SignExtend <= #2 1'b1;
            ALUOp <= #2 `ADD;
            Jr <= 1'b0;
            Jal <= 1'b0;     
            end 
           `BEQOPCODE:begin
            RegDst <= #2 1'bx;
            ALUSrc1 <= #2 1'b0;
            ALUSrc2 <= #2 1'b0;
            MemToReg <= #2 1'bx;
            RegWrite <= #2 1'b0;
            MemRead <= #2 1'b0;
            MemWrite <= #2 1'b0;
            Branch <= #2 1'b1;
            Jump <= #2 1'b0;
            SignExtend <= #2 1'b1;
            ALUOp <= #2 `SUB; 
            Jr <= 1'b0;
            Jal <= 1'b0;         
            end    
           `JOPCODE:  begin
             RegDst <= #2 1'bx;
            ALUSrc1 <= #2 1'b0;
            ALUSrc2 <= #2 1'b0;
            MemToReg <= #2 1'bx;
            RegWrite <= #2 1'b0;
            MemRead <= #2 1'b0;
            MemWrite <= #2 1'b0;
            Branch <= #2 1'b0;
            Jump <= #2 1'b1;
            SignExtend <= #2 1'b1;
            ALUOp <= #2 `AND;
            Jr <= 1'b0;
            Jal <= 1'b0;        
            end    
           `ORIOPCODE: begin
             RegDst <= #2 1'b0;
            ALUSrc1 <= #2 1'b1;
            ALUSrc2 <= #2 1'b0;
            MemToReg <= #2 1'b0;
            RegWrite <= #2 1'b1;
            MemRead <= #2 1'b0;
            MemWrite <= #2 1'b0;
            Branch <= #2 1'b0;
            Jump <= #2 1'b0;
            SignExtend <= #2 1'b0;
            ALUOp <= #2 `OR;
            Jr <= 1'b0;
            Jal <= 1'b0;        
            end       
           `ADDIOPCODE: begin
            RegDst <= #2 1'b0;
            ALUSrc1 <= #2 1'b1;
            ALUSrc2 <= #2 1'b0;
            MemToReg <= #2 1'b0;
            RegWrite <= #2 1'b1;
            MemRead <= #2 1'b0;
            MemWrite <= #2 1'b0;
            Branch <= #2 1'b0;
            Jump <= #2 1'b0;
            SignExtend <= #2 1'b1;
            ALUOp <= #2 `ADD;   
            Jr <= 1'b0;
            Jal <= 1'b0;       
            end  
           `ADDIUOPCODE:  begin
            RegDst <= #2 1'b0;
            ALUSrc1 <= #2 1'b1;
            ALUSrc2 <= #2 1'b0;
            MemToReg <= #2 1'b0;
            RegWrite <= #2 1'b1;
            MemRead <= #2 1'b0;
            MemWrite <= #2 1'b0;
            Branch <= #2 1'b0;
            Jump <= #2 1'b0;
            SignExtend <= #2 1'b0;
            ALUOp <= #2 `ADDU; 
            Jr <= 1'b0;
            Jal <= 1'b0;         
            end 
           `ANDIOPCODE:  begin
             RegDst <= #2 1'b0;
            ALUSrc1 <= #2 1'b1;
            ALUSrc2 <= #2 1'b0;
            MemToReg <= #2 1'b0;
            RegWrite <= #2 1'b1;
            MemRead <= #2 1'b0;
            MemWrite <= #2 1'b0;
            Branch <= #2 1'b0;
            Jump <= #2 1'b0;
            SignExtend <= #2 1'b0;
            ALUOp <= #2 `AND; 
            Jr <= 1'b0;
            Jal <= 1'b0;         
            end 
           `LUIOPCODE:  begin
            RegDst <= #2 1'b0;
            ALUSrc1 <= #2 1'b1;
            ALUSrc2 <= #2 1'b0;
            MemToReg <= #2 1'b0;
            RegWrite <= #2 1'b1;
            MemRead <= #2 1'b0;
            MemWrite <= #2 1'b0;
            Branch <= #2 1'b0;
            Jump <= #2 1'b0;
            SignExtend <= #2 1'b0;
            ALUOp <= #2 `LUI;  
            Jr <= 1'b0;
            Jal <= 1'b0;        
            end     
           `SLTIOPCODE: begin
            RegDst <= #2 1'b0;
            ALUSrc1 <= #2 1'b1;
            ALUSrc2 <= #2 1'b0;
            MemToReg <= #2 1'b0;
            RegWrite <= #2 1'b1;
            MemRead <= #2 1'b0;
            MemWrite <= #2 1'b0;
            Branch <= #2 1'b0;
            Jump <= #2 1'b0;
            SignExtend <= #2 1'b1;
            ALUOp <= #2 `SLT; 
            Jr <= 1'b0;
            Jal <= 1'b0;         
            end  
           `SLTIUOPCODE: begin
            RegDst <= #2 1'b0;
            ALUSrc1 <= #2 1'b1;
            ALUSrc2 <= #2 1'b0;
            MemToReg <= #2 1'b0;
            RegWrite <= #2 1'b1;
            MemRead <= #2 1'b0;
            MemWrite <= #2 1'b0;
            Branch <= #2 1'b0;
            Jump <= #2 1'b0;
            SignExtend <= #2 1'b1;
            ALUOp <= #2 `SLTU; 
            Jr <= 1'b0;
            Jal <= 1'b0;         
            end 
           `XORIOPCODE:   begin
            RegDst <= #2 1'b0;
            ALUSrc1 <= #2 1'b1;
            ALUSrc2 <= #2 1'b0;
            MemToReg <= #2 1'b0;
            RegWrite <= #2 1'b1;
            MemRead <= #2 1'b0;
            MemWrite <= #2 1'b0;
            Branch <= #2 1'b0;
            Jump <= #2 1'b0;
            SignExtend <= #2 1'b0;
            ALUOp <= #2 `XOR;  
            Jr <= 1'b0;
            Jal <= 1'b0;        
            end       
           `JALOPCODE:   begin
            RegDst <= #2 1'b0;
            ALUSrc1 <= #2 1'b0;
            ALUSrc2 <= #2 1'b0;
            MemToReg <= #2 1'b0;
            RegWrite <= #2 1'b1;
            MemRead <= #2 1'b0;
            MemWrite <= #2 1'b0;
            Branch <= #2 1'b0;
            Jump <= #2 1'b1;
            SignExtend <= #2 1'b0;
            ALUOp <= #2 4'bxxxx;  
            Jr <= 1'b0;
            Jal <= 1'b1;        
            end   
            default: begin
            RegDst <= #2 1'bx;
            ALUSrc1 <= #2 1'bx;
            ALUSrc2 <= #2 1'bx;
            MemToReg <= #2 1'bx;
            RegWrite <= #2 1'bx;
            MemRead <= #2 1'b0;
            MemWrite <= #2 1'bx;
            Branch <= #2 1'bx;
            Jump <= #2 1'b0;   
            SignExtend <= #2 1'bx;
            ALUOp <= #2 4'bxxxx;
            Jr <= 1'b0;
            Jal <= 1'b0;
   end
endcase
end
//end
endmodule
