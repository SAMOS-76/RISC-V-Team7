module cache_controller #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter LINE_WIDTH = 32,
    parameter TAG_BITS = 21,      // TAG_BITS = 32 - 9 - 2 = 21
    parameter INDEX_BITS = 9,     // log2(512) = 9 bits
    parameter BYTE_BYPASS = 0,    // 1 = bypass cache for byte accesses, 0 = cache all accesses
    parameter CACHE_ENABLE = 0    // 0 = passthrough, 1 = write-through, 2 = write-back
)(
    input logic clk,
    input logic rst,

   //-> cpu
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
    input logic [DATA_WIDTH-1:0] mem_dout,

    //L1 read
    output logic [INDEX_BITS-1:0] L1_read_index,
    input logic [LINE_WIDTH-1:0] L1_data_way0,
    input logic [LINE_WIDTH-1:0] L1_data_way1,
    input logic [TAG_BITS-1:0] L1_tag_way0,
    input logic [TAG_BITS-1:0] L1_tag_way1,
    input logic L1_valid_way0,
    input logic L1_valid_way1,
    input logic L1_dirty_way0,
    input logic L1_dirty_way1,
    input logic L1_lru_bit,

    //L1 write
    output logic L1_write_en_way0,
    output logic L1_write_en_way1,
    output logic [INDEX_BITS-1:0] L1_write_index,
    output logic [LINE_WIDTH-1:0] L1_write_data_way0,
    output logic [LINE_WIDTH-1:0] L1_write_data_way1,
    output logic [TAG_BITS-1:0] L1_write_tag_way0,
    output logic [TAG_BITS-1:0] L1_write_tag_way1,
    output logic L1_write_valid_way0,
    output logic L1_write_valid_way1,
    output logic L1_write_dirty_way0,
    output logic L1_write_dirty_way1,
    output logic L1_write_lru,
    output logic L1_lru_value
);

//fsm
    typedef enum logic [1:0] {
        IDLE,
        WRITEitBack,
        ALLOCit
    } cache_state_t;

    cache_state_t state, next_state;

    //captures the pending request during multi-cycle miss
    logic [ADDR_WIDTH-1:0] miss_addr;
    logic [DATA_WIDTH-1:0] miss_din;
    logic [1:0] miss_type_control;
    logic miss_write_en;
    logic miss_sign_ext;

    logic [TAG_BITS-1:0] tag;
    logic [INDEX_BITS-1:0] index;
    logic [ADDR_WIDTH-1:0] current_addr;
    logic [1:0] current_type_control;
    logic [DATA_WIDTH-1:0] current_din;
    logic current_write_en;
    logic current_sign_ext;

    //mux between current request and saved miss request
    assign current_addr = (state != IDLE) ? miss_addr : addr;
    assign current_type_control = (state != IDLE) ? miss_type_control : type_control;
    assign current_din = (state != IDLE) ? miss_din : din;
    assign current_write_en = (state != IDLE) ? miss_write_en : write_en;
    assign current_sign_ext = (state != IDLE) ? miss_sign_ext : sign_ext;

    //[TAG | INDEX | BYTE_OFFSET]
    assign tag = current_addr[ADDR_WIDTH-1:INDEX_BITS+2];
    assign index = current_addr[INDEX_BITS+1:2];

    assign L1_read_index = index;
    assign L1_write_index = index;

    //hit dtect
    logic hit_way0, hit_way1, hit;
    logic is_word_access, is_halfword_access, is_byte_access, is_cacheable_access;

    assign is_word_access = (current_type_control == 2'b10);
    assign is_halfword_access = (current_type_control == 2'b01);
    assign is_byte_access = (current_type_control == 2'b00);

    // Cacheable access depends on BYTE_BYPASS parameter and CACHE_ENABLE
    assign is_cacheable_access = (CACHE_ENABLE == 0) ? 1'b0 :
                                 (BYTE_BYPASS ? (is_word_access || is_halfword_access) :
                                               (is_word_access || is_halfword_access || is_byte_access));

    assign hit_way0 = L1_valid_way0 && (L1_tag_way0 == tag) && is_cacheable_access;
    assign hit_way1 = L1_valid_way1 && (L1_tag_way1 == tag) && is_cacheable_access;
    assign hit = hit_way0 || hit_way1;

    logic victim_way;
    logic evict_dirty;

    always_comb begin
        if (!L1_valid_way0)
            victim_way = 1'b0;
        else if (!L1_valid_way1)
            victim_way = 1'b1;
        else
            victim_way = L1_lru_bit;

        //need wb?
        evict_dirty = (victim_way == 1'b0) ?
                      (L1_valid_way0 && L1_dirty_way0) :
                      (L1_valid_way1 && L1_dirty_way1);
    end

    //state reg
    always_ff @(posedge clk) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // FSM logic - selects behavior based on CACHE_ENABLE parameter
    always_comb begin
        if (CACHE_ENABLE == 0) begin
            // PASSTHROUGH MODE: Never stall
            next_state = IDLE;
            stall = 1'b0;
        end else if (CACHE_ENABLE == 1) begin
            // WRITE-THROUGH MODE: Stall only on read misses
            next_state = state;
            stall = 1'b0;
            case (state)
                IDLE: begin
                    if (is_cacheable_access && !hit && !current_write_en) begin
                        next_state = ALLOCit;
                        stall = 1'b1;
                    end
                end
                ALLOCit: begin
                    next_state = IDLE;
                    stall = 1'b1;
                end
                default: next_state = IDLE;
            endcase
        end else begin
            // WRITE-BACK MODE: Stall on misses, handle dirty evictions
            next_state = state;
            stall = 1'b0;
            case (state)
                IDLE: begin
                    if (is_cacheable_access && !hit) begin
                        if (evict_dirty) begin
                            next_state = WRITEitBack;
                            stall = 1'b1;
                        end else begin
                            next_state = ALLOCit;
                            stall = 1'b1;
                        end
                    end
                end
                WRITEitBack: begin
                    next_state = ALLOCit;
                    stall = 1'b1;
                end
                ALLOCit: begin
                    next_state = IDLE;
                    stall = 1'b1;
                end
                default: next_state = IDLE;
            endcase
        end
    end

    //miss req reg
    always_ff @(posedge clk) begin
        if (state == IDLE && (next_state == WRITEitBack || next_state == ALLOCit)) begin
            miss_addr <= addr;
            miss_din <= din;
            miss_type_control <= type_control;
            miss_write_en <= write_en;
            miss_sign_ext <= sign_ext;
        end
    end


    logic write_to_mem;
    logic [ADDR_WIDTH-1:0] write_addr;
    logic [DATA_WIDTH-1:0] write_data;
    logic [1:0] write_type;
    logic [LINE_WIDTH-1:0] victim_data;
    logic [TAG_BITS-1:0] victim_tag;

    assign victim_data = (victim_way == 1'b0) ? L1_data_way0 : L1_data_way1;
    assign victim_tag = (victim_way == 1'b0) ? L1_tag_way0 : L1_tag_way1;

    // Memory interface logic - selects behavior based on CACHE_ENABLE parameter
    always_comb begin
        write_to_mem = 1'b0;
        write_addr = current_addr;
        write_data = current_din;
        write_type = current_type_control;

        if (CACHE_ENABLE == 0) begin
            // PASSTHROUGH MODE: All accesses go directly to memory
            write_to_mem = current_write_en;
        end else if (CACHE_ENABLE == 1) begin
            // WRITE-THROUGH MODE: Always write to memory on CPU writes
            case (state)
                IDLE: begin
                    if (current_write_en) begin
                        write_to_mem = 1'b1;
                    end
                end
                ALLOCit: begin
                    write_to_mem = 1'b0; // Just filling cache from memory
                end
                default: begin
                    write_to_mem = 1'b0;
                end
            endcase
        end else begin
            // WRITE-BACK MODE: Only write on dirty evictions
            case (state)
                WRITEitBack: begin
                    write_to_mem = 1'b1;
                    write_addr = {victim_tag, index, 2'b00};
                    write_data = victim_data;
                    write_type = 2'b10; // Always write full word for evictions
                end
                default: begin
                    write_to_mem = 1'b0;
                end
            endcase
        end
    end

    assign mem_write_en = write_to_mem;
    assign mem_type_control = write_type;
    assign mem_addr = write_addr;
    assign mem_din = write_data;
    assign mem_sign_ext = current_sign_ext;

    logic [DATA_WIDTH-1:0] cache_read_data;
    logic [DATA_WIDTH-1:0] extracted_read_data;
    logic [1:0] byte_offset;

    assign byte_offset = current_addr[1:0] ;
    assign cache_read_data = hit_way0 ? L1_data_way0 : L1_data_way1;

    /* verilator lint_off PINCONNECTEMPTY */
    cache_data_parser #(
        .DATA_WIDTH(DATA_WIDTH)
    ) read_parser (
        .type_control(current_type_control),
        .byte_offset(byte_offset),
        .sign_ext(current_sign_ext),
        .cache_line_data(cache_read_data),
        .extracted_data(extracted_read_data),
        .write_data('0),
        .base_data('0),
        .merged_data()
    );
    /* verilator lint_on PINCONNECTEMPTY */

    // Output data logic - selects behavior based on CACHE_ENABLE parameter
    always_comb begin
        if (CACHE_ENABLE == 0) begin
            // PASSTHROUGH MODE: Always use memory output
            dout = mem_dout;
        end else begin
            // WRITE-THROUGH/WRITE-BACK MODE: Use cache on read hits
            if (is_cacheable_access && hit && !current_write_en) begin
                dout = extracted_read_data;
            end else begin
                dout = mem_dout;
            end
        end
    end

    logic [DATA_WIDTH-1:0] merged_cache_data;
    logic [DATA_WIDTH-1:0] merged_mem_data;

    /* verilator lint_off PINCONNECTEMPTY */
    cache_data_parser #(
        .DATA_WIDTH(DATA_WIDTH)
    ) write_hit_parser(
        .type_control(current_type_control) ,
        .byte_offset(byte_offset),
        .sign_ext(current_sign_ext),
        .cache_line_data('0),
        .extracted_data(),
        .write_data(current_din),
        .base_data(cache_read_data),
        .merged_data(merged_cache_data)
    );

    cache_data_parser #(
        .DATA_WIDTH(DATA_WIDTH)
    ) write_miss_parser(
        .type_control(current_type_control),
        .byte_offset(byte_offset),
        .sign_ext(current_sign_ext),
        .cache_line_data('0),
        .extracted_data(),
        .write_data(current_din),
        .base_data(mem_dout),
        .merged_data(merged_mem_data)
    );
    /* verilator lint_on PINCONNECTEMPTY */

    // Cache write logic - selects behavior based on CACHE_ENABLE parameter
    always_comb begin
        // Default values
        L1_write_en_way0 = 1'b0;
        L1_write_en_way1 = 1'b0;
        L1_write_data_way0 = '0;
        L1_write_data_way1 = '0;
        L1_write_tag_way0 = tag;
        L1_write_tag_way1 = tag;
        L1_write_valid_way0 = 1'b1;
        L1_write_valid_way1 = 1'b1;
        L1_write_dirty_way0 = 1'b0;
        L1_write_dirty_way1 = 1'b0;
        L1_write_lru = 1'b0;
        L1_lru_value = 1'b0;

        if (CACHE_ENABLE == 0) begin
            // PASSTHROUGH MODE: Never write to cache
        end else if (CACHE_ENABLE == 1) begin
            // WRITE-THROUGH MODE
            // Write hit: update cache (also writes to memory via write_to_mem)
            if (is_cacheable_access && current_write_en && state == IDLE) begin
                if (hit_way0) begin
                    L1_write_en_way0 = 1'b1;
                    L1_write_data_way0 = merged_cache_data;
                    L1_write_tag_way0 = tag;
                    L1_write_valid_way0 = 1'b1;
                    L1_write_dirty_way0 = 1'b0;  // Write-through: clean
                    L1_write_lru = 1'b1;
                    L1_lru_value = 1'b1;  // way1 now LRU
                end else if (hit_way1) begin
                    L1_write_en_way1 = 1'b1;
                    L1_write_data_way1 = merged_cache_data;
                    L1_write_tag_way1 = tag;
                    L1_write_valid_way1 = 1'b1;
                    L1_write_dirty_way1 = 1'b0;  // Write-through: clean
                    L1_write_lru = 1'b1;
                    L1_lru_value = 1'b0;  // way0 is LRU
                end
            end
            // Read hit: just update LRU
            else if (is_cacheable_access && !current_write_en && state == IDLE) begin
                if (hit_way0) begin
                    L1_write_lru = 1'b1;
                    L1_lru_value = 1'b1;
                end else if (hit_way1) begin
                    L1_write_lru = 1'b1;
                    L1_lru_value = 1'b0;
                end
            end
            // Read miss: allocate line from memory
            else if (is_cacheable_access && state == ALLOCit) begin
                if (victim_way == 1'b0) begin
                    L1_write_en_way0 = 1'b1;
                    L1_write_data_way0 = mem_dout;
                    L1_write_dirty_way0 = 1'b0;  // Clean on fill
                end else begin
                    L1_write_en_way1 = 1'b1;
                    L1_write_data_way1 = mem_dout;
                    L1_write_dirty_way1 = 1'b0;  // Clean on fill
                end
                L1_write_lru = 1'b1;
                L1_lru_value = ~victim_way;
            end
        end else begin
            // WRITE-BACK MODE
            // Write hit: mark dirty
            if (is_cacheable_access && current_write_en && state == IDLE) begin
                if (hit_way0) begin
                    L1_write_en_way0 = 1'b1;
                    L1_write_data_way0 = merged_cache_data;
                    L1_write_tag_way0 = tag;
                    L1_write_valid_way0 = 1'b1;
                    L1_write_dirty_way0 = 1'b1;  // Write-back: mark dirty
                    L1_write_lru = 1'b1;
                    L1_lru_value = 1'b1;
                end else if (hit_way1) begin
                    L1_write_en_way1 = 1'b1;
                    L1_write_data_way1 = merged_cache_data;
                    L1_write_tag_way1 = tag;
                    L1_write_valid_way1 = 1'b1;
                    L1_write_dirty_way1 = 1'b1;  // Write-back: mark dirty
                    L1_write_lru = 1'b1;
                    L1_lru_value = 1'b0;
                end
            end
            // Read hit: just update LRU
            else if (is_cacheable_access && !current_write_en && state == IDLE) begin
                if (hit_way0) begin
                    L1_write_lru = 1'b1;
                    L1_lru_value = 1'b1;
                end else if (hit_way1) begin
                    L1_write_lru = 1'b1;
                    L1_lru_value = 1'b0;
                end
            end
            // Miss: allocate line from memory
            else if (is_cacheable_access && state == ALLOCit) begin
                if (victim_way == 1'b0) begin
                    L1_write_en_way0 = 1'b1;
                    L1_write_data_way0 = current_write_en ? merged_mem_data : mem_dout;
                    L1_write_dirty_way0 = current_write_en ? 1'b1 : 1'b0;
                end else begin
                    L1_write_en_way1 = 1'b1;
                    L1_write_data_way1 = current_write_en ? merged_mem_data : mem_dout;
                    L1_write_dirty_way1 = current_write_en ? 1'b1 : 1'b0;
                end
                L1_write_lru = 1'b1;
                L1_lru_value = ~victim_way;
            end
        end
    end

endmodule
