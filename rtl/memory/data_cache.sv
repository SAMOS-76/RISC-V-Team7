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

    // replacement lgic, semi FSM setup 
    logic replace_way;
    logic need_writeback;
    logic [31:0] writeback_addr ;
    
    assign replace_way = lru[index];
    assign need_writeback = valid[index][replace_way] && dirty[index][replace_way];
    assign writeback_addr = {tags[index][replace_way], index,  4'b0000 };

    // FSM
    
    typedef enum logic [ 1:0]{
        IDLE,
        WRITEBACK,
        ALLOCATE,
        UPDATE_CACHE
    } state_t ;
    
    state_t state, next_state;
    
    always_ff @(posedge clk or posedge rst )begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

  //next  state logic
    logic mem_access;
    assign mem_access = write_en || ( !write_en && (type_control !=  2'b11)); // w or r
    
    always_comb begin
        next_state = state;

        case (state)
            IDLE: begin
                if (mem_access &&  !cache_hit) begin
                    //handle a miss
                    if (need_writeback )
                        next_state =  WRITEBACK;
                    else
                        next_state = ALLOCATE;
                end
            end
            
            WRITEBACK: begin
                if (mem_ready)
                    next_state = ALLOCATE;
            end
            
            ALLOCATE: begin
                if (mem_ready)
                    next_state = UPDATE_CACHE;
            end
            
            UPDATE_CACHE : begin
                next_state = IDLE;
            end
        endcase
    end


endmodule