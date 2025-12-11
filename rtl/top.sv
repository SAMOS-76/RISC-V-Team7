module top #(
    parameter DATA_WIDTH = 32
) (
    input   logic clk,
    input   logic rst,
    input   logic trigger,
    output  logic [DATA_WIDTH-1:0] a0
);

    logic F_PCSrc;

    logic [DATA_WIDTH-1:0] F_PCTarget;
    logic [DATA_WIDTH-1:0] F_instr;
    logic [DATA_WIDTH-1:0] F_pc_out;
    logic [DATA_WIDTH-1:0] F_pc_out4;

    logic [DATA_WIDTH-1:0] D_instr;
    logic [DATA_WIDTH-1:0] D_pc_out;
    logic [DATA_WIDTH-1:0] D_pc_out4;


    logic D_PCTargetSrc;
    logic D_RegWrite;
    logic [1:0] D_result_src;
    logic D_mem_write;
    logic [3:0] D_alu_control;
    logic D_alu_srcA;
    logic D_alu_srcB;
    logic D_sign_ext_flag;
    logic D_Branch;
    logic D_Jump;
    logic [2:0] D_branchType;
    logic [DATA_WIDTH-1:0] D_imm_ext;
    logic [DATA_WIDTH-1:0] D_r_out1;
    logic [DATA_WIDTH-1:0] D_r_out2;
    logic [1:0] D_type_control;
    logic [4:0] D_rs1;
    logic [4:0] D_rs2;
    logic [4:0] D_rd;

    logic E_PCTargetSrc;
    logic E_RegWrite;
    logic [1:0] E_result_src;
    logic E_mem_write;
    logic [3:0] E_alu_control;
    logic E_alu_srcA;
    logic E_alu_srcB;
    logic E_sign_ext_flag;
    logic E_Branch;
    logic E_Jump;
    logic [2:0] E_branchType;
    logic [DATA_WIDTH-1:0] E_pc_out;
    logic [DATA_WIDTH-1:0] E_pc_out4;
    logic [DATA_WIDTH-1:0] E_imm_ext;
    logic [DATA_WIDTH-1:0] E_r_out1;
    logic [DATA_WIDTH-1:0] E_r_out2;
    logic [DATA_WIDTH-1:0] E_forwarded_1;
    logic [DATA_WIDTH-1:0] E_forwarded_2;

    logic [1:0] E_type_control;
    logic [4:0] E_rd;
    logic [4:0] E_ra;
    logic [4:0] E_rb;

    logic [DATA_WIDTH-1:0] E_ALUResult;

    logic M_mem_write;
    logic M_RegWrite;
    logic [1:0] M_type_control;
    logic M_sign_ext_flag;
    logic [1:0] M_result_src;
    logic [DATA_WIDTH-1:0] M_alu_result;
    logic [DATA_WIDTH-1:0] M_write_data;
    logic [DATA_WIDTH-1:0] M_pc_out4;
    logic [4:0] M_rd;

    logic [DATA_WIDTH-1:0] M_mem_read_data;
    logic [DATA_WIDTH-1:0] M_alu_result_out;
    logic [DATA_WIDTH-1:0] M_result;

    logic W_RegWrite;
    logic [1:0] W_result_src;
    logic [DATA_WIDTH-1:0] W_alu_result;
    logic [DATA_WIDTH-1:0] W_mem_data;
    logic [DATA_WIDTH-1:0] W_pc_out4;
    logic [4:0] W_rd;

    logic [DATA_WIDTH-1:0] W_result;

    logic [1:0] forwarding_sel_a;
    logic [1:0] forwarding_sel_b;

    logic [6:0] D_opcode;
    logic [6:0] E_opcode;
    logic [6:0] M_opcode;
    logic [6:0] W_opcode;

    logic F_D_en;
    logic D_E_en;
    logic E_M_en;
    logic M_W_en;
    logic PC_en;
    logic no_op;

    logic CTRL_Flush;
    logic branch_taken;

    logic cache_stall;
    // Connected to memory_stage.cache_stall output

    // always_ff @(posedge clk) begin
    //     stateful_F_D_en <= F_D_en;
    //     stateful_PC_en  <= PC_en;
    // end

    fetch fetch_stage (
        .clk(clk),
        .rst(rst),
        .PCSrc(F_PCSrc),
        .trigger(trigger),
        .PC_target(F_PCTarget),
        .Instr(F_instr),
        .pc_out4(F_pc_out4),
        .pc_out(F_pc_out),
        .PC_en(PC_en)
    );

    F_D_reg F_D (
        .clk(clk),
        .rst(rst), //issue is here
        .CTRL_Flush(CTRL_Flush),
        .F_D_en(F_D_en),
        .F_instr(F_instr),
        .F_pc_out(F_pc_out),
        .F_pc_out4(F_pc_out4),
        .D_instr(D_instr),
        .D_pc_out(D_pc_out),
        .D_pc_out4(D_pc_out4)
    );

    decode decode_stage (
        .clk(clk),
        .rst(rst),
        .instr(D_instr),
        .data_in(W_result),
        .wb_write_en(W_RegWrite),
        .wb_rd(W_rd),
        .PCTargetSrc(D_PCTargetSrc),
        .RegWrite(D_RegWrite),
        .result_src(D_result_src),
        .mem_write(D_mem_write),
        .alu_control(D_alu_control),
        .alu_srcA(D_alu_srcA),
        .alu_srcB(D_alu_srcB),
        .sign_ext_flag(D_sign_ext_flag),
        .Branch(D_Branch),
        .Jump(D_Jump),
        .branchType(D_branchType),
        .imm_ext(D_imm_ext),
        .r_out1(D_r_out1),
        .r_out2(D_r_out2),
        .type_control(D_type_control),
        .rs1(D_rs1),
        .rs2(D_rs2),
        .rd(D_rd),
        .a0(a0),
        .opcode(D_opcode)
    );

    //wire stall_control_mem_write;
    //wire stall_control_reg_write;

    //assign stall_control_mem_write = D_mem_write && ~no_op;
    //assign stall_control_reg_write = D_RegWrite && ~no_op;




    D_E_reg D_E (
        .clk(clk),
        .rst(rst),
        .no_op(no_op),
        .D_E_en(D_E_en),
        .CTRL_Flush(CTRL_Flush),
        .D_RegWrite(D_RegWrite),
        .D_PCTargetSrc(D_PCTargetSrc),
        .D_result_src(D_result_src),
        .D_mem_write(D_mem_write),
        .D_alu_control(D_alu_control),
        .D_alu_srcA(D_alu_srcA),
        .D_alu_srcB(D_alu_srcB),
        .D_sign_ext_flag(D_sign_ext_flag),
        .D_Branch(D_Branch),
        .D_Jump(D_Jump),
        .D_branchType(D_branchType),
        .D_pc_out(D_pc_out),
        .D_pc_out4(D_pc_out4),
        .D_imm_ext(D_imm_ext),
        .D_r_out1(D_r_out1),
        .D_r_out2(D_r_out2),
        .D_type_control(D_type_control),
        .D_rd(D_rd),
        .D_ra(D_rs1),
        .D_rb(D_rs2),
        .D_opcode(D_opcode),
        .E_RegWrite(E_RegWrite),
        .E_PCTargetSrc(E_PCTargetSrc),
        .E_result_src(E_result_src),
        .E_mem_write(E_mem_write),
        .E_alu_control(E_alu_control),
        .E_alu_srcA(E_alu_srcA),
        .E_alu_srcB(E_alu_srcB),
        .E_sign_ext_flag(E_sign_ext_flag),
        .E_Branch(E_Branch),
        .E_Jump(E_Jump),
        .E_branchType(E_branchType),
        .E_pc_out(E_pc_out),
        .E_pc_out4(E_pc_out4),
        .E_imm_ext(E_imm_ext),
        .E_r_out1(E_r_out1),
        .E_r_out2(E_r_out2),
        .E_type_control(E_type_control),
        .E_rd(E_rd),
        .E_ra(E_ra),
        .E_rb(E_rb),
        .E_opcode(E_opcode)
    );

    // M-stage result mux: select between ALU result and load data
    always_comb begin
        case (M_result_src)
            2'b00: M_result = M_alu_result_out;
            2'b01: M_result = M_mem_read_data;
            2'b10: M_result = M_pc_out4;
            default: M_result = M_alu_result_out;
        endcase
    end

    always_comb begin
        case (forwarding_sel_a)
            2'b00: E_forwarded_1 = E_r_out1;
            2'b01: E_forwarded_1 = M_result;
            2'b10: E_forwarded_1 = W_result;
            default: E_forwarded_1 = 32'b0;
        endcase
        case (forwarding_sel_b)
            2'b00: E_forwarded_2 = E_r_out2;
            2'b01: E_forwarded_2 = M_result;
            2'b10: E_forwarded_2 = W_result;
            default: E_forwarded_2 = 32'b0;
        endcase
    end

    execute execute_stage (
        .alu_control(E_alu_control),
        .ALUSrcA(E_alu_srcA),
        .ALUSrcB(E_alu_srcB),
        .PCTargetSrc(E_PCTargetSrc),
        .Branch(E_Branch),
        .branch_taken(branch_taken),
        .branchType(E_branchType),
        .PC(E_pc_out),
        .rs1(E_forwarded_1),
        .rs2(E_forwarded_2),
        .imm_ext(E_imm_ext),
        .ALUResult(E_ALUResult),
        .PCTarget(F_PCTarget)
    );



    E_M_reg E_M (
        .clk(clk),
        .rst(rst),
        .E_M_en(E_M_en),
        .E_RegWrite(E_RegWrite),
        .E_mem_write(E_mem_write),
        .E_type_control(E_type_control),
        .E_sign_ext_flag(E_sign_ext_flag),
        .E_result_src(E_result_src),
        .E_alu_result(E_ALUResult),
        .E_r_out2(E_forwarded_2),
        .E_pc_out4(E_pc_out4),
        .E_rd(E_rd),
        .E_opcode(E_opcode),
        .M_RegWrite(M_RegWrite),
        .M_mem_write(M_mem_write),
        .M_type_control(M_type_control),
        .M_sign_ext_flag(M_sign_ext_flag),
        .M_result_src(M_result_src),
        .M_alu_result(M_alu_result),
        .M_write_data(M_write_data),
        .M_pc_out4(M_pc_out4),
        .M_rd(M_rd),
        .M_opcode(M_opcode)
    );

    memory memory_stage (
        .clk(clk),
        .rst(rst),
        .mem_write(M_mem_write),
        .type_control(M_type_control),
        .sign_ext_flag(M_sign_ext_flag),
        .alu_result(M_alu_result),
        .write_data(M_write_data),
        .alu_result_out(M_alu_result_out),
        .read_data(M_mem_read_data),
        .cache_stall(cache_stall)
    );

    M_W_reg M_W (
        .clk(clk),
        .rst(rst),
        .M_W_en(M_W_en),
        .M_RegWrite(M_RegWrite),
        .M_result_src(M_result_src),
        .M_alu_result(M_alu_result_out),
        .M_mem_data(M_mem_read_data),
        .M_pc_out4(M_pc_out4),
        .M_rd(M_rd),
        .M_opcode(M_opcode),
        .W_RegWrite(W_RegWrite),
        .W_result_src(W_result_src),
        .W_alu_result(W_alu_result),
        .W_mem_data(W_mem_data),
        .W_pc_out4(W_pc_out4),
        .W_rd(W_rd),
        .W_opcode(W_opcode)
    );

    writeback writeback_stage (
        .result_src(W_result_src),
        .alu_result(W_alu_result),
        .mem_data(W_mem_data),
        .pc4(W_pc_out4),
        .result(W_result)
    );

    hazard_unit h_u(

        .cache_stall(cache_stall),

        .PC_en(PC_en),
        .F_D_en(F_D_en),
        .D_E_en(D_E_en),
        .E_M_en(E_M_en),
        .M_W_en(M_W_en),


        .E_opcode(E_opcode),
        .M_opcode(M_opcode),
        .W_opcode(W_opcode),

        //execute stage registers it wants to read
        .d_reg_a(D_rs1),
        .d_reg_b(D_rs2),
        .d_opcode(D_opcode),

        .ex_reg_a(E_ra),
        .ex_reg_b(E_rb),
        .ex_reg_d(E_rd),



        //datamem stage
        .datamem_reg_write_enable(M_RegWrite),
        .datamem_reg_write_addr(M_rd),



        //writeback stage
        .wb_reg_write_enable(W_RegWrite),
        .wb_reg_write_addr(W_rd),

        //outputs to mux's controlling inputs in ex stage
        .reg_a(forwarding_sel_a),
        .reg_b(forwarding_sel_b),
        .no_op(no_op),

        // Control Signals
        .Branch(E_Branch),
        .Jump(E_Jump),
        .branch_taken(branch_taken),
        .PCSrc(F_PCSrc),
        .Flush(CTRL_Flush)

    );

endmodule
