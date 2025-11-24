module fetch #(
    DATA_WIDTH = 32
) (
    input logic clk,
    input logic rst,
    input logic [1:0] PCSrc,
    input logic [DATA_WIDTH-1:0] Result,
    input logic [DATA_WIDTH-1:0] ImmExt, //Input from sign extend

    output logic [DATA_WIDTH-1:0] Instr,
    output logic [DATA_WIDTH-1:0] pc_out4
);

    logic [DATA_WIDTH-1:0] PC;
    logic [DATA_WIDTH-1:0] PC_next;
    logic [DATA_WIDTH-1:0] PC_target;

    mux4 PC_mux4(
        .in0(pc_out4),
        .in1(PC_target),
        .in2(Result),
        .in3(PC),
        .sel(PCSrc),
        .out(PC_next)
    );

    adder PC_plus4(
        .in0(PC),
        .in1(3'b100),
        .out(pc_out4)
    );

    adder PC_imm(
        .in0(ImmExt),
        .in1(PC),
        .out(PC_target)
    )

    pc_reg PC_reg(
        .clk(clk),
        .rst(rst),
        .pc_next(PC_next),
        .pc_out(PC)
    )

    instrMem instrMem(
        .addr(PC),
        .instr(Instr)
    )
    
endmodule
