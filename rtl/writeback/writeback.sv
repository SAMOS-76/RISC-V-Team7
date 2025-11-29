module writeback #(
    parameter DATA_WIDTH = 32
) (
    input  logic [1:0]            result_src,
    input  logic [DATA_WIDTH-1:0] alu_result,
    input  logic [DATA_WIDTH-1:0] mem_data,
    input  logic [DATA_WIDTH-1:0] pc4,
    
    output logic [DATA_WIDTH-1:0] result
);
    
    always_comb begin
        case(result_src)
            2'b00: result = alu_result;
            2'b01: result = mem_data;
            2'b10: result = pc4;
            default: result = alu_result;
        endcase
    end
    
endmodule