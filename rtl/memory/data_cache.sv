module data_cache (
    input  logic        clk,
    input  logic        rst,
    
    // Cpu interface - kept signext outside as this isnt rlly cache logic...
    input  logic        write_en,
    input  logic [1:0]  type_control,   // byte/half/word
    /* verilator lint_off UNUSED */
    input  logic [31:0] addr,
    /* verilator lint_on UNUSED */
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
    logic [6:0]         index;
    //selct which set
    logic [1:0]          word_offset;
    /* verilator lint_off UNUSED */
    logic [1:0]          byte_offset;
    /* verilator lint_on UNUSED */

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

    // request capture regs - save request info on miss (inputs may change during multi-cycle miss)
    logic              req_write_en;
    logic [1:0]        req_word_offset;
    logic [31:0]       req_din;
    logic [TAG_BITS-1:0] req_tag;
    logic [6:0]        req_index;
    logic              req_replace_way;
    
    always_ff @(posedge clk or posedge rst )begin
        if (rst) begin
            state           <= IDLE;
            req_write_en    <= 1'b0;
            req_word_offset <= 2'b0;
            req_din         <= 32'b0;
            req_tag         <= '0;
            req_index       <= 7'b0;
            req_replace_way <= 1'b0;
        end
        else begin
            state <= next_state;

            // capture request when leaving IDLE, miss detetcted 
            if (state == IDLE && next_state != IDLE) begin
                req_write_en    <= write_en;
                req_word_offset <= word_offset;
                req_din         <= din;
                req_tag         <= tag;
                req_index       <= index;
                req_replace_way <= replace_way;
            end
        end
    end

  //next  state logic
    logic mem_access;
    assign mem_access = write_en || ( !write_en && (type_control !=  2'b11));
    // w or r
    
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


    // Stall
    // miiss is in IDLE or genrally in any non idle set
    assign stall = (state != IDLE) || (mem_access && !cache_hit);

     //mem interface - WB or alloc (use captured values)
    always_comb begin
        mem_read  = 1'b0;
        mem_write = 1'b0;
        mem_addr  = 32'b0;
        mem_wdata = 128'b0 ;
        case (state)
            WRITEBACK: begin
                mem_write = 1'b1;
                mem_addr  = {tags[req_index][req_replace_way], req_index, 4'b0000};
                mem_wdata = data[req_index][req_replace_way];
            end
            
            ALLOCATE : begin
                mem_read = 1'b1;
                mem_addr = {req_tag, req_index , 4'b0000};  // has to be block aligned
            end
            
            default: ;
            // other states no mem acecss 
        endcase
    end

    ///read data out
    logic [BLOCK_BITS-1:0] hit_block;
    logic [31:0]           selected_word ;

    always_comb begin
        if (hit_way0)
            hit_block = data[index][0];
        else if (hit_way1)
            hit_block = data[index][1];
        else
            hit_block = 128'b0;
    end
    
    // select corrct word from offset
    always_comb begin
        case (word_offset)
            2'b00: selected_word = hit_block[31:0];
            2'b01: selected_word = hit_block[63:32];
            2'b10: selected_word = hit_block[95: 64];
            2'b11: selected_word = hit_block[127:96];
        endcase
    end
    
    assign dout = selected_word;

    //update the cache:
    // which way was hit (for updates)
    logic hit_way;
    always_comb begin
        if (hit_way0)
            hit_way = 1'b0;
        else
            hit_way = 1'b1;
    end
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset bits
            /* verilator lint_off BLKLOOPINIT */
            for (int i = 0; i < NUM_SETS; i++) begin
                valid[i][0] <= 1'b0;
                valid[i][1] <= 1'b0;
                dirty[i][0] <= 1'b0;
                dirty[i][1] <= 1'b0;
                lru[i]      <= 1'b0;
            end
            /* verilator lint_on BLKLOOPINIT */
        end
        else begin
            case (state)
                IDLE: begin
                    if (cache_hit) begin
                        
                        lru[index] <= hit_way ? 1'b0 : 1'b1;
            
                        if (write_en) begin
                            dirty[index][hit_way] <= 1'b1;

                            // merge write data into block
                            case (word_offset)
                                2'b00: data[index][hit_way][31:0]   <= din;
                                2'b01: data[index][hit_way][63:32]  <= din;
                                2'b10: data[index][hit_way][95:64]  <= din;
                                2'b11: data[index][hit_way][127:96] <= din;
                            endcase
                        end
                    end
                end
                
                UPDATE_CACHE: begin
                     // Install new block (use captured values)
                    valid[req_index][req_replace_way] <= 1'b1;
                    tags[req_index][req_replace_way]  <= req_tag;
                    lru[req_index] <= req_replace_way ? 1'b0 : 1'b1;

                    if (req_write_en) begin
                        // write miss - merge write data into fetched block
                        dirty[req_index][req_replace_way] <= 1'b1;
                        case (req_word_offset)
                            2'b00: data[req_index][req_replace_way] <= {mem_rdata[127:32], req_din};
                            2'b01: data[req_index][req_replace_way] <= {mem_rdata[127:64], req_din, mem_rdata[31:0]};
                            2'b10: data[req_index][req_replace_way] <= {mem_rdata[127:96], req_din, mem_rdata[63:0]};
                            2'b11: data[req_index][req_replace_way] <= {req_din, mem_rdata[95:0]};
                        endcase
                    end
                    else begin
                        // read miss - just install block
                        dirty[req_index][req_replace_way] <= 1'b0;
                        data[req_index][req_replace_way]  <= mem_rdata;
                    end
                end
                
                default: ;
            endcase
        end
    end

endmodule
