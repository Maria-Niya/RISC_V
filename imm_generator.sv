module imm_generator(
    input logic [11:0] imm,
    input logic [19:0] imm_uj,
    input logic [6:0] opcode,
    output logic [31:0] imm_out
);
    always_comb begin
        case (opcode)
            7'b0010011, 7'b0000011, 7'b1100111:
                imm_out = {{20{imm[11]}}, imm};
            7'b0100011:
                imm_out = {{20{imm[11]}}, imm};
            7'b1100011:
                imm_out = {{19{imm[11]}}, imm, 1'b0};
            7'b1101111:
                imm_out = {{11{imm_uj[19]}}, imm_uj, 1'b0};
            7'b0110111:
                imm_out = {imm_uj, 12'b0};
            7'b0010111:
                imm_out = {imm_uj, 12'b0};
            default:
                imm_out = 32'b0;
        endcase
    end
endmodule
