module cache #(
    parameter NUM_SETS = 512,
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter LINE_WIDTH = 32,
    parameter BYTE_BYPASS = 0,  // 0 = all access, 1 = bypass byte ops //this is for legacy testing purposes
    parameter CACHE_ENABLE = 0  // 0 =pt,  1 = wt ,  2 = wb
)(
    input logic clk,
    input logic rst,

    //_> cpu
    input logic write_en,
    input logic [1:0] type_control,
    input logic [ADDR_WIDTH-1:0] addr,
    input logic [DATA_WIDTH-1:0] din,
    input logic sign_ext,
    output logic [DATA_WIDTH-1:0] dout,
    output logic stall,

    // -> main mem 
    output logic mem_write_en,
    output logic [1:0] mem_type_control,
    output logic [ADDR_WIDTH-1:0] mem_addr,
    output logic [DATA_WIDTH-1:0] mem_din,
    output logic mem_sign_ext,
    input logic [DATA_WIDTH-1:0] mem_dout
);

    // Cache parameters
    localparam INDEX_BITS = 9;
    localparam TAG_BITS = 21;

    //-> l1
    logic [INDEX_BITS-1:0] L1_read_index;
    logic [LINE_WIDTH-1:0] L1_data_way0;
    logic [LINE_WIDTH-1:0] L1_data_way1;
    logic [TAG_BITS-1:0] L1_tag_way0;
    logic [TAG_BITS-1:0] L1_tag_way1;
    logic L1_valid_way0;
    logic L1_valid_way1;
    logic L1_dirty_way0;
    logic L1_dirty_way1;
    logic L1_lru_bit;

    logic L1_write_en_way0;
    logic L1_write_en_way1;
    logic [INDEX_BITS-1:0] L1_write_index;
    logic [LINE_WIDTH-1:0] L1_write_data_way0;
    logic [LINE_WIDTH-1:0] L1_write_data_way1;
    logic [TAG_BITS-1:0] L1_write_tag_way0;
    logic [TAG_BITS-1:0] L1_write_tag_way1;
    logic L1_write_valid_way0;
    logic L1_write_valid_way1;
    logic L1_write_dirty_way0;
    logic L1_write_dirty_way1;
    logic L1_write_lru;
    logic L1_lru_value;

    cache_L1 #(
        .NUM_SETS(NUM_SETS),
        .LINE_WIDTH(LINE_WIDTH),
        .TAG_BITS(TAG_BITS),
        .INDEX_BITS(INDEX_BITS)
    ) L1_inst (
        .clk(clk),
        .rst(rst),
        //read
        .read_index(L1_read_index),
        .data_way0(L1_data_way0),
        .data_way1(L1_data_way1),
        .tag_way0(L1_tag_way0),
        .tag_way1(L1_tag_way1),
        .valid_way0(L1_valid_way0),
        .valid_way1(L1_valid_way1),
        .dirty_way0(L1_dirty_way0),
        .dirty_way1(L1_dirty_way1),
        .lru_bit(L1_lru_bit),
        //wrte
        .write_en_way0(L1_write_en_way0),
        .write_en_way1(L1_write_en_way1),
        .write_index(L1_write_index),
        .write_data_way0(L1_write_data_way0),
        .write_data_way1(L1_write_data_way1),
        .write_tag_way0(L1_write_tag_way0),
        .write_tag_way1(L1_write_tag_way1),
        .write_valid_way0(L1_write_valid_way0),
        .write_valid_way1(L1_write_valid_way1),
        .write_dirty_way0(L1_write_dirty_way0),
        .write_dirty_way1(L1_write_dirty_way1),
        .write_lru(L1_write_lru),
        .lru_value(L1_lru_value)
    );

    cache_controller #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .LINE_WIDTH(LINE_WIDTH),
        .TAG_BITS(TAG_BITS),
        .INDEX_BITS(INDEX_BITS),
        .BYTE_BYPASS(BYTE_BYPASS),
        .CACHE_ENABLE(CACHE_ENABLE)
    ) controller_inst (
        .clk(clk),
        .rst(rst),
        //cpu
        .write_en(write_en),
        .type_control(type_control),
        .addr(addr),
        .din(din),
        .sign_ext(sign_ext),
        .dout(dout),
        .stall(stall),
        //mem
        .mem_write_en(mem_write_en),
        .mem_type_control(mem_type_control),
        .mem_addr(mem_addr),
        .mem_din(mem_din),
        .mem_sign_ext(mem_sign_ext),
        .mem_dout(mem_dout),
        //l1 read
        .L1_read_index(L1_read_index),
        .L1_data_way0(L1_data_way0),
        .L1_data_way1(L1_data_way1),
        .L1_tag_way0(L1_tag_way0),
        .L1_tag_way1(L1_tag_way1),
        .L1_valid_way0(L1_valid_way0),
        .L1_valid_way1(L1_valid_way1),
        .L1_dirty_way0(L1_dirty_way0),
        .L1_dirty_way1(L1_dirty_way1),
        .L1_lru_bit(L1_lru_bit),
        //l1 write
        .L1_write_en_way0(L1_write_en_way0),
        .L1_write_en_way1(L1_write_en_way1),
        .L1_write_index(L1_write_index),
        .L1_write_data_way0(L1_write_data_way0),
        .L1_write_data_way1(L1_write_data_way1),
        .L1_write_tag_way0(L1_write_tag_way0),
        .L1_write_tag_way1(L1_write_tag_way1),
        .L1_write_valid_way0(L1_write_valid_way0),
        .L1_write_valid_way1(L1_write_valid_way1),
        .L1_write_dirty_way0(L1_write_dirty_way0),
        .L1_write_dirty_way1(L1_write_dirty_way1),
        .L1_write_lru(L1_write_lru),
        .L1_lru_value(L1_lru_value)
    );

endmodule
