module alu #(parameter WIDTH = 32)(
    input logic [WIDTH-1:0] inA,
    input logic [WIDTH-1:0] inB,
    input logic [3:0]       alu_op,
    output logic            zero,
    output logic [WIDTH-1:0] result

);

    always @(*) begin
        case(alu_op)
            4'b0000: result = inA + inB;
            4'b1000: result = inA - inB;
            4'b0001: result = inA << inB[4:0]; //logical left shift 
            4'b0010: result = ($signed(inA) < $signed(inB)) ? {{(WIDTH-1){1'b0}},{1'b1}} : {(WIDTH){1'b0}};   //set less than (signed)
            4'b0011: result = (inA < inB) ? {{(WIDTH-1){1'b0}},{1'b1}} : {(WIDTH){1'b0}}; //set less than (unsigned)
            4'b0100: result = inA ^ inB;
            4'b0101: result = inA >> inB[4:0]; //shift right logical
            4'b1101: result = $signed(inA) >>> inB[4:0]; //shift right arithmetic
            4'b0110: result = inA | inB;
            4'b0111: result = inA & inB;
            default: result = {WIDTH{1'b0}};
        endcase
    end

    assign zero = ~(| result[WIDTH-1:0]);




endmodule