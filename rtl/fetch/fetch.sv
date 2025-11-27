module fetch #(
    parameter DATA_WIDTH = 32
) (
    input logic clk,
    /* verilator lint_off UNUSED */
    input logic rst,
    /* verilator lint_on UNUSED */
    input logic PCSrc,
    input logic [DATA_WIDTH-1:0] ImmExt, //Input from sign extend
    input logic PCTargetSrc,
    input logic [DATA_WIDTH-1:0] r1_val,

    input logic trigger,

    output logic [DATA_WIDTH-1:0] Instr,
    output logic [DATA_WIDTH-1:0] pc_out4,
    output logic [DATA_WIDTH-1:0] pc_out
);

    logic [DATA_WIDTH-1:0] PC_next;
    logic [DATA_WIDTH-1:0] PC_target;
    
    logic [DATA_WIDTH-1:0] PCTargetOp;
     
    adder PC_plus4(
        .in0(pc_out),
        .in1(32'd4),
        .out(pc_out4)
    );

    assign PCTargetOp = PCTargetSrc ? r1_val : pc_out; //choose r1 or current pc value for target adder.

    adder PC_imm(
        .in0(ImmExt),
        .in1(PCTargetOp),
        .out(PC_target)
    );

    pc_reg PC_reg(
        .clk(clk),
        .rst(rst),
        .trigger(trigger),
        .pc_next(PC_next),
        .pc_out(pc_out)
    );

    instrMem instrMem(
        .addr(pc_out),
        .instr(Instr)
    );

    assign PC_next = PCSrc ? PC_target : pc_out4;
    
endmodule
