module memory #(
    parameter DATA_WIDTH = 32
) (
    input logic clk,
    
    // control signals from EXE PL reg? 
    input logic mem_write,
    input logic [1:0] type_control,
    input logic sign_ext_flag,
    input logic [1:0] result_src,  //result mux
    
    // data from EXe PL reg? 
    input logic [DATA_WIDTH-1:0] alu_result,
    input logic [DATA_WIDTH-1:0] write_data,
    input logic [DATA_WIDTH-1:0] pc4,  //result mux
    
    output logic [DATA_WIDTH-1:0] result
);

    logic [DATA_WIDTH-1:0] read_data;

    datamem datamem_inst(
        .clk(clk),
        .write_en(mem_write),
        .type_control(type_control),
        .addr(alu_result),
        .din(write_data),
        .sign_ext(sign_ext_flag),
        .dout(read_data)
    );

    //result mux
    always_comb begin
        case(result_src)
            2'b00   : result = alu_result;
            2'b01   : result = read_data;
            2'b10   : result = pc4;
            default : result = alu_result;
        endcase
    end

endmodule