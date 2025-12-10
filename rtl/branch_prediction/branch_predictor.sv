module branch_predictor #(
    parameter INDEX_BITS = 4
)(
    input  logic        clk,
    input  logic        rst,
    
    input  logic [31:0] PC_F,
    output logic        predict_taken_F,
    output logic [31:0] predict_target_F,
    output logic        predict_valid_F,
    
    input  logic        branch_resolved_E,
    input  logic        E_Jump, 
    input  logic [31:0] PC_E,
    input  logic        branch_taken_E,
    input  logic [31:0] branch_target_E,
    input  logic [6:0]  E_opcode
);

    logic bht_predict_taken;
    logic btb_hit;
    logic [31:0] btb_target;

    logic update_predictor;
    logic update_btb;
    logic actual_taken;
    logic is_jal;

    assign is_jal = E_Jump && (E_opcode == 7'b1101111);

    assign update_predictor = branch_resolved_E || is_jal;
    assign actual_taken = branch_taken_E || is_jal;
    assign update_btb = btb_hit;
    
    branch_history_table #(
        .INDEX_BITS(INDEX_BITS)
    ) bht1 (
        .clk(clk),
        .rst(rst),
        .PC_F(PC_F),
        .predict_taken_F(bht_predict_taken),
        .update_en(update_predictor),
        .PC_E(PC_E),
        .branch_taken_E(actual_taken)
    );
    
    branch_target_buffer #(
        .INDEX_BITS(INDEX_BITS)
    ) btb1 (
        .clk(clk),
        .rst(rst),
        .PC_F(PC_F),
        .hit_F(btb_hit),
        .target_F(btb_target),
        .update_en(update_btb),
        .PC_E(PC_E),
        .target_E(branch_target_E)
    );
    
    assign predict_taken_F = bht_predict_taken && btb_hit;
    assign predict_target_F = btb_target;
    assign predict_valid_F = btb_hit;

endmodule
