`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.10.2026 14:53:14
// Design Name: 
// Module Name: ALUdec
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


module ALUdec(
    input  logic        opb5,      // instruction bit [5] of opcode
    input  logic [2:0]  funct3,    // funct3 field of instruction
    input  logic        funct7b5,  // bit 5 of funct7 field
    input  logic [1:0]  ALUOp,     // high-level ALU operation
    output logic [2:0]  ALUControl // ALU operation code
    );
    always_comb
    begin
     case(ALUOp)
        2'b00: ALUControl = 3'b000;
        2'b01: ALUControl = 3'b001;

        2'b10:
          begin
         case(funct3)
          3'b000:
           begin
            if(opb5 && funct7b5)
              ALUControl = 3'b001;
            else
              ALUControl = 3'b000;
           end
          3'b111: ALUControl = 3'b010;
          3'b110: ALUControl = 3'b011;
          3'b010: ALUControl = 3'b101;
          default: ALUControl = 3'b000;
         endcase
       end

       default: ALUControl = 3'b000;
      endcase
end
    
endmodule
