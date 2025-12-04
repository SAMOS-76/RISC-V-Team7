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

    //made async
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            PC <= 32'b0;
        end

        else begin
            PC <= pc_next;
        end
    end
    
    assign pc_out = PC;
    
    //temp for now
    /* verilator lint_off UNUSED */
    logic unused_trigger;
    assign unused_trigger = trigger;
    /* verilator lint_on UNUSED */

endmodule

