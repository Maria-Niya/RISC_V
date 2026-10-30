module id_stage(
    input  logic        clk,
    input  logic        reset,
    input  logic        stall,
    input  logic [31:0] instruction,
    input  logic [31:0] wb_data,        // data to write back (from the WB stage)
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data,
    output logic [31:0] imm_out,
    output logic [6:0]  opcode_out_d,
    output logic [6:0]  imm11_5,
    output logic [2:0]  fn3_out_d,
    output logic        fn7_5,
    output logic [2:0]  aluop,
    output logic [1:0]  memtoreg,
    output logic        branch,
    output logic        mem_write,
    output logic        mem_read,
    output logic        alu_src,
    output logic        mux_inp
);
        logic [4:0] rs1, rs2, rd;
    logic [1:0] immsrc;
    logic [1:0] ALUOp;
    logic [1:0] ResultSrc;
    logic RegWrite, Jump;
    logic [2:0] ALUControl;

    assign opcode_out_d = instruction[6:0];
    assign rd = instruction[11:7];
    assign fn3_out_d = instruction[14:12];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign imm11_5 = instruction[31:25];
    assign fn7_5 = instruction[30];

    maindec md(
        .op(opcode_out_d),
        .ResultSrc(ResultSrc),
        .MemWrite(mem_write),
        .Branch(branch),
        .ALUSrc(alu_src),
        .RegWrite(RegWrite),
        .Jump(Jump),
        .ImmSrc(immsrc),
        .ALUOp(ALUOp)
    );

    extend ext(
        .instr(instruction[31:7]),
        .immsrc(immsrc),
        .immext(imm_out)
    );

    regfile rf(
        .clk(clk),
        .we3(RegWrite && !stall),
        .a1(rs1),
        .a2(rs2),
        .a3(rd),
        .wd3(wb_data),
        .rd1(rs1_data),
        .rd2(rs2_data)
    );

    ALUdec ad(
        .opb5(opcode_out_d[5]),
        .funct3(fn3_out_d),
        .funct7b5(fn7_5),
        .ALUOp(ALUOp),
        .ALUControl(ALUControl)
    );

    assign aluop = ALUControl;
    assign memtoreg = ResultSrc;
    assign mem_read = (opcode_out_d == 7'b0000011);
    assign mux_inp = Jump
  
