module fetch #(
    parameter DATA_WIDTH = 32
) (
    input logic clk,
    /* verilator lint_off UNUSED */
    input logic rst,
    /* verilator lint_on UNUSED */
    input logic                  PCSrc,
    input logic                  trigger,
    input logic [DATA_WIDTH-1:0] PC_target,
    input logic                  PC_en,

    output logic [DATA_WIDTH-1:0] Instr,
    output logic [DATA_WIDTH-1:0] pc_out4,
    output logic [DATA_WIDTH-1:0] pc_out
);

    logic [DATA_WIDTH-1:0] PC_next;

    pc_reg PC_REG( //signal and instance were named PC = VARHIDDEN warn/error, so renamed PC -> PC_REG
        .clk(clk),
        .rst(rst),
        .trigger(trigger),
        .PC_en(PC_en),

        .pc_next(PC_next),
        .pc_out(pc_out)
    );

    always_comb begin                             // PC +4 adder
        pc_out4 = pc_out + 32'b100;
    end

    assign PC_next = PCSrc ? PC_target : pc_out4; // Branch target or increment PC mux

    instrMem memROM (
        .addr(pc_out),
        .instr(Instr)
    );
    
endmodule
