`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/03/2022 07:34:32 PM
// Design Name: 
// Module Name: DataMemory
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


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/21/2022 12:31:41 PM
// Design Name: 
// Module Name: DataMemory
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


module DataMemory(
 output reg [31:0] ReadData, 
 input [5:0] Address,
 input [31:0] WriteData,
 input MemoryRead,
 input MemoryWrite, 
 input Clock 
    );

reg [31:0] DM[63:0];
//reg [31:0] ReadData;
//write    
always @(negedge Clock) begin

if (MemoryWrite) begin
   DM[Address] <= WriteData;   
end
end   

//read
always @(posedge Clock) begin

if (MemoryRead) begin
   ReadData <= DM[Address];
end 
end   
    
    
endmodule
