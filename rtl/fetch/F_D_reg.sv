module F_D_reg #(
    parameter DATA_WIDTH = 32
) (
    input  logic clk,
    input  logic rst,
    input  logic [DATA_WIDTH-1:0] F_instr,
    input  logic [DATA_WIDTH-1:0] F_pc_out,
    input  logic [DATA_WIDTH-1:0] F_pc_out4,
    output logic [DATA_WIDTH-1:0] D_instr,
    output logic [DATA_WIDTH-1:0] D_pc_out,
    output logic [DATA_WIDTH-1:0] D_pc_out4
);
    always_ff @(posedge clk) begin
        if (rst) begin
            D_instr <= 0;
            D_pc_out <= 0;
            D_pc_out4 <= 0;
        end else begin
            D_instr <= F_instr;
            D_pc_out <= F_pc_out;
            D_pc_out4 <= F_pc_out4;
        end
    end
endmodule
