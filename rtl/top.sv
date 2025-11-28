

module top #(
    parameter DATA_WIDTH = 32
) (
    input   logic clk,
    /* verilator lint_off UNUSED */
    input logic rst,
    /* verilator lint_on UNUSED */
    input logic trigger,

    output logic [DATA_WIDTH-1:0] a0
);

    logic PCSrc;
    /* verilator lint_off UNUSED */
    logic [DATA_WIDTH-1:0] ALU_result;
    /* verilator lint_on UNUSED */
    logic [DATA_WIDTH-1:0] imm_ext;
    logic [DATA_WIDTH-1:0] instr;
    logic [DATA_WIDTH-1:0] pc_out4;
    logic [DATA_WIDTH-1:0] pc_out;

    logic [1:0] result_src;
    logic [DATA_WIDTH-1:0] result_final;
    logic write_en;
    logic [3:0] alu_control;
    logic alu_srcA;
    logic alu_srcB;
    logic zero;
    logic alu_result_0;
    logic sign_ext_flag;
    logic [DATA_WIDTH-1:0] r_out1;
    logic [DATA_WIDTH-1:0] r_out2;
    logic [1:0] type_control;

    logic PCTargetSrc;

    assign alu_result_0 = ALU_result[0];

    fetch fetch(
        .clk(clk),
        .rst(rst),
        .trigger(trigger),
        .PCSrc(PCSrc),
        .PCTargetSrc(PCTargetSrc),
        .r1_val(r_out1),
        .ImmExt(imm_ext),
        .Instr(instr),
        .pc_out4(pc_out4),
        .pc_out(pc_out)
    );

    decode decode(
        .clk(clk),
        .rst(rst),
        .instr(instr),
        .data_in(result_final),
        .PCSrc(PCSrc),
        .PCTargetSrc(PCTargetSrc),
        .result_src(result_src),
        .mem_write(write_en),
        .alu_control(alu_control),
        .alu_srcA(alu_srcA),
        .alu_srcB(alu_srcB),
        .zero(zero),
        .alu_result_0(alu_result_0),
        .sign_ext_flag(sign_ext_flag),
        .imm_ext(imm_ext),
        .r_out1(r_out1),
        .r_out2(r_out2),
        .type_control(type_control),
        .a0(a0)
    );

    execute execute(
        .clk(clk),
        .pc(pc_out),
        .pc4(pc_out4),
        .zero(zero),
        .alu_control(alu_control),
        .alu_srcA(alu_srcA),
        .alu_srcB(alu_srcB),
        .sign_ext_flag(sign_ext_flag),
        .r_out1(r_out1),
        .r_out2(r_out2),
        .imm_ext(imm_ext),
        .write_en(write_en),
        .type_control(type_control),
        .result_src(result_src),
        .result(result_final),
        .ALU_out(ALU_result)
    );

endmodule
