module fetch #(
    parameter DATA_WIDTH = 32
) (
    input logic clk,
    /* verilator lint_off UNUSED */
    input logic rst,
    /* verilator lint_on UNUSED */
    input logic                  PCSrc,
    input logic                  trigger,
    input logic                  PC_en,
    input logic                  predict_taken,
    input logic [DATA_WIDTH-1:0] predict_target,
    input logic                  predict_valid,
    input logic [DATA_WIDTH-1:0] Hazard_target,

    output logic [DATA_WIDTH-1:0] Instr,
    output logic [DATA_WIDTH-1:0] pc_out4,
    output logic [DATA_WIDTH-1:0] pc_out
);

    logic [DATA_WIDTH-1:0] PC_next;

    pc_reg PC_REG(
        .clk(clk),
        .rst(rst),
        .trigger(trigger),
        .PC_en(PC_en),
        .pc_next(PC_next),
        .pc_out(pc_out)
    );

    always_comb begin
        pc_out4 = pc_out + 32'b100;
    end

    always_comb begin
        if (PCSrc)
            PC_next = Hazard_target;
        else if (predict_taken && predict_valid)
            PC_next = predict_target;
        else
            PC_next = pc_out4;
    end

    instrMem memROM (
        .addr(pc_out),
        .instr(Instr)
    );
    
endmodule
