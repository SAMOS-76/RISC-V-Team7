module execute #(
    parameter DATA_WIDTH = 32
) (
    input  logic clk,
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
    input  logic                  is_div,
    
    output logic [DATA_WIDTH-1:0] ALUResult,
    output logic [DATA_WIDTH-1:0] PCTarget,
    output logic                  branch_taken,
    output logic                  div_stall_flag
);
    logic [DATA_WIDTH-1:0] op1;
    logic [DATA_WIDTH-1:0] op2;
    logic [DATA_WIDTH-1:0] PCoperand;
    logic                  ALUlsb;
    logic                  zero;

    logic [DATA_WIDTH-1:0] alu_out;
    logic [DATA_WIDTH-1:0] quotient;
    logic [DATA_WIDTH-1:0] remainder; 
    logic div_done;
    logic div_unsigned;

    always_comb begin : ALU_Operand_select
        op1 = ALUSrcA ? PC : rs1;
        op2 = ALUSrcB ? imm_ext : rs2;    
    end 

    alu alu(
        .inA(op1),
        .inB(op2),
        .alu_op(alu_control),
        .zero(zero),
        .result(alu_out)
    );

    // check this
    assign ALUlsb = ALUResult[0];
    assign div_unsigned = alu_control[0];

    div div(
        .clk(clk),
        .triggered(is_div),
        .dividend(op1),
        .divisor(op2),
        .is_unsigned(div_unsigned),
        .quotient(quotient),
        .remainder(remainder),
        .is_finished(div_done)
    );


    assign div_stall_flag = (is_div) && !div_done;

    always_comb begin
        ALUResult = alu_out;

        if (is_div) begin
            // If the divider is finished, we select its output.
            if (div_done) begin
                if (alu_control[3] == 1'b0) 
                    ALUResult = remainder;
                else
                    ALUResult = quotient;
            end
        end
    end


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
