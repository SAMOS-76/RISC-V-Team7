module data_cache (
    input  logic        clk,
    input  logic        rst,
    
    // Cpu interface - kept signext outside as this isnt rlly cache logic...
    input  logic        write_en,
    input  logic [1:0]  type_control,   // byte/half/word
    input  logic [31:0] addr,
    input  logic [31:0] din,
    output logic [31:0] dout,
    output logic        stall,
    
    // mem interface
    output logic        mem_read,
    output logic        mem_write,
    output logic [31:0] mem_addr,
    output logic [127:0] mem_wdata,
    input  logic [127:0] mem_rdata,
    input  logic        mem_ready
);

//storage
    // cache params
    localparam NUM_SETS = 128;
    localparam NUM_WAYS = 2;
    localparam TAG_BITS = 21;
    localparam BLOCK_BITS = 128;  // 4 words

    logic                  valid [NUM_SETS-1:0] [NUM_WAYS-1:0 ];
    logic                  dirty [NUM_SETS-1:0] [NUM_WAYS-1:0 ];
    logic [TAG_BITS-1:0]   tags  [NUM_SETS-1:0] [NUM_WAYS-1:0 ];
    logic [BLOCK_BITS-1:0] data  [NUM_SETS-1:0] [NUM_WAYS-1:0 ];
    
    // LRU tracking (1 bit per set)
    logic [NUM_SETS-1:0] lru;


endmodule