typedef enum logic [1:0]{
    none = 2'b00,
    mem  = 2'b01,
    writeback = 2'b10
} forward_type;


module hazard_unit(

    input  logic    [4:0] d_reg_a,
    input  logic    [4:0] d_reg_b,
    input  logic    [6:0] d_opcode,
    input   logic   [4:0] ex_reg_a,
    input   logic   [4:0] ex_reg_b,
    input   logic   [4:0] ex_reg_d,
    input   logic   [6:0] E_opcode,
    
    input   logic   datamem_reg_write_enable,
    input   logic   [4:0] datamem_reg_write_addr,
    input   logic   [6:0] M_opcode,

    input   logic   wb_reg_write_enable,
    input   logic   [4:0] wb_reg_write_addr,
    input   logic   [6:0] W_opcode,

    output  forward_type    reg_a,
    output  forward_type    reg_b,

    output logic            PC_en,
    output logic            F_D_en,
    output logic            D_E_en,

    output logic            no_op,

    input  logic            Branch,
    input  logic            branch_taken,
    input  logic            Jump,
    output logic            PCSrc,
    output logic            Flush,

    input  logic            E_prediction_made,
    input  logic            E_predicted_taken,
    input  logic   [31:0]   E_btb_PCtarget,
    input  logic   [31:0]   PCTarget
);

logic E_reg_1_valid;
logic E_reg_2_valid;
logic M_reg_c_valid;
logic W_reg_c_valid;
logic d_reg_1_valid;
logic d_reg_2_valid;

logic reg_en;
logic branch_mispredict;

logic target_mismatch;

assign target_mismatch = (E_btb_PCtarget != PCTarget);

always_comb begin : opcode_check
    d_reg_1_valid = ~(d_opcode == 7'b0010111 | d_opcode == 7'b0110111 | d_opcode == 7'b1101111);
    d_reg_2_valid = ~(d_opcode == 7'b0010111 | d_opcode == 7'b0110111 | d_opcode == 7'b1100111 | d_opcode == 7'b1101111 | d_opcode == 7'b0000011 | d_opcode == 7'b0010011);

    E_reg_1_valid = ~(E_opcode == 7'b0010111 | E_opcode == 7'b0110111 | E_opcode == 7'b1101111 | E_opcode == 7'b0000000);
    E_reg_2_valid = ~(E_opcode == 7'b0010111 | E_opcode == 7'b0110111 | E_opcode == 7'b1100111 | E_opcode == 7'b1101111 | E_opcode == 7'b0000011 | E_opcode == 7'b0010011 | E_opcode == 7'b0000000);

    W_reg_c_valid = ~(W_opcode == 7'b0100011 | W_opcode == 7'b1100011 | ~wb_reg_write_enable);
    M_reg_c_valid = ~(M_opcode == 7'b0100011 | M_opcode == 7'b1100011 | ~datamem_reg_write_enable);
end

always_comb begin : reg_enables
    if (branch_mispredict) begin
        PC_en  = 1'b1;
        F_D_en = 1'b1;
        D_E_en = 1'b1;
        no_op  = 1'b0;
    end else begin
        PC_en  = reg_en;
        F_D_en = reg_en;
        D_E_en = reg_en;
        no_op  = ~reg_en;
    end
end

logic A_L_haz;

assign A_L_haz = (E_opcode == 7'b0000011 && (((d_reg_a == ex_reg_d) && d_reg_1_valid) || ((d_reg_b == ex_reg_d) && d_reg_2_valid)));

assign reg_en = ~(A_L_haz);
    
always_comb begin

    reg_a = none;
    reg_b = none;
    
    if((ex_reg_a == datamem_reg_write_addr) && datamem_reg_write_enable && E_reg_1_valid && M_reg_c_valid && (M_opcode != 7'b0000011)) begin
        reg_a = mem;
    end
    else if((ex_reg_a == wb_reg_write_addr) && wb_reg_write_enable && E_reg_1_valid && W_reg_c_valid) begin
        reg_a = writeback;
    end

    if((ex_reg_b == datamem_reg_write_addr) && datamem_reg_write_enable && E_reg_2_valid && M_reg_c_valid && (M_opcode != 7'b0000011)) begin
        reg_b = mem;
    end
    else if((ex_reg_b == wb_reg_write_addr) && wb_reg_write_enable && E_reg_2_valid && W_reg_c_valid) begin
        reg_b = writeback;
    end
end

always_comb begin
    if (Branch) begin
        if (E_prediction_made) begin
            if (branch_taken) begin
                branch_mispredict = (~E_predicted_taken) || target_mismatch;
            end else begin
                branch_mispredict = E_predicted_taken;
            end
        end else begin
            branch_mispredict = branch_taken;
        end
    end
    else if (Jump) begin
        if (E_opcode == 7'b1100111) begin
            branch_mispredict = 1'b1;
        end else begin
            if (E_prediction_made) begin
                if (E_predicted_taken) begin
                    branch_mispredict = target_mismatch;
                end else begin
                    branch_mispredict = 1'b1;
                end
            end else begin
                branch_mispredict = 1'b1;
            end
        end
    end
    else begin
        branch_mispredict = 1'b0;
    end

    Flush = branch_mispredict || (E_prediction_made && branch_taken && target_mismatch);
    PCSrc = branch_mispredict || (E_prediction_made && branch_taken && target_mismatch);
end

endmodule
