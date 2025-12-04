module alu #(parameter WIDTH = 32)(
    input logic [WIDTH-1:0] inA,
    input logic [WIDTH-1:0] inB,
    input logic [3:0]       alu_op,
    output logic            zero,
    output logic [WIDTH-1:0] result

);

    always @(*) begin
        case(alu_op)
            4'b0000: result = inA + inB;                     // ADD
            4'b0001: result = inA - inB;                     // SUB

            4'b0010: result = inA << inB[4:0];               // SLL
            4'b0011: result = ($signed(inA) < $signed(inB)); // SLT
            4'b0100: result = (inA < inB);                   // SLTU

            4'b0101: result = inA ^ inB;                     // XOR
            4'b0110: result = inA >> inB[4:0];               // SRL
            4'b0111: result = $signed(inA) >>> inB[4:0];     // SRA

            4'b1000: result = inA | inB;                     // OR
            4'b1001: result = inA & inB;                     // AND

            // -------------------------------
            // RV32M: Multiply operations
            // -------------------------------
            4'b1010: result = inA * inB;                                          // MUL
            4'b1011: result = (64'(($signed(inA))) * 64'(($signed(inB)))) >> 32;  // MULH
            4'b1100: result = (64'(($signed(inA))) * 64'(inB)) >> 32;             // MULHSU
            4'b1101: result = (64'(inA) * 64'(inB)) >> 32;

            default: result = {WIDTH{1'b0}};
        endcase
    end

    assign zero = ~(| result[WIDTH-1:0]);




endmodule
