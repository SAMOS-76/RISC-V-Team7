module top #(
    parameter DATA_WIDTH = 32
) (
    input   logic clk,
    input   logic rst,
    input   logic trigger,
    output  logic [DATA_WIDTH-1:0] a0
);

    // Fetch
    logic                       PCSrc;
    logic [DATA_WIDTH-1:0]      PCTarget;
    logic [DATA_WIDTH-1:0]      instr;
    logic [DATA_WIDTH-1:0]      pc_out;
    logic [DATA_WIDTH-1:0]      pc_out4;

    // decode
    logic                       PCTargetSrc;
    logic                       RegWrite;
    logic [1:0]                 result_src;
    logic                       mem_write;
    logic [3:0]                 alu_control;
    logic                       alu_srcA;
    logic                       alu_srcB;
    logic                       sign_ext_flag;
    logic                       Branch;
    logic                       Jump;
    logic [2:0]                 branchType;
    logic [DATA_WIDTH-1:0]      imm_ext;
    logic [DATA_WIDTH-1:0]      r_out1;
    logic [DATA_WIDTH-1:0]      r_out2;
    logic [1:0]                 type_control;

    /* verilator lint_off UNUSED */
    logic [4:0]                 rs1;
    logic [4:0]                 rs2;
    /* verilator lint_on UNUSED */

    logic [4:0]                 rd;

    // Execute
    logic [DATA_WIDTH-1:0]      ALUResult;

    /* verilator lint_off UNUSED */
    logic                       zero;
    /* verilator lint_on UNUSED */

    //memory
    logic [DATA_WIDTH-1:0]      mem_read_data;
    logic [DATA_WIDTH-1:0]      alu_result_out;

    // writeback
    logic [DATA_WIDTH-1:0]      result;

    fetch fetch_stage (
        .clk(clk),
        .rst(rst),
        .PCSrc(PCSrc),
        .trigger(trigger),
        .PC_target(PCTarget),
        .Instr(instr),
        .pc_out4(pc_out4),
        .pc_out(pc_out)
    );

    decode decode_stage(
        .clk(clk),
        .rst(rst),
        .instr(instr),
        .data_in(result),
        .wb_write_en(RegWrite),
        .wb_rd(rd),
        .PCTargetSrc(PCTargetSrc),
        .RegWrite(RegWrite),
        .result_src(result_src),
        .mem_write(mem_write),
        .alu_control(alu_control),
        .alu_srcA(alu_srcA),
        .alu_srcB(alu_srcB),
        .sign_ext_flag(sign_ext_flag),
        .Branch(Branch),
        .Jump(Jump),
        .branchType(branchType),
        .imm_ext(imm_ext),
        .r_out1(r_out1),
        .r_out2(r_out2),
        .type_control(type_control),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .a0(a0)
    );

    execute execute_stage (
        .alu_control(alu_control),
        .ALUSrcA(alu_srcA),
        .ALUSrcB(alu_srcB),
        .PCTargetSrc(PCTargetSrc),
        .Branch(Branch),
        .Jump(Jump),
        .branchType(branchType),
        .PC(pc_out),
        .rs1(r_out1),
        .rs2(r_out2),
        .imm_ext(imm_ext),
        .ALUResult(ALUResult),
        .zero(zero),
        .PCSrc(PCSrc),
        .PCTarget(PCTarget)
    );

    memory memory_stage (
        .clk(clk),
        .mem_write(mem_write),
        .type_control(type_control),
        .sign_ext_flag(sign_ext_flag),
        .alu_result(ALUResult),
        .write_data(r_out2),
        .alu_result_out(alu_result_out),
        .read_data(mem_read_data)
    );

    writeback writeback_stage (
        .result_src(result_src),
        .alu_result(alu_result_out),
        .mem_data(mem_read_data),
        .pc4(pc_out4),
        .result(result)
    );

endmodule
