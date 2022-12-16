`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/02/2022 02:02:43 AM
// Design Name: 
// Module Name: HazardUnit
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


module HazardUnit (IF_write , PC_write , bubble , addrSel , Jump , Branch , ALUZero ,
memReadEX, currRs , currRt , prevRt , UseShamt , UseImmed , Clk , Rst, Jr, EX_RegWrite, MEM_RegWrite, EX_Rw, MEM_Rw ) ;
output reg IF_write, PC_write, bubble;
output reg [1:0] addrSel ;
input Jump , Branch , ALUZero , memReadEX, Clk , Rst ;
input UseShamt , UseImmed ;
input [4:0] currRs , currRt , prevRt ;
input [4:0] EX_Rw, MEM_Rw;
input Jr, EX_RegWrite, MEM_RegWrite;
//4 states in mealy FSM
parameter NoHazard_state=2'b00;
parameter Jump_state=2'b01;
parameter Branch0_state=2'b10;
parameter Branch1_state=2'b11;
reg LdHazard;
wire JrHazard;
reg [1:0] FSM_state, FSM_nxt_state;

//jr hazard detection
assign JrHazard = ((Jr == 1) && ((EX_Rw == currRs && EX_RegWrite == 1)||(MEM_Rw == currRs && MEM_RegWrite == 1))) ? 1:0;
//load hazard detection
always @ (*)
begin
if (prevRt!=0 && memReadEX ==1)
	begin
	case({memReadEX, UseShamt, UseImmed})
	3'b100: if((currRs==prevRt)||(currRt==prevRt))
	           	LdHazard<=1;
	        else
	            LdHazard<=0;
    3'b110: if(currRs==prevRt)
                LdHazard<=1;
            else
                LdHazard<=0;
    3'b101: if(currRs==prevRt)
                LdHazard<=1;
            else
                LdHazard<=0;
	default: 	LdHazard<=0;
	endcase	
	end
else 
	LdHazard<=0;
end

//state change
always @(negedge Clk)
	begin
	if(Rst==0)
		FSM_state<=NoHazard_state;
	else
		FSM_state<=FSM_nxt_state;
	end


//next state logic and output logic of mealy FSM
always @(*)
begin
case(FSM_state)
NoHazard_state: begin
            if ((LdHazard==1'b1) || (JrHazard==1'b1))
				begin
				IF_write=1'b0;
				PC_write=1'b0;
				bubble=1'b1;
				addrSel=2'b00;
				FSM_nxt_state=NoHazard_state;
				end
			else if (Jump==1'b1)
		    	begin
			    IF_write=1'b0;
			    PC_write=1'b1;
			    bubble=1'b0;
			    addrSel=2'b01;
			    FSM_nxt_state=Jump_state;
			end
			else if(Branch==1'b1)
				begin
				IF_write=1'b0;
				PC_write=1'b0;
				bubble=1'b0;
				addrSel=2'b00;
				FSM_nxt_state=Branch0_state;
				end
			else
				begin
				IF_write=1'b1;
				PC_write=1'b1;
				bubble=1'b0;
				addrSel=2'b00;
				FSM_nxt_state=NoHazard_state;
				end		
		end
Jump_state: begin
		IF_write=1'b1;
		PC_write=1'b1;
		bubble=1'b1;
		addrSel=2'b00;
		FSM_nxt_state=NoHazard_state;
		end
Branch0_state:
begin
		if(ALUZero==1'b0)
		begin
		IF_write=1'b1;
		PC_write=1'b1;
		bubble=1'b1;
		addrSel=2'b00;
		FSM_nxt_state=NoHazard_state;
		end
		else
		begin
		IF_write=1'b0;
		PC_write=1'b1;
		bubble=1'b1;
		addrSel=2'b10;
		FSM_nxt_state=Branch1_state;
		end
end
Branch1_state:
begin
		IF_write=1'b1;
		PC_write=1'b1;
		bubble=1'b1;
		addrSel=2'b00;
		FSM_nxt_state=NoHazard_state;
end
default: FSM_nxt_state=NoHazard_state;
endcase
end

endmodule