module if_stage (
    input  logic        clk,
    input  logic        reset,              // Asynchronous, active high
    input  logic        stall,              // Hold the PC
    input  logic        and_out,            // 1 = take branch/jump target
    input  logic [31:0] pc_signed_offset,   // Branch / jump target address
    output logic [31:0] address,            // Current PC
    output logic [31:0] pc_new              // PC + 4
);
    logic [31:0] pc_next;

    adder pc_adder(
        .a(address),
        .b(32'd4),
        .y(pc_new)
    );

    mux2 #(.WIDTH(32)) pc_mux(
        .d0(pc_new),
        .d1(pc_signed_offset),
        .s(and_out),
        .y(pc_next)
    );

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            address <= 32'h8000_0000;
        else if (!stall)
            address <= pc_next;
    end

endmodule
