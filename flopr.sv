`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.10.2026 14:17:36
// Design Name: 
// Module Name: flopr
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


module flopr#(parameter WIDTH = 8)(
    input  logic [WIDTH-1:0] d,     // Data input
    input  logic              clk,   // Clock
    input  logic              reset, // Asynchronous reset
    output logic [WIDTH-1:0] q      // Data output
    );
    always_ff@(posedge clk or posedge reset)
    begin
    if (reset)
      q<='0;
    else
      q<=d;
    end
     
endmodule
