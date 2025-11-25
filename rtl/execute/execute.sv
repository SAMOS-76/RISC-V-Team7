module execute #(
    DATA_WIDTH =32
) (
    input logic clk, 
    input logic rst,

    input logic [DATA_WIDTH-1:0] pc,
    input logic [DATA_WIDTH-1:0] pc4,

    output logic zero,
    input logic [3:0] alu_control,
    input logic alu_srcA,
    input logic alu_srcB,

    input logic sign_ext_flag,

    input logic [DATA_WIDTH-1:0] r_out1,
    input logic [DATA_WIDTH-1:0] r_out2,
    input logic [DATA_WIDTH-1:0] imm_ext,

    input logic write_en,
    input logic [1:0] type_control,

    input logic [1:0] result_src,

    output logic [DATA_WIDTH-1:0] result,
    output logic [DATA_WIDTH-1:0] ALU_out
);

    logic [DATA_WIDTH-1:0] inA;
    logic [DATA_WIDTH-1:0] inB;
    logic [DATA_WIDTH-1:0] read_data;

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

    mux4 alu_result(
        .in0(ALU_out),
        .in1(read_data),
        .in2(pc4),
        .in3(imm_ext),
        .sel(result_src),
        .out(result)
    );

    alu alu(
        .inA(inA),
        .inB(inB),
        .alu_op(alu_control),
        .zero(zero),
        .result(ALU_out)
    );

    datamem datamem(
        .clk(clk),
        .write_en(write_en),
        .type_control(type_control),
        .addr(ALU_out),
        .din(r_out2),
        .sign_ext(sign_ext_flag),
        .dout(read_data)
    );
    
endmodule
