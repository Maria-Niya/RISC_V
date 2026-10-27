`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.10.2026 14:07:21
// Design Name: 
// Module Name: maindec
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


module maindec(
    input  logic [6:0] op,        // Opcode of the instruction
    output logic [1:0] ResultSrc, // Selects ALU, memory, or PC+4 for writeback
    output logic       MemWrite,   // Enable writing to data memory
    //output logic       MemRead,
    output logic       Branch,     // Branch instruction flag
    output logic       ALUSrc,     // ALU source select (register vs immediate)
    output logic       RegWrite,   // Enable writing to register file
    output logic       Jump,       // Jump instruction flag
    output logic [1:0] ImmSrc,     // Immediate type selector
    output logic [1:0] ALUOp      // ALU operation selector
    );
    always_comb 
    begin
   
       ResultSrc=2'b0;
       MemWrite=0;
       Branch=0;
       ALUSrc=0;
       RegWrite=0;
       Jump=0;
       //MemRead=0;
       ALUOp=2'b00;
       ImmSrc=2'b00;
       
       case(op)
       
       7'b0110011: //r
       begin
       RegWrite=1;
       ALUOp=2'b10;
       end

        7'b0010011:  //I
        begin
        RegWrite=1;
        ALUSrc=1;
        ALUOp=2'b10;
        end
        
        7'b0000011:  //Load
        begin
        ALUSrc=1;
        RegWrite=1;
        //MemRead=1;
        ResultSrc=2'b01;
        end
        
        7'b0100011:  //Store
        begin
        ALUSrc=1;
        MemWrite=1;
        ImmSrc=2'b01;
        end
        
        7'b1100011:  //Branch
        begin
        Branch=1;
        ImmSrc=2'b10;
        ALUOp=2'b01;
        end
        
        7'b1101111:  //Jump
        begin
        Jump=1;
        ResultSrc=2'b10;
        ImmSrc=2'b11;
        RegWrite=1;
        ResultSrc=2'b10;
        end
       endcase
 end   
endmodule
