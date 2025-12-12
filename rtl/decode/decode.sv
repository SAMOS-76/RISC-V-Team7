module decode #(
    parameter DATA_WIDTH = 32
) (
    input  logic                   clk,
    input  logic                   rst,
    input  logic [DATA_WIDTH-1:0]  instr,
    input  logic [DATA_WIDTH-1:0]  data_in,
    input  logic                   wb_write_en,
    input  logic [4:0]             wb_rd,

    output logic                   PCTargetSrc,
    output logic                   RegWrite,
    output logic [1:0]             result_src,
    output logic                   mem_write,
    output logic [3:0]             alu_control,
    output logic                   alu_srcA,
    output logic                   alu_srcB,
    output logic                   sign_ext_flag,
    output logic                   Branch,
    output logic                   Jump,
    output logic [2:0]             branchType,
    output logic [DATA_WIDTH-1:0]  imm_ext,
    output logic [DATA_WIDTH-1:0]  r_out1,
    output logic [DATA_WIDTH-1:0]  r_out2,
    output logic [1:0]             type_control,
    output logic [4:0]             rs1,
    output logic [4:0]             rs2,
    output logic [4:0]             rd,
    output logic [6:0]             opcode,
    output logic [DATA_WIDTH-1:0]  a0,
    output logic                   is_div
);

    logic [2:0] imm_src;

    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];
    assign rd  = instr[11:7];
    assign opcode = instr[6:0];

    control_unit control_unit(
        .instr(instr),
        .ALUControl(alu_control),
        .ALUSrcB(alu_srcB),
        .ALUSrcA(alu_srcA),
        .MemWrite(mem_write),     
        .RegWrite(RegWrite),
        .ResultSrc(result_src),  
        .ImmSrc(imm_src),
        .memSize(type_control),    
        .mem_signed(sign_ext_flag),
        .Branch(Branch),
        .Jump(Jump),
        .branchType(branchType),
        .PCTargetSrc(PCTargetSrc),
        .is_div(is_div)
    );

    regfile regfile(
        .clk(clk),
        .write_en(wb_write_en),
        .rst(rst),
        .a1(rs1),
        .a2(rs2),
        .a3(wb_rd),
        .din(data_in),
        .rout1(r_out1),
        .rout2(r_out2),
        .a0(a0)
    );

    sign_extend sign_extend(
        .immSrc(imm_src),
        .instr(instr),
        .imm_ext(imm_ext)
    );
    
endmodule
