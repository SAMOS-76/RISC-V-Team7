// cache controller fsm manages cache hits, misses, writebacks, and refills
module cache_controller (
    input  logic        clk,
    input  logic        rst,

    // cpu -> mem stage of ppl eventually
    input  logic [31:0] cpu_addr,
    input  logic [31:0] cpu_wdata,
    input  logic        cpu_mem_write,
    input  logic        cpu_mem_read,
    input  logic [1:0]  cpu_type,  //00=byte, 01=half, 10=word
    input  logic        cpu_sign_ext,
    output logic [31:0] cpu_rdata,
    output logic        stall,

    // sram
    output logic [6:0]   sram_set_idx,
    output logic         sram_write_en,
    output logic [302:0] sram_wdata,     // data to write (LRU + 2 ways)
    input  logic [302:0] sram_rdata,  // data from SRAM (LRU + 2 ways)

    // main mem interface
    output logic [31:0] mem_addr,
    output logic [31:0] mem_wdata,
    output logic        mem_write_en,
    output logic [1:0]  mem_type,   // access type (always word for burst)
    input  logic [31:0] mem_rdata   // data from main memory
);

    typedef enum logic [1:0]{
        IDLE, //wait/hit
        WRITEBACK, //get rid of dirty
        ALLOCATE, //fetch
         UPDATE_SRAM} state_t;
    state_t state, next_state;

    // burst counter tracks which word (0-3) we're reading/writing during refill/writeback
    logic [1:0] burst_cnt;
    logic burst_inc, burst_rst;

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            burst_cnt <= 2'b00;
        end else if (burst_rst) begin
            burst_cnt <= 2'b00;
        end else if (burst_inc) begin
            burst_cnt <= burst_cnt + 1;
        end
    end

    always_ff @(posedge clk, posedge rst) begin 
        if (rst) state <= IDLE; 
        else     state <= next_state;
    end

    //address decode
    logic [20:0] tag;
    logic [6:0]  set_idx;
    logic [3:0]  offset ;
    assign {tag, set_idx, offset} = {cpu_addr[31:11], cpu_addr[10:4], cpu_addr[3:0]};

    //latch request info at miss so controller is robust if cpu changes signals under stall
    logic [20:0] miss_tag;
    logic [6:0]  miss_set_idx;
    logic [3:0]  miss_offset ;
    logic [1:0]  miss_type;
    logic [31:0] miss_wdata;
    logic        miss_is_write;

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            miss_tag      <= '0;
            miss_set_idx  <= '0;
            miss_offset   <= '0;
            miss_type     <= 2'b00;
            miss_wdata    <= '0;
            miss_is_write <= 1'b0;
        end else if (state == IDLE && (cpu_mem_read || cpu_mem_write) && !(w0_valid && (w0_tag == tag)) && !(w1_valid && (w1_tag == tag))) begin
            // latch the miss-causing request
            miss_tag      <= tag;
            miss_set_idx  <= set_idx;
            miss_offset   <= offset;
            miss_type     <= cpu_type;
            miss_wdata    <= cpu_wdata;
            miss_is_write <= cpu_mem_write;
        end
    end

    //unpack 303-bit sram data
    // [LRU:1][Way1: V  D  Tag  Data][Way0: V  D  Tag  Data]
    logic        lru_bit;                 // LRU bit: 0 ofc way0, 1=use way1
    logic        w1_valid,  w1_dirty;
    logic        w0_valid, w0_dirty;
    logic [20:0] w1_tag, w0_tag ;
    logic [127:0] w1_data, w0_data;
    
    assign {lru_bit, w1_valid, w1_dirty, w1_tag, w1_data, w0_valid, w0_dirty, w0_tag, w0_data} = sram_rdata;

    // hit/miss detect logic
    logic hit0, hit1, hit, req;
    assign req  =  cpu_mem_read || cpu_mem_write;  // any mem request
    assign hit0 = w0_valid && (w0_tag == tag) ;
    assign hit1 = w1_valid && (w1_tag == tag);
    assign hit  = req && (hit0  || hit1);   //overall hit

    //victim selct, which way to evict on miss
    logic victim_way; 
    assign victim_way = lru_bit;

    // victim data extract
    logic [127:0] victim_data;   // data to write back if dirty
    logic [20:0]  victim_tag;    // tag to form wb address
    logic         victim_dirty ;
    logic         victim_valid;
    
    assign victim_data  = victim_way ? w1_data  : w0_data;
    assign victim_tag   = victim_way ? w1_tag   : w0_tag;
    assign victim_dirty = victim_way  ? w1_dirty : w0_dirty;
    assign victim_valid = victim_way ? w1_valid : w0_valid;

    logic [127:0] selected_line_data;
    assign selected_line_data = hit1 ? w1_data : w0_data;

    // read formatter, get byte/half/word from 128-bit cache line
    cache_read_formatter read_fmt (
        .line_in(selected_line_data),
        .offset(offset),
        .size_type(cpu_type),
        .sign_ext(cpu_sign_ext),
        .data_out(cpu_rdata)
    );

    // write formatter for hit --  merges CPU write into existing  cache line
    logic [127:0] hit_updated_line;
    cache_write_formatter hit_write_fmt (
        .line_in(selected_line_data),
        .offset(offset),
        .size_type(cpu_type),
        .wdata(cpu_wdata),
        .write_en(cpu_mem_write),
        .line_out(hit_updated_line)
    );

    // refill buffer as stores words 0,1,2 from BRAM as they arrive (word 3 on wire) 
    //needed as BRAM has 1-cycle read latency, buffer captures data before its overwritten
    logic [95:0] alloc_buffer;
    
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            alloc_buffer <= '0 ;
        end else if (state == ALLOCATE) begin //eg N+1 latency
            case(burst_cnt)
                2'b01: alloc_buffer[31:0]   <= mem_rdata;  // capture word 0
                2'b10: alloc_buffer[63:32]  <= mem_rdata;  // capture word 1
                2'b11: alloc_buffer[95:64]  <= mem_rdata;  // capture word 2
                default: ; 
            endcase
        end
    end
    
    //recombine, word 3 arriving rn
    logic [127:0] refill_line_raw;
    assign refill_line_raw = { mem_rdata, alloc_buffer};  // {word3, word2, word1, word0}

    // write format - merge
    logic [127:0] refill_line_merged;
    cache_write_formatter refill_write_fmt (
        .line_in(refill_line_raw),
        .offset(miss_offset),
        .size_type(miss_type),
        .wdata(miss_wdata),
        .write_en(miss_is_write), 
        .line_out(refill_line_merged )
    );

    logic new_lru;

    always_comb begin
        //deafults
        next_state = state;
        stall      = 1'b0;
        burst_inc  = 1'b0;
        burst_rst  = 1'b0 ;
        
        // use live set index only in IDLE; during miss handling, stick with latched miss_set_idx
        sram_set_idx  = (state == IDLE) ? set_idx : miss_set_idx;
        sram_write_en = 1'b0;
        sram_wdata    = '0;

        mem_addr     = '0;
        mem_wdata    = '0;
        mem_write_en = 1'b0 ;
        mem_type     = 2'b10; //burst always wrd
        new_lru      = 1'b0;

        case (state)
            IDLE: begin
                if (req ) begin
                    if (hit)  begin
                        sram_write_en  = 1'b1;
                        new_lru = hit0 ? 1'b1 : 1'b0;  // update LRU, ie point to other way
                        
                        if (cpu_mem_write) begin
                            // write hit: update data and set dirty bit
                            if (hit0) 
                                sram_wdata = {new_lru, w1_valid, w1_dirty, w1_tag, w1_data, 1'b1, 1'b1, w0_tag, hit_updated_line};
                            else      
                                sram_wdata = {new_lru, 1'b1, 1'b1, w1_tag, hit_updated_line,  w0_valid, w0_dirty, w0_tag, w0_data};
                        end else begin
                            //read hit, just LRU update
                            if (hit0) 
                                sram_wdata = {new_lru, w1_valid, w1_dirty, w1_tag, w1_data, w0_valid, w0_dirty, w0_tag, w0_data};
                            else      
                                sram_wdata = {new_lru, w1_valid, w1_dirty, w1_tag, w1_data,  w0_valid, w0_dirty, w0_tag, w0_data};
                        end
                    end 
                    else begin
                        //cache miss,  stall and check if victim needs writeback
                        stall = 1'b1 ;
                        burst_rst = 1'b1;
                        next_state = (victim_valid && victim_dirty ) ? WRITEBACK : ALLOCATE;
                    end
                end
            end

            WRITEBACK: begin
                //evict dirty victim line to main mem (4-word burst write)
                stall = 1'b1;
                mem_write_en = 1'b1 ;
                mem_addr = { victim_tag, miss_set_idx, burst_cnt, 2'b00};  // form address using latched set index
                
                // selct which word to wb
                case(burst_cnt)
                    2'b00: mem_wdata = victim_data[31:0];
                    2'b01: mem_wdata = victim_data[63:32];
                    2'b10: mem_wdata = victim_data[95:64];
                    2'b11: mem_wdata = victim_data[127:96];
                endcase
                
                burst_inc = 1'b1;
                if (burst_cnt == 2'b11 ) begin
                    burst_rst = 1'b1 ;
                    next_state = ALLOCATE;
                end
            end

            ALLOCATE: begin
                //fetch new line from main memory -  burst read 
                stall = 1'b1;
                mem_addr = {miss_tag, miss_set_idx, burst_cnt, 2'b00} ;
                burst_inc = 1'b1;
                
                if (burst_cnt == 2'b11) 
                    next_state = UPDATE_SRAM;  //after all fetched, udpate cahce
            end

            UPDATE_SRAM: begin
                stall = 1'b1;
                sram_write_en = 1'b1;
                new_lru = victim_way ? 1'b0 : 1'b1 ;

                //write to victim way with new
                if (victim_way == 0)
                    sram_wdata = {new_lru, w1_valid, w1_dirty, w1_tag, w1_data, 1'b1, miss_is_write, miss_tag, refill_line_merged};
                else
                    sram_wdata = {new_lru, 1'b1,  miss_is_write, miss_tag, refill_line_merged, w0_valid, w0_dirty, w0_tag, w0_data};
                
                next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end
endmodule
