module pc_reg #(
    parameter DATA_WIDTH = 32
) (
    input logic clk,
    input logic rst,
    input logic trigger,
    input logic PC_en,

    input logic [DATA_WIDTH-1: 0] pc_next,
    output logic [DATA_WIDTH-1: 0] pc_out
);

    logic [DATA_WIDTH-1:0] PC; 

    always_ff @(posedge clk)
        if (rst & !trigger) begin
            PC <= 32'b0;
        end

        else if(PC_en)begin
            PC <= pc_next;
        end
    
    assign pc_out = PC;
    
endmodule
