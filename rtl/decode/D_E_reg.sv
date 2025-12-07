module D_E_reg #(
    parameter DATA_WIDTH = 32
) (
    input  logic clk,
    input  logic rst,

    input  logic CTRL_Flush,
    
    input  logic D_E_en,
    input  logic D_RegWrite,
    input  logic D_PCTargetSrc,
    input  logic [1:0] D_result_src,
    input  logic D_mem_write,
    input  logic [3:0] D_alu_control,
    input  logic D_alu_srcA,
    input  logic D_alu_srcB,
    input  logic D_sign_ext_flag,
    input  logic D_Branch,
    input  logic D_Jump,
    input  logic [2:0] D_branchType,
    input  logic [DATA_WIDTH-1:0] D_pc_out,
    input  logic [DATA_WIDTH-1:0] D_pc_out4,
    input  logic [DATA_WIDTH-1:0] D_imm_ext,
    input  logic [DATA_WIDTH-1:0] D_r_out1,
    input  logic [DATA_WIDTH-1:0] D_r_out2,
    input  logic [1:0] D_type_control,
    input  logic [6:0] D_opcode,
    input  logic [4:0] D_rd,
    input  logic D_is_div,

    input  logic [4:0] D_ra,
    input  logic [4:0] D_rb,
    
    output logic E_RegWrite,
    output logic E_PCTargetSrc,
    output logic [1:0] E_result_src,
    output logic E_mem_write,
    output logic [3:0] E_alu_control,
    output logic E_alu_srcA,
    output logic E_alu_srcB,
    output logic E_sign_ext_flag,
    output logic E_Branch,
    output logic E_Jump,
    output logic [2:0] E_branchType,
    output logic [DATA_WIDTH-1:0] E_pc_out,
    output logic [DATA_WIDTH-1:0] E_pc_out4,
    output logic [DATA_WIDTH-1:0] E_imm_ext,
    output logic [DATA_WIDTH-1:0] E_r_out1,
    output logic [DATA_WIDTH-1:0] E_r_out2,
    output logic [1:0] E_type_control,
    output logic [6:0] E_opcode,
    output logic [4:0] E_rd,
    output logic E_is_div,

    output logic [4:0] E_ra,
    output logic [4:0] E_rb
);
    always_ff @(negedge clk) begin  //negaedge so register file can be written nd then read with new value - makes the execute sort of 'directly'/'combinatoraly' connected to the regfile as no updates are lost
        if (rst) begin
            E_RegWrite <= 0;
            E_PCTargetSrc <= 0;
            E_result_src <= 0;
            E_mem_write <= 0;
            E_alu_control <= 0;
            E_alu_srcA <= 0;
            E_alu_srcB <= 0;
            E_sign_ext_flag <= 0;
            E_Branch <= 0;
            E_Jump <= 0;
            E_branchType <= 0;
            E_pc_out <= 0;
            E_pc_out4 <= 0;
            E_imm_ext <= 0;
            E_r_out1 <= 0;
            E_r_out2 <= 0;
            E_type_control <= 0;
            E_rd <= 0;
            E_ra <= 0;
            E_rb <= 0;
            E_opcode <= 0;
            E_is_div <= 0;
        end 
        //only flush if the flush isnt from the instruction currently in E stage
        // this prevented corrupt PC+4 when JAL/Branch executes
        else if (CTRL_Flush && !(E_Jump || E_Branch)) begin
            E_RegWrite <= 0;
            E_PCTargetSrc <= 0;
            E_result_src <= 0;
            E_mem_write <= 0;
            E_alu_control <= 0;
            E_alu_srcA <= 0;
            E_alu_srcB <= 0;
            E_sign_ext_flag <= 0;
            E_Branch <= 0;
            E_Jump <= 0;
            E_branchType <= 0;
            E_pc_out <= 0;
            E_pc_out4 <= 0;
            E_imm_ext <= 0;
            E_r_out1 <= 0;
            E_r_out2 <= 0;
            E_type_control <= 0;
            E_rd <= 0;
            E_ra <= 0;
            E_rb <= 0;
            E_opcode <= 0;
        end
        else if (D_E_en)
        begin
            E_RegWrite <= D_RegWrite;
            E_PCTargetSrc <= D_PCTargetSrc;
            E_result_src <= D_result_src;
            E_mem_write <= D_mem_write;
            E_alu_control <= D_alu_control;
            E_alu_srcA <= D_alu_srcA;
            E_alu_srcB <= D_alu_srcB;
            E_sign_ext_flag <= D_sign_ext_flag;
            E_Branch <= D_Branch;
            E_Jump <= D_Jump;
            E_branchType <= D_branchType;
            E_pc_out <= D_pc_out;
            E_pc_out4 <= D_pc_out4;
            E_imm_ext <= D_imm_ext;
            E_r_out1 <= D_r_out1;
            E_r_out2 <= D_r_out2;
            E_type_control <= D_type_control;
            E_rd <= D_rd;
            E_ra <= D_ra;
            E_rb <= D_rb;
            E_opcode <= D_opcode;
            E_is_div <= D_is_div;
        end
    end
endmodule
