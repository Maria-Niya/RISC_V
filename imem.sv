`timescale 1ns / 1ps

module imem(
    input  logic [31:0] a,   // Address
    output logic [31:0] rd   // Instruction
    );
    logic [31:0]mem[0:63];
    initial begin
        $readmemh("example.txt", mem); 
  
         assign rd=mem[a[7:2]];
    end
endmodule
