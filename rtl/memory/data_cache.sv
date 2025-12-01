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

    //exxtract bit patterns from addr
    logic [TAG_BITS-1:0] tag;
    logic [6:0]         index; //selct which set
    logic [1:0]          word_offset;
    logic [1:0]          byte_offset;
    
    assign tag         = addr[31:11];
    assign index       = addr[10:4];
    assign word_offset = addr[3:2] ;
    assign byte_offset = addr[1:0];

    // detect hits -check each way in the set and hits 
    logic hit_way0;
    logic hit_way1;
    logic cache_hit;

    assign hit_way0 = valid[index][0] && (tags[index][0] == tag);
    assign hit_way1 = valid[index][1] && (tags[index][1] == tag);
    assign cache_hit = hit_way0 || hit_way1 ;



endmodule