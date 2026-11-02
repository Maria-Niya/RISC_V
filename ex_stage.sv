module ex_stage (
    input  logic [31:0] rs1_data,
    input  logic [31:0] rs2_data,
    input  logic [31:0] imm_out,
    input  logic [31:0] address,       // current PC
    input  logic        branch,
    input  logic        alu_src,       // 0 = rs2_data, 1 = imm_out
    input  logic        fn7_5,
    input  logic        mux_inp,       // 1 = JALR
    input  logic [2:0]  fn3,
    input  logic [6:0]  imm11_5,
    input  logic [2:0]  aluop,
    input  logic [6:0]  opcode,
    output logic        and_out_ex,    // branch / jump taken
    output logic [31:0] alu_out,
    output logic [31:0] pc_ex_out      // branch / jump target
);
    logic [31:0] src_b;
    logic [31:0] pc_signed_offset;
    logic zero;
    logic [2:0] alu_control;

    mux2 #(.WIDTH(32)) alu_mux(
        .d0(rs2_data),
        .d1(imm_out),
        .s(alu_src),
        .y(src_b) );

    ALUdec ad(
        .opb5(opcode[5]),
        .funct3(fn3),
        .funct7b5(fn7_5),
        .ALUOp(aluop[1:0]),
        .ALUControl(alu_control) );

    ALU alu(
        .a(rs1_data),
        .b(src_b),
        .ALUControl(alu_control),
        .result(alu_out),
        .zero(zero) );

    adder pc_adder(
        .a(address),
        .b(imm_out),
        .y(pc_signed_offset) );

    assign pc_ex_out = mux_inp ? {alu_out[31:1], 1'b0} : pc_signed_offset;
    assign and_out_ex = (branch && zero) || (opcode == 7'h6F) ||(opcode == 7'h67);
endmodule

endmodule
