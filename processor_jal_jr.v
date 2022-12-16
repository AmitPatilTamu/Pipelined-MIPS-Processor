`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////
////////
// Company:
// Engineer:
//
// Create Date:    11:42:15 04/01/2008
// Design Name:
// Module Name:    Pipelined
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
module PipelinedProc(CLK, Reset_L, startPC, dMemOut);
input CLK;
input Reset_L;
input [31:0] startPC;
output [31:0] dMemOut;
//Hazard
wire Bubble;
wire PCWrite;
wire IFWrite;
//Stage 1
wire [31:0] currentPCPlus4;
wire [31:0] jumpDescisionTarget;
wire [31:0] nextPC;
reg [31:0] currentPC;
wire [31:0] currentInstruction;
//Stage 2
reg [31:0] currentInstruction2, ID_currentPCPlus4;
wire [5:0] opcode;
wire [4:0] rs, rt, rd;
wire [15:0] imm16;
wire [4:0] shamt;
wire [5:0] func;
wire [31:0] busA, busB, ALUImmRegChoice, signExtImm;
wire [31:0] jumpTarget, jumpTarget_1;
wire [1:0] addrSel;
//Stage 2 Control Wires
wire regDst, memToReg, regWrite, memRead, memWrite, branch, 
jump, signExtend;
wire UseShiftField;
wire rsUsed, rtUsed;
wire [4:0] rw;
wire [3:0] aluOp;
wire [31:0] ALUBIn;
wire [31:0] ALUAIn;
wire [1:0] AluOpCtrlA_ID, AluOpCtrlB_ID;
//Stage 3
reg [31:0] ALUAIn3, ALUBIn3, busB3, signExtImm3, busA3;
wire [4:0] rw3, rw3_1;
wire [5:0] func3;
wire [31:0] shiftedSignExtImm;
wire [31:0] branchDst;
wire [3:0] aluCtrl;
wire aluZero;
wire [31:0] aluOut_1, aluOut;
wire [4:0] Shamt_ID_EX;
wire [31:0] Data_Memory_Input_ID_EX;
wire Jal, Jr;
//Stage 3 Control
reg regDst3, memToReg3, regWrite3, memRead3, memWrite3;
reg [3:0] aluOp3;
reg [4:0] rt3, rd3; 
reg [31:0] EX_currentPCPlus4;
reg [20:0] Ins_ID_EX;
reg DataMemForwardCtrl_EX_ID_EX, DataMemForwardCtrl_MEM_ID_EX;
reg [1:0] AluOpCtrlA_ID_EX, AluOpCtrlB_ID_EX;
reg EX_Jal;
//Stage 4
//reg aluZero4;
reg [31:0] aluOut4, busB4;
reg [4:0] rw4;
wire [31:0] memOut;
//assign dMemOut = memOut;
//Stage 4 Control
reg memToReg4, regWrite4, memRead4, memWrite4;
reg [31:0] Data_Memory_Input_EX_MEM;
wire [31:0] Data_Memory_in;
reg DataMemForwardCtrl_MEM_EX_MEM;
//Stage 5
reg [31:0] memOut5, aluOut5;
reg [4:0] rw5;
wire [31:0] regWriteData;
//Stage 5 Control
reg memToReg5, regWrite5;

//Stage 1 Logic
/*Below is a special case.  If we are doing a jump, and IFWrite is 
set to true,
then we have completed the jump.  That means we are not jumping 
anymore.
Same is true of a branch that we just took.
*/
//assign #1 jumpDescisionTarget = (jump & ~IFWrite) ? jumpTarget : currentPCPlus4;
//assign #1 nextPC = (branch4 & aluZero4 & ~IFWrite) ? branchDst4 : jumpDescisionTarget;
assign #1 nextPC = (addrSel == 2'b00)?currentPCPlus4:((addrSel == 2'b01)?(Jr?busA:jumpTarget):branchDst);
//assign jumpTarget_1= Jr?busA:jumpTarget;
always @ (negedge CLK) begin
if(~Reset_L)
    currentPC = startPC;
else if(PCWrite)
    currentPC = nextPC;
end
assign #2 currentPCPlus4 = currentPC + 4;
InstructionMemory instrMemory(currentInstruction, currentPC);
//Stage 2 Logic
always @ (negedge CLK or negedge Reset_L) begin
if(~Reset_L) begin
    currentInstruction2 <= 32'b0;
    ID_currentPCPlus4 <= 32'b0;
    end
else if(IFWrite) begin
    currentInstruction2 <= currentInstruction;
    ID_currentPCPlus4 <= currentPCPlus4;
end
end
assign {opcode, rs, rt, rd, shamt, func} = currentInstruction2;
assign imm16 = currentInstruction2[15:0];
PipelinedControl controller(regDst, alusrc1, alusrc2, memToReg, regWrite, memRead, memWrite, branch, jump, signExtend, aluOp, opcode, func, Jal, Jr);
//assign #1 rw = regDst ? rd : rt;
//assign #2 UseShiftField = ((aluOp == 4'b1111) && ((func == 6'b000000) || (func == 6'b000010) || (func == 6'b000011)));
//assign #2 rsUsed = (opcode != 6'b001111/*LUI*/) & ~UseShiftField;
//assign #1 rtUsed = (opcode == 6'b0) || branch || (opcode == 6'b101011/*SW*/);
//Hazard hazard(PCWrite, IFWrite, Bubble, branch, aluZero4, jump,regWrite ? rw : 5'b0,rsUsed ? rs : 5'b0,rtUsed ? rt : 5'b0,Reset_L, CLK);
HazardUnit hazard (.IF_write(IFWrite), .PC_write(PCWrite), .bubble(Bubble), .addrSel(addrSel), .Jump(jump), .Branch(branch), .ALUZero(aluZero),
.memReadEX(memRead3), .currRs(rs), .currRt(rt), .prevRt(rw3_1), .UseShamt(alusrc2), .UseImmed(alusrc1), .Clk(CLK), .Rst(Reset_L), .Jr(Jr), .EX_RegWrite(regWrite3),
 .MEM_RegWrite(regWrite4), .EX_Rw(rw3), .MEM_Rw(rw4));
RegisterFile Registers(busA, busB, regWriteData, rs, rt, rw5, regWrite5, CLK);
SignExtender immExt(signExtImm, imm16, ~signExtend);

assign jumpTarget = {currentPC[31:28], currentInstruction2[25:0], 2'b00};
//forwarding UNit
ForwardingUnit FU( .UseShamt(alusrc2), .UseImmed(alusrc1), .ID_Rs(rs),.ID_Rt(rt), .EX_Rw(rw3),.MEM_Rw(rw4), .EX_RegWrite(regWrite3), .MEM_RegWrite(regWrite4), .AluOpCtrlA(AluOpCtrlA_ID), .AluOpCtrlB(AluOpCtrlB_ID),
.DataMemForwardCtrl_EX(DataMemForwardCtrl_EX_IF_ID), .DataMemForwardCtrl_MEM(DataMemForwardCtrl_MEM_IF_ID) );
//assign #2 ALUImmRegChoice = alusrc1 ? signExtImm : busB;
//assign #2 ALUAIn = alusrc2 ? busB : busA;
//assign #2 ALUBIn = alusrc2 ? {27'b0, shamt} : ALUImmRegChoice;

//Stage 3 Logic
always @ (negedge CLK or negedge Reset_L) begin
if(~Reset_L) begin
//ALUAIn3 <= 0;
//ALUBIn3 <= 0;
busB3 <= 0;
busA3 <= 0;
signExtImm3 <= 0;
//rw3 <= 0;
regDst3 <= 0;
memToReg3 <= 0;
regWrite3 <= 0;
memRead3 <= 1'b0;
memWrite3 <= 0;
//branch3 <= 0;
aluOp3 <= 0;
Ins_ID_EX <= 21'b0;
//rs3 <= 32'b0;
rt3 <= 5'b00000;
rd3 <= 5'b00000;
DataMemForwardCtrl_EX_ID_EX <= 0;
DataMemForwardCtrl_MEM_ID_EX<= 0;
AluOpCtrlA_ID_EX <= 2'b00;
AluOpCtrlB_ID_EX <= 2'b00;
EX_Jal <= 1'b0;
EX_currentPCPlus4 <= 32'b0;
end
else if(Bubble) begin
//ALUAIn3 <= 0;
//ALUBIn3 <= 0;
busB3 <= 0;
busA3 <= 0;
signExtImm3 <= 0;
//rw3 <= 0;
regDst3 <= 0;
memToReg3 <= 0;
regWrite3 <= 0;
memRead3 <= 1'b0;
memWrite3 <= 0;
//branch3 <= 0;
aluOp3 <= 0;
Ins_ID_EX <= 21'b0;
//rs3 <= 32'b0;
rt3 <= 5'b00000;
rd3 <= 5'b00000;
AluOpCtrlA_ID_EX <= 2'b00;
AluOpCtrlB_ID_EX <= 2'b00;
DataMemForwardCtrl_EX_ID_EX <= 0;
DataMemForwardCtrl_MEM_ID_EX<= 0;
EX_Jal <= 1'b0;
EX_currentPCPlus4 <= 32'b0;
end
else begin
//ALUAIn3 <= ALUAIn;
//ALUBIn3 <= ALUBIn;
busB3 <= busB;
busA3 <= busA;
signExtImm3 <= signExtImm;
//rw3 <= rw;
regDst3 <= regDst;
memToReg3 <= memToReg;
regWrite3 <= regWrite;
memRead3 <= memRead;
memWrite3 <= memWrite;
//branch3 <= branch;
aluOp3 <= aluOp;
Ins_ID_EX <= currentInstruction2[20:0];
//rs3 <= rs;
rt3 <= rt;
rd3 <= rd;
DataMemForwardCtrl_EX_ID_EX <= DataMemForwardCtrl_EX_IF_ID;
DataMemForwardCtrl_MEM_ID_EX<= DataMemForwardCtrl_MEM_IF_ID;
AluOpCtrlA_ID_EX <= AluOpCtrlA_ID;
AluOpCtrlB_ID_EX <= AluOpCtrlB_ID;
EX_Jal <= Jal;
EX_currentPCPlus4 <= ID_currentPCPlus4;
end
end
assign func3 = signExtImm3[5:0];

//assign RT_ID_EX = Ins_ID_EX[20:16];
//assign RD_ID_EX = Ins_ID_EX[15:11];
assign Shamt_ID_EX = Ins_ID_EX[10:6];
assign rw3_1 = regDst3?rd3:rt3;
assign rw3 = EX_Jal?(5'b11111):rw3_1;

// ALU input 1 
always @(*)begin 
case (AluOpCtrlA_ID_EX)
2'b00: ALUAIn3 = {27'b0, Shamt_ID_EX};
2'b01: ALUAIn3 = regWriteData;
2'b10: ALUAIn3 = aluOut4;
2'b11: ALUAIn3 = busA3;
endcase
end 
//ALU input 2 
always @(*)begin 
case (AluOpCtrlB_ID_EX)
2'b00: ALUBIn3 = signExtImm3;
2'b01: ALUBIn3 = regWriteData;
2'b10: ALUBIn3 = aluOut4;
2'b11: ALUBIn3 = busB3;
endcase
end 

ALUControl mainALUControl(aluCtrl, aluOp3, func3);
ALU mainALU(aluOut_1, aluZero, ALUAIn3, ALUBIn3, aluCtrl);
assign shiftedSignExtImm = signExtImm3<<2;
assign #2 branchDst = currentPC + shiftedSignExtImm;
assign aluOut = EX_Jal?EX_currentPCPlus4:aluOut_1;
assign Data_Memory_Input_ID_EX = DataMemForwardCtrl_EX_ID_EX ?  regWriteData : busB3;


//Stage 4 Logic
always @ (negedge CLK or negedge Reset_L) begin
if(~Reset_L) begin
//aluZero4 <= 0;
//branchDst4 <= 0;
aluOut4 <= 32'h00000000;
//busB4 <= 0;
rw4 <= 5'b00000;
memToReg4 <= 0;
regWrite4 <= 0;
memRead4 <= 0;
memWrite4 <= 0;
//branch4 <= 0;
Data_Memory_Input_EX_MEM <= 32'b0;
DataMemForwardCtrl_MEM_EX_MEM <= 0;
end
else begin
//aluZero4 <= aluZero;
//branchDst4 <= branchDst;
aluOut4 <= aluOut;
//busB4 <= busB3;
rw4 <= rw3;
memToReg4 <= memToReg3;
regWrite4 <= regWrite3;
memRead4 <= memRead3;
memWrite4 <= memWrite3;
//branch4 <= branch3;
Data_Memory_Input_EX_MEM <= Data_Memory_Input_ID_EX;
DataMemForwardCtrl_MEM_EX_MEM <= DataMemForwardCtrl_MEM_ID_EX;
end
end

assign Data_Memory_in = DataMemForwardCtrl_MEM_EX_MEM ? regWriteData: Data_Memory_Input_EX_MEM;

DataMemory dmem(memOut, aluOut4[5:0], Data_Memory_in, memRead4, memWrite4, CLK);
//Stage 5 Logic
always @ (negedge CLK or negedge Reset_L) begin
if(~Reset_L) begin
memOut5 <= 32'h00000000;
aluOut5 <= 32'h00000000;
rw5 <= 0;
memToReg5 <= 0;
regWrite5 <= 0;
end
else begin
memOut5 <= memOut;
aluOut5 <= aluOut4;
rw5 <= rw4;
memToReg5 <= memToReg4;
regWrite5 <= regWrite4;
end
end
assign #1 regWriteData = memToReg5 ? memOut5 : aluOut5;
// actual output 
assign dMemOut = memOut5;
endmodule
