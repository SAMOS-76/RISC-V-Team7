module branch_target_buffer #(
    parameter INDEX_BITS = 4
)(
    input  logic        clk,
    input  logic        rst,
    
    input  logic [31:0] PC_F,
    output logic        hit_F,
    output logic [31:0] target_F,
    
    input  logic        update_en,
    input  logic [31:0] PC_E,
    input  logic [31:0] target_E
);
    
    logic btb_valid [2**INDEX_BITS-1:0];
    logic [31:0] btb_target [2**INDEX_BITS-1:0];
    logic [31:0] btb_tag [2**INDEX_BITS-1:0];
    
    logic [INDEX_BITS-1:0] index_F;
    logic [INDEX_BITS-1:0] index_E;
    logic [31:0] tag_F;
    logic [31:0] tag_E;
    
    assign index_F = PC_F[INDEX_BITS+1:2];
    assign index_E = PC_E[INDEX_BITS+1:2];
    assign tag_F   = PC_F;
    assign tag_E   = PC_E;
    
    assign hit_F    = btb_valid[index_F] && (btb_tag[index_F] == tag_F);
    assign target_F = btb_target[index_F];
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int i = 0; i < 2**INDEX_BITS; i++) begin
                btb_valid[i]  = 1'b0;
                btb_tag[i]    = '0;
                btb_target[i] = '0;
            end
        end
        else if (update_en) begin
            btb_valid[index_E]  <= 1'b1;
            btb_tag[index_E]    <= tag_E;
            btb_target[index_E] <= target_E;
        end
    end

endmodule
