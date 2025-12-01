module memory #(
    parameter DATA_WIDTH = 32
) (
    input logic                   clk,
    input logic                   rst,
    input logic                   mem_write,
    input logic [1:0]             type_control,
    input logic                   sign_ext_flag,
    input logic [DATA_WIDTH-1:0]  alu_result,
    input logic [DATA_WIDTH-1:0]  write_data,
    
    output logic [DATA_WIDTH-1:0] alu_result_out,
    output logic [DATA_WIDTH-1:0] read_data,
    output logic                  mem_stall
);
    assign alu_result_out = alu_result;

    // Cache datamem interface
    logic        cache_mem_read;
    logic        cache_mem_write;
    logic [31:0] cache_mem_addr;
    logic [127:0] cache_mem_wdata;
    logic [127:0] cache_mem_rdata;
    logic        cache_mem_ready;

    // Raw data from cache (before sign extension)
    logic [31:0] cache_dout;

    data_cache cache_inst (
        .clk(clk),
        .rst(rst),
        .write_en(mem_write),
        .type_control(type_control),
        .addr(alu_result),
        .din(write_data),
        .dout(cache_dout),
        .stall(mem_stall),
        .mem_read(cache_mem_read),
        .mem_write(cache_mem_write),
        .mem_addr(cache_mem_addr),
        .mem_wdata(cache_mem_wdata),
        .mem_rdata(cache_mem_rdata),
        .mem_ready(cache_mem_ready)
    );

    datamem datamem_inst (
        .clk(clk),
        .rst(rst),
        .write_en(1'b0),
        .type_control(2'b10),
        .addr(32'b0),
        .din(32'b0),
        .sign_ext(1'b0),
        /* verilator lint_off PINCONNECTEMPTY */
        .dout(), 
        /* verilator lint_on PINCONNECTEMPTY */
        
        // Block interface (for cache)
        .block_read(cache_mem_read),
        .block_write(cache_mem_write),
        .block_addr(cache_mem_addr),
        .block_din(cache_mem_wdata),
        .block_dout(cache_mem_rdata),
        .block_ready(cache_mem_ready)
    );

    // Sign extension
    always_comb begin
        case (type_control)
            2'b00:   read_data = {{24{sign_ext_flag & cache_dout[7]}},  cache_dout[7:0]};
            2'b01:   read_data = {{16{sign_ext_flag & cache_dout[15]}}, cache_dout[15:0]};
            2'b10:   read_data = cache_dout;
            default: read_data = cache_dout;
        endcase
    end

endmodule
