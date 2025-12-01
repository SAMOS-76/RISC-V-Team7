module pc_reg #(
    parameter DATA_WIDTH = 32
) (
    input logic clk,
    input logic rst,
    input logic trigger,

    input logic [DATA_WIDTH-1: 0] pc_next,
    output logic [DATA_WIDTH-1: 0] pc_out
);

    logic [DATA_WIDTH-1:0] PC; 

    // changed to async reset to match cache and standard practice.
    // trigger stall update
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            PC <= 32'b0;
        end
        else if (trigger) begin
            PC <= PC;
        end
        else begin
            PC <= pc_next;
        end
    end
    
    assign pc_out = PC;
    
endmodule
