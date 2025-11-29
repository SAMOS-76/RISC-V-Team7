module execute #(
    parameter DATA_WIDTH =32
) (
    input logic clk, 

    input logic [DATA_WIDTH-1:0] pc,
    input logic [DATA_WIDTH-1:0] pc4,

    output logic zero,
    input logic [3:0] alu_control,
    input logic alu_srcA,
    input logic alu_srcB,

    input logic [DATA_WIDTH-1:0] r_out1,
    input logic [DATA_WIDTH-1:0] r_out2,
    input logic [DATA_WIDTH-1:0] imm_ext,

    output logic [DATA_WIDTH-1:0] ALU_out
);

    logic [DATA_WIDTH-1:0] inA;
    logic [DATA_WIDTH-1:0] inB;

    mux aluA(
        .in0(r_out1),
        .in1(pc),
        .sel(alu_srcA),
        .out(inA)
    );

    mux aluB(
        .in0(r_out2),
        .in1(imm_ext),
        .sel(alu_srcB),
        .out(inB)
    );

    alu alu(
        .inA(inA),
        .inB(inB),
        .alu_op(alu_control),
        .zero(zero),
        .result(ALU_out)
    );
    
endmodule
