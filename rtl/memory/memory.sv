module memory #(
    parameter DATA_WIDTH = 32
) (
    input logic                   clk,
    input logic                   rst,

    // control signals from EXE PL reg
    input logic                   mem_write,
    input logic [1:0]             type_control,
    input logic                   sign_ext_flag,

    // data from EXe PL reg
    input logic [DATA_WIDTH-1:0]  alu_result,
    input logic [DATA_WIDTH-1:0]  write_data,

    output logic [DATA_WIDTH-1:0] alu_result_out,
    output logic [DATA_WIDTH-1:0] read_data,
    output logic                  cache_stall
);

    assign alu_result_out = alu_result; // pass through signal

    // Backing memory (acts as main memory for cache)
    logic [DATA_WIDTH-1:0] backing_mem_dout;
    logic backing_mem_write_en;
    logic [1:0] backing_mem_type_control;
    logic [DATA_WIDTH-1:0] backing_mem_addr;
    logic [DATA_WIDTH-1:0] backing_mem_din;
    logic backing_mem_sign_ext;

    datamem datamem_inst(
        .clk(clk),
        .write_en(backing_mem_write_en),
        .type_control(backing_mem_type_control),
        .addr(backing_mem_addr),
        .din(backing_mem_din),
        .sign_ext(backing_mem_sign_ext),
        .dout(backing_mem_dout)
    );

    // Cache with BYTE_BYPASS=1 for PDF test compatibility
    cache #(
        .NUM_SETS(512),
        .ADDR_WIDTH(32),
        .DATA_WIDTH(32),
        .LINE_WIDTH(32),
        .BYTE_BYPASS(1)  // Bypass cache for byte accesses
    ) cache_inst (
        .clk(clk),
        .rst(rst),

        // CPU interface
        .write_en(mem_write),
        .type_control(type_control),
        .addr(alu_result),
        .din(write_data),
        .sign_ext(sign_ext_flag),
        .dout(read_data),
        .stall(cache_stall),

        // Memory interface (to backing datamem)
        .mem_write_en(backing_mem_write_en),
        .mem_type_control(backing_mem_type_control),
        .mem_addr(backing_mem_addr),
        .mem_din(backing_mem_din),
        .mem_sign_ext(backing_mem_sign_ext),
        .mem_dout(backing_mem_dout)
    );

endmodule
