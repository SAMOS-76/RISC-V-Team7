typedef enum logic [1:0]{
    none = 2'b00,
    mem  = 2'b01,
    writeback = 2'b10
} forward_type;


module hazard_unit(

    //execute stage registers it wants to read
    input   logic   [4:0] ex_reg_a,
    input   logic   [4:0] ex_reg_b,
    
    
    
    //datamem stage
    input   logic   datamem_reg_write_enable,
    input   logic   [4:0] datamem_reg_write_addr,



    //writeback stage

    input   logic   wb_reg_write_enable,
    input   logic   [4:0] wb_reg_write_addr,


    //outputs to mux's controlling inputs in ex stage
    output  forward_type    reg_a,
    output  forward_type    reg_b



);

always_comb begin

    reg_a = none;
    reg_b = none;


    //for a
    //most recent (the one currently in data) is pipelined in

    if((ex_reg_a == datamem_reg_write_addr) && datamem_reg_write_enable) begin
        reg_a = mem;
    end

    else if((ex_reg_a == wb_reg_write_addr) && wb_reg_write_enable) begin
        reg_a = writeback;
    end

    //for b



    if((ex_reg_b == datamem_reg_write_addr) && datamem_reg_write_enable) begin
        reg_b = mem;
    end

    else if((ex_reg_b == wb_reg_write_addr) && wb_reg_write_enable) begin
        reg_b = writeback;
    end
end

endmodule
