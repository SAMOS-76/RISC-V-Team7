module decode #(
    DATA_WIDTH = 32
) (
    input logic clk,
    input logic rst,
    input logic [DATA_WIDTH-1:0] instr,
    input logic [DATA_WIDTH-1:0] data_in,

    output logic [1:0] PCSrc,
    output logic [1:0] result_src,
    output logic mem_write,
    output logic [3:0] alu_control,
    output logic addr_mode,
    output logic alu_srcA,
    output logic alu_srcB,
    output logic zero,
    output logic sign_ext_flag,
    output logic [DATA_WIDTH-1:0] imm_ext,
    output logic [DATA_WIDTH-1:0] r_out1,
    output logic [DATA_WIDTH-1:0] r_out2,
    output logic [1:0] type_control
);

    logic write_en;
    logic [2:0] imm_src;

    control_unit control_unit(
        .instr(insr),
        .alu_zero(zero),
        .ALUControl(alu_control),
        .ALUSrcB(alu_srcB),
        .ALUSrcA(alu_srcA),
        .MemWrite(mem_write),     
        .RegWrite(write_en),     
        .ResultSrc(result_src),  
        .ImmSrc(imm_src),
        .memSize(type_control),    
        .memUnsigned(sign_ext_flag),
        .PCSrc(PCSrc)
    );

    regfile regfile(
        .clk(clk),
        .write_en(write_en),
        .rst(rst),

        .a1(),
        .a2(),
        .a3(),

        .din(data_in),

        .orout1(r_out1),
        .orout2(r_out2)
    );

    sign_extend sign_extend(
        .ImmSrc(imm_src),
        .instr(instr),
        .imm_ext(imm_ext)
    );
    
endmodule