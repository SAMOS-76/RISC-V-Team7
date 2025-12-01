module M_W_reg #(
    parameter DATA_WIDTH = 32
) (
    input  logic clk,
    input  logic rst,
    input  logic M_RegWrite,
    input  logic [1:0] M_result_src,
    input  logic [DATA_WIDTH-1:0] M_alu_result,
    input  logic [DATA_WIDTH-1:0] M_mem_data,
    input  logic [DATA_WIDTH-1:0] M_pc_out4,
    input  logic [4:0] M_rd,
    input  logic [6:0] M_opcode,
    
    output logic W_RegWrite,
    output logic [1:0] W_result_src,
    output logic [DATA_WIDTH-1:0] W_alu_result,
    output logic [DATA_WIDTH-1:0] W_mem_data,
    output logic [DATA_WIDTH-1:0] W_pc_out4,
    output logic [4:0] W_rd,
    output logic [6:0] W_opcode
);
    always_ff @(posedge clk) begin
        if (rst) begin
            W_RegWrite <= 0;
            W_result_src <= 0;
            W_alu_result <= 0;
            W_mem_data <= 0;
            W_pc_out4 <= 0;
            W_rd <= 0;
            W_opcode <= 0;
        end 
        else 
        begin
            W_RegWrite <= M_RegWrite;
            W_result_src <= M_result_src;
            W_alu_result <= M_alu_result;
            W_mem_data <= M_mem_data;
            W_pc_out4 <= M_pc_out4;
            W_rd <= M_rd;
            W_opcode <= M_opcode;

        end
    end
endmodule
