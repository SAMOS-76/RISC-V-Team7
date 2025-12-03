module memory #(
    parameter DATA_WIDTH = 32
) (
    input logic                   clk,
    
    // control signals from EXE PL reg? 
    input logic                   mem_write,
    input logic [1:0]             type_control,
    input logic                   sign_ext_flag,
    
    // data from EXe PL reg? 
    input logic [DATA_WIDTH-1:0]  alu_result,
    input logic [DATA_WIDTH-1:0]  write_data,
    
    output logic [DATA_WIDTH-1:0] alu_result_out,
    output logic [DATA_WIDTH-1:0] read_data
);

    assign alu_result_out = alu_result; // pass through signaL.

    datamem datamem_inst(
        .clk(clk),
        .write_en(mem_write),
        .type_control(type_control),
        .addr(alu_result),
        .din(write_data),
        .sign_ext(sign_ext_flag),
        .dout(read_data)
    );

endmodule
