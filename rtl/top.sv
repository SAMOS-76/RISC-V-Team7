module top #(
    parameter DATA_WIDTH = 32
) (
    input   logic clk,
    input   logic rst,
    input   logic trigger,
    output  logic [DATA_WIDTH-1:0] a0
);

    logic F_PCSrc;
    logic [DATA_WIDTH-1:0] F_PCTarget;
    logic [DATA_WIDTH-1:0] F_instr;
    logic [DATA_WIDTH-1:0] F_pc_out;
    logic [DATA_WIDTH-1:0] F_pc_out4;

    logic [DATA_WIDTH-1:0] D_instr;
    logic [DATA_WIDTH-1:0] D_pc_out;
    logic [DATA_WIDTH-1:0] D_pc_out4;

    logic D_PCTargetSrc;
    logic D_RegWrite;
    logic [1:0] D_result_src;
    logic D_mem_write;
    logic [3:0] D_alu_control;
    logic D_alu_srcA;
    logic D_alu_srcB;
    logic D_sign_ext_flag;
    logic D_Branch;
    logic D_Jump;
    logic [2:0] D_branchType;
    logic [DATA_WIDTH-1:0] D_imm_ext;
    logic [DATA_WIDTH-1:0] D_r_out1;
    logic [DATA_WIDTH-1:0] D_r_out2;
    logic [1:0] D_type_control;
    logic [4:0] D_rs1;
    logic [4:0] D_rs2;
    logic [4:0] D_rd;

    logic E_PCTargetSrc;
    logic E_RegWrite;
    logic [1:0] E_result_src;
    logic E_mem_write;
    logic [3:0] E_alu_control;
    logic E_alu_srcA;
    logic E_alu_srcB;
    logic E_sign_ext_flag;
    logic E_Branch;
    logic E_Jump;
    logic [2:0] E_branchType;
    logic [DATA_WIDTH-1:0] E_pc_out;
    logic [DATA_WIDTH-1:0] E_pc_out4;
    logic [DATA_WIDTH-1:0] E_imm_ext;
    logic [DATA_WIDTH-1:0] E_r_out1;
    logic [DATA_WIDTH-1:0] E_r_out2;
    logic [1:0] E_type_control;
    logic [4:0] E_rd;

    logic [DATA_WIDTH-1:0] E_ALUResult;
    logic E_zero;

    logic M_mem_write;
    logic M_RegWrite;
    logic [1:0] M_type_control;
    logic M_sign_ext_flag;
    logic [1:0] M_result_src;
    logic [DATA_WIDTH-1:0] M_alu_result;
    logic [DATA_WIDTH-1:0] M_write_data;
    logic [DATA_WIDTH-1:0] M_pc_out4;
    logic [4:0] M_rd;

    logic [DATA_WIDTH-1:0] M_mem_read_data;
    logic [DATA_WIDTH-1:0] M_alu_result_out;

    logic W_RegWrite;
    logic [1:0] W_result_src;
    logic [DATA_WIDTH-1:0] W_alu_result;
    logic [DATA_WIDTH-1:0] W_mem_data;
    logic [DATA_WIDTH-1:0] W_pc_out4;
    logic [4:0] W_rd;

    logic [DATA_WIDTH-1:0] W_result;

    fetch fetch_stage (
        .clk(clk),
        .rst(rst),
        .PCSrc(F_PCSrc),
        .trigger(trigger),
        .PC_target(F_PCTarget),
        .Instr(F_instr),
        .pc_out4(F_pc_out4),
        .pc_out(F_pc_out)
    );

    F_D_reg F_D (
        .clk(clk),
        .rst(rst),
        .F_instr(F_instr),
        .F_pc_out(F_pc_out),
        .F_pc_out4(F_pc_out4),
        .D_instr(D_instr),
        .D_pc_out(D_pc_out),
        .D_pc_out4(D_pc_out4)
    );

    decode decode_stage (
        .clk(clk),
        .rst(rst),
        .instr(D_instr),
        .data_in(W_result),
        .wb_write_en(W_RegWrite),
        .wb_rd(W_rd),
        .PCTargetSrc(D_PCTargetSrc),
        .RegWrite(D_RegWrite),
        .result_src(D_result_src),
        .mem_write(D_mem_write),
        .alu_control(D_alu_control),
        .alu_srcA(D_alu_srcA),
        .alu_srcB(D_alu_srcB),
        .sign_ext_flag(D_sign_ext_flag),
        .Branch(D_Branch),
        .Jump(D_Jump),
        .branchType(D_branchType),
        .imm_ext(D_imm_ext),
        .r_out1(D_r_out1),
        .r_out2(D_r_out2),
        .type_control(D_type_control),
        .rs1(D_rs1),
        .rs2(D_rs2),
        .rd(D_rd),
        .a0(a0)
    );

    D_E_reg D_E (
        .clk(clk),
        .rst(rst),
        .D_RegWrite(D_RegWrite),
        .D_PCTargetSrc(D_PCTargetSrc),
        .D_result_src(D_result_src),
        .D_mem_write(D_mem_write),
        .D_alu_control(D_alu_control),
        .D_alu_srcA(D_alu_srcA),
        .D_alu_srcB(D_alu_srcB),
        .D_sign_ext_flag(D_sign_ext_flag),
        .D_Branch(D_Branch),
        .D_Jump(D_Jump),
        .D_branchType(D_branchType),
        .D_pc_out(D_pc_out),
        .D_pc_out4(D_pc_out4),
        .D_imm_ext(D_imm_ext),
        .D_r_out1(D_r_out1),
        .D_r_out2(D_r_out2),
        .D_type_control(D_type_control),
        .D_rd(D_rd),
        .E_RegWrite(E_RegWrite),
        .E_PCTargetSrc(E_PCTargetSrc),
        .E_result_src(E_result_src),
        .E_mem_write(E_mem_write),
        .E_alu_control(E_alu_control),
        .E_alu_srcA(E_alu_srcA),
        .E_alu_srcB(E_alu_srcB),
        .E_sign_ext_flag(E_sign_ext_flag),
        .E_Branch(E_Branch),
        .E_Jump(E_Jump),
        .E_branchType(E_branchType),
        .E_pc_out(E_pc_out),
        .E_pc_out4(E_pc_out4),
        .E_imm_ext(E_imm_ext),
        .E_r_out1(E_r_out1),
        .E_r_out2(E_r_out2),
        .E_type_control(E_type_control),
        .E_rd(E_rd)
    );

    execute execute_stage (
        .alu_control(E_alu_control),
        .ALUSrcA(E_alu_srcA),
        .ALUSrcB(E_alu_srcB),
        .PCTargetSrc(E_PCTargetSrc),
        .Branch(E_Branch),
        .Jump(E_Jump),
        .branchType(E_branchType),
        .PC(E_pc_out),
        .rs1(E_r_out1),
        .rs2(E_r_out2),
        .imm_ext(E_imm_ext),
        .ALUResult(E_ALUResult),
        .zero(E_zero),
        .PCSrc(F_PCSrc),
        .PCTarget(F_PCTarget)
    );

    E_M_reg E_M (
        .clk(clk),
        .rst(rst),
        .E_RegWrite(E_RegWrite),
        .E_mem_write(E_mem_write),
        .E_type_control(E_type_control),
        .E_sign_ext_flag(E_sign_ext_flag),
        .E_result_src(E_result_src),
        .E_alu_result(E_ALUResult),
        .E_r_out2(E_r_out2),
        .E_pc_out4(E_pc_out4),
        .E_rd(E_rd),
        .M_RegWrite(M_RegWrite),
        .M_mem_write(M_mem_write),
        .M_type_control(M_type_control),
        .M_sign_ext_flag(M_sign_ext_flag),
        .M_result_src(M_result_src),
        .M_alu_result(M_alu_result),
        .M_write_data(M_write_data),
        .M_pc_out4(M_pc_out4),
        .M_rd(M_rd)
    );

    memory memory_stage (
        .clk(clk),
        .mem_write(M_mem_write),
        .type_control(M_type_control),
        .sign_ext_flag(M_sign_ext_flag),
        .alu_result(M_alu_result),
        .write_data(M_write_data),
        .alu_result_out(M_alu_result_out),
        .read_data(M_mem_read_data)
    );

    M_W_reg M_W (
        .clk(clk),
        .rst(rst),
        .M_RegWrite(M_RegWrite),
        .M_result_src(M_result_src),
        .M_alu_result(M_alu_result_out),
        .M_mem_data(M_mem_read_data),
        .M_pc_out4(M_pc_out4),
        .M_rd(M_rd),
        .W_RegWrite(W_RegWrite),
        .W_result_src(W_result_src),
        .W_alu_result(W_alu_result),
        .W_mem_data(W_mem_data),
        .W_pc_out4(W_pc_out4),
        .W_rd(W_rd)
    );

    writeback writeback_stage (
        .result_src(W_result_src),
        .alu_result(W_alu_result),
        .mem_data(W_mem_data),
        .pc4(W_pc_out4),
        .result(W_result)
    );

endmodule
