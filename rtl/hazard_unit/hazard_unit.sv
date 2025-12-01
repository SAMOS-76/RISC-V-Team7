typedef enum logic [1:0]{
    none = 2'b00,
    mem  = 2'b01,
    writeback = 2'b10
} forward_type;


module hazard_unit(

    //execute stage registers it wants to read
    input   logic   [4:0] ex_reg_a,
    input   logic   [4:0] ex_reg_b,
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
    output  forward_type    reg_b



);

    logic E_reg_1_valid;
    logic E_reg_2_valid;
    logic M_reg_c_valid;
    logic W_reg_c_valid;


assign E_reg_1_valid = ~(E_opcode == 7'b0010111 | E_opcode == 7'b0110111 | E_opcode == 7'b1101111);
assign E_reg_2_valid = ~(E_opcode == 7'b0010111 | E_opcode == 7'b0110111 | E_opcode == 7'b1100111 | E_opcode == 7'b1101111 | E_opcode == 7'b0000011 | E_opcode == 7'b0010011);
assign W_reg_c_valid = ~(W_opcode == 7'b0100011 | W_opcode == 7'b1100011);
assign M_reg_c_valid = ~(M_opcode == 7'b0100011 | M_opcode == 7'b1100011);



always_comb begin






    reg_a = none;
    reg_b = none;



    //for a
    //most recent (the one currently in data) is pipelined in

    if((ex_reg_a == datamem_reg_write_addr) && datamem_reg_write_enable && E_reg_1_valid && M_reg_c_valid) begin
        reg_a = mem;
    end

    else if((ex_reg_a == wb_reg_write_addr) && wb_reg_write_enable && E_reg_1_valid && W_reg_c_valid) begin
        reg_a = writeback;
    end

    //for b



    if((ex_reg_b == datamem_reg_write_addr) && datamem_reg_write_enable && E_reg_2_valid && M_reg_c_valid) begin
        reg_b = mem;
    end

    else if((ex_reg_b == wb_reg_write_addr) && wb_reg_write_enable && E_reg_2_valid && W_reg_c_valid) begin
        reg_b = writeback;
    end
end

endmodule
