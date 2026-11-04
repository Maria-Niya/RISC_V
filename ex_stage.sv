
module ex_stage(
    input logic [31:0] rs1_data,
    input logic [31:0] rs2_data,
    input logic [31:0] imm_out,
    input logic [31:0] address,
    input logic branch,
    input logic alu_src,
    input logic fn7_5,
    input logic mux_inp,
    input logic [2:0] fn3,
    input logic [6:0] imm11_5,
    input logic [4:0] aluop,
    input logic [6:0] opcode,
    output logic and_out_ex,
    output logic [31:0] alu_out,
    output logic [31:0] pc_ex_out
);

    logic [31:0] src_b;
    logic [31:0] pc_signed_offset;
    logic zero;

    mux2 #(.WIDTH(32)) alu_mux(
        .d0(rs2_data),
        .d1(imm_out),
        .s(alu_src),
        .y(src_b)
    );

    alu alu_unit(
        .alu_control(aluop),
        .rs1_data(rs1_data),
        .rs2_data(src_b),
        .alu_out(alu_out),
        .zero(zero)
    );

    adder pc_adder(
        .a(address),
        .b(imm_out),
        .y(pc_signed_offset)
    );

    assign pc_ex_out = mux_inp ?
                       {alu_out[31:1], 1'b0} :
                       pc_signed_offset;

    assign and_out_ex = (branch && zero) ||
                        (opcode == 7'h6F) ||
                        (opcode == 7'h67);

endmodule
