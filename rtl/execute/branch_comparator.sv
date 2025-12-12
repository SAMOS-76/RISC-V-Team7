module branch_comparator (
    input  logic        zero,          // From ALU
    input  logic        alu_result_0,  // LSB of ALU result
    input  logic [2:0]  branchType,
    input  logic        Branch,

    output logic        branch_taken
);

    typedef enum logic [2:0] {
        BEQ  = 3'b000,
        BNE  = 3'b001,
        BLT  = 3'b100,
        BGE  = 3'b101,
        BLTU = 3'b110,
        BGEU = 3'b111
    } branch_t;

    always_comb begin
        branch_taken = 1'b0;

        if (Branch) begin
            case (branchType)
                BEQ:  branch_taken = zero;           // SUB result is 0
                BNE:  branch_taken = ~zero;          // SUB result is not 0
                BLT:  branch_taken = ~zero;          // SLT result is 1 (not 0) 
                BGE:  branch_taken = zero;           // SLT result is 0
                BLTU: branch_taken = ~zero;          // SLTU result is 1 (not 0)
                BGEU: branch_taken = zero;           // SLTU result is 0
                default: branch_taken = 1'b0;
            endcase
        end
    end

endmodule
