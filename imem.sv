`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.10.2026 14:27:59
// Design Name: 
// Module Name: imem
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


module imem(
    input  logic [31:0] a,   // Address
    output logic [31:0] rd   // Instruction
    );
    logic [31:0]mem[0:63];
    initial begin
        $readmemh("a.txt", mem); 
  
         assign rd=mem[a[7:2]];
    end
endmodule
