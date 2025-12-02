module E_M_reg #(
    parameter DATA_WIDTH = 32
) (
    input  logic clk,
    input  logic rst,
    input  logic E_RegWrite,
    input  logic E_mem_write,
    input  logic [1:0] E_type_control,
    input  logic E_sign_ext_flag,
    input  logic [1:0] E_result_src,
    input  logic [DATA_WIDTH-1:0] E_alu_result,
    input  logic [DATA_WIDTH-1:0] E_r_out2,
    input  logic [DATA_WIDTH-1:0] E_pc_out4,
    input  logic [4:0] E_rd,
    input  logic [6:0] E_opcode,
    input  logic       E_M_en,
    
    output logic M_RegWrite,
    output logic M_mem_write,
    output logic [1:0] M_type_control,
    output logic M_sign_ext_flag,
    output logic [1:0] M_result_src,
    output logic [DATA_WIDTH-1:0] M_alu_result,
    output logic [DATA_WIDTH-1:0] M_write_data,
    output logic [DATA_WIDTH-1:0] M_pc_out4,
    output logic [4:0] M_rd,
    output logic [6:0] M_opcode
);
    always_ff @(posedge clk) begin
        if (rst) begin
            M_RegWrite <= 0;
            M_mem_write <= 0;
            M_type_control <= 0;
            M_sign_ext_flag <= 0;
            M_result_src <= 0;
            M_alu_result <= 0;
            M_write_data <= 0;
            M_pc_out4 <= 0;
            M_rd <= 0;
            M_opcode <= 0;
        end 
        else if (E_M_en) 
        begin
            M_RegWrite <= E_RegWrite;
            M_mem_write <= E_mem_write;
            M_type_control <= E_type_control;
            M_sign_ext_flag <= E_sign_ext_flag;
            M_result_src <= E_result_src;
            M_alu_result <= E_alu_result;
            M_write_data <= E_r_out2;
            M_pc_out4 <= E_pc_out4;
            M_rd <= E_rd;
            M_opcode <= E_opcode;
        end
    end
endmodule
