typedef enum logic [1:0]{
    none = 2'b00,
    mem  = 2'b01,
    writeback = 2'b10
} forward_type;


module hazard_unit(
    input logic         clk,

    input  logic    [4:0] d_reg_a,
    input  logic    [4:0] d_reg_b,
    input  logic    [6:0] d_opcode,
    //execute stage registers it wants to read
    input   logic   [4:0] ex_reg_a,
    input   logic   [4:0] ex_reg_b,
    input   logic   [4:0] ex_reg_d,

    input   logic   [6:0] E_opcode,
    
    
    
    //datamem stage
    input   logic   datamem_reg_write_enable,
    input   logic   [4:0] datamem_reg_write_addr,
    input   logic   [6:0] M_opcode,


    //writeback stage

    input   logic   wb_reg_write_enable,
    input   logic   [4:0] wb_reg_write_addr,
    input   logic   [6:0] W_opcode,


    //outputs to mux's controlling inputs in ex stage
    output  forward_type    reg_a,
    output  forward_type    reg_b,

    output logic            PC_en,
    output logic            F_D_en,
    output logic            D_E_en,

    output logic            no_op,

    // Control Signals
    input  logic            Branch,
    input  logic            branch_taken,
    input  logic            Jump,
    input  logic            rst,

    output logic            PCSrc,
    output logic            Flush
);

logic E_reg_1_valid;
logic E_reg_2_valid;
logic M_reg_c_valid;
logic W_reg_c_valid;
logic d_reg_1_valid;
logic d_reg_2_valid;

logic reg_en;

always_comb begin : opcode_check
    d_reg_1_valid = ~(d_opcode == 7'b0010111 | d_opcode == 7'b0110111 | d_opcode == 7'b1101111);
    d_reg_2_valid = ~(d_opcode == 7'b0010111 | d_opcode == 7'b0110111 | d_opcode == 7'b1100111 | d_opcode == 7'b1101111 | d_opcode == 7'b0000011 | d_opcode == 7'b0010011);

    E_reg_1_valid = ~(E_opcode == 7'b0010111 | E_opcode == 7'b0110111 | E_opcode == 7'b1101111);
    E_reg_2_valid = ~(E_opcode == 7'b0010111 | E_opcode == 7'b0110111 | E_opcode == 7'b1100111 | E_opcode == 7'b1101111 | E_opcode == 7'b0000011 | E_opcode == 7'b0010011);

    W_reg_c_valid = ~(W_opcode == 7'b0100011 | W_opcode == 7'b1100011);
    M_reg_c_valid = ~(M_opcode == 7'b0100011 | M_opcode == 7'b1100011);
end

assign PC_en = reg_en;
assign F_D_en = reg_en;
assign D_E_en = reg_en;
assign no_op = ~reg_en;

always_ff @(negedge clk) begin
reg_en <= ~(E_opcode == 7'b0000011 && (((d_reg_a == ex_reg_d) && d_reg_1_valid) || ((d_reg_b == ex_reg_d) && d_reg_2_valid)) && ~no_op);
end


always_comb begin

    reg_a = none;
    reg_b = none;
    
    //for a
    //most recent (the one currently in data) is pipelined in

    if((ex_reg_a == datamem_reg_write_addr) && datamem_reg_write_enable && E_reg_1_valid && M_reg_c_valid && (M_opcode != 7'b0000011)) begin
        reg_a = mem;
    end

    else if((ex_reg_a == wb_reg_write_addr) && wb_reg_write_enable && E_reg_1_valid && W_reg_c_valid) begin
        reg_a = writeback;
    end

    //for b
    if((ex_reg_b == datamem_reg_write_addr) && datamem_reg_write_enable && E_reg_2_valid && M_reg_c_valid && (M_opcode != 7'b0000011)) begin
        reg_b = mem;
    end

    else if((ex_reg_b == wb_reg_write_addr) && wb_reg_write_enable && E_reg_2_valid && W_reg_c_valid) begin
        reg_b = writeback;
    end
end

logic branch_mispredict;

always_comb begin : control_hazard
    Flush = 1'b0;
    PCSrc = 1'b0;

    if (rst) begin
        Flush = 1'b0;
        PCSrc = 1'b0;
    end else begin
        branch_mispredict = (Branch && branch_taken);
        PCSrc = branch_mispredict || Jump;
        Flush = branch_mispredict || Jump;
    end
    
end

endmodule
