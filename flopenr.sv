`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.10.2026 18:29:27
// Design Name: 
// Module Name: flopenr
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


module flopenr #(parameter WIDTH = 8)(
    input logic [WIDTH-1:0] d,
    input logic clk,
    input logic reset,
    input logic en,
    output logic [WIDTH-1:0] q
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            q <= '0;
        else if (en)
            q <= d;
    end
endmodule
