module execute #(
    parameter DATA_WIDTH = 32
) (
    input  logic [3:0]            alu_control,
    input  logic                  ALUSrcA,
    input  logic                  ALUSrcB,
    input  logic                  PCTargetSrc,
    input  logic                  Branch,
    input  logic [2:0]            branchType,
    input  logic [DATA_WIDTH-1:0] PC,
    input  logic [DATA_WIDTH-1:0] rs1,
    input  logic [DATA_WIDTH-1:0] rs2,
    input  logic [DATA_WIDTH-1:0] imm_ext,
    
    output logic [DATA_WIDTH-1:0] ALUResult,
    output logic [DATA_WIDTH-1:0] PCTarget,
    output logic                  branch_taken
);
    logic [DATA_WIDTH-1:0] op1;
    logic [DATA_WIDTH-1:0] op2;
    logic [DATA_WIDTH-1:0] PCoperand;
    logic                  ALUlsb;
    logic                  zero;

    always_comb begin : ALU_Operand_select
        op1 = ALUSrcA ? PC : rs1;
        op2 = ALUSrcB ? imm_ext : rs2;    
    end 

    alu alu(
        .inA(op1),
        .inB(op2),
        .alu_op(alu_control),
        .zero(zero),
        .result(ALUResult)
    );

    assign ALUlsb = ALUResult[0];

    branch_comparator branchComparator (
        .zero(zero),
        .alu_result_0(ALUlsb),
        .branchType(branchType),
        .Branch(Branch),
        .branch_taken(branch_taken)
    );

    always_comb begin : PC_target_adder
        PCoperand = PCTargetSrc ? rs1 : PC;
        PCTarget  = PCoperand + imm_ext;
    end
    
endmodule
