module cache_controller #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter LINE_WIDTH = 32,
    parameter TAG_BITS = 21,      // TAG_BITS = 32 - 9 - 2 = 21
    parameter INDEX_BITS = 9,     // log2(512) = 9 bits
    parameter BYTE_BYPASS = 0    // 1 = bypass cache for byte accesses, 0 = cache all accesses
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
    typedef enum logic [2:0] {
        IDLE,
        WRITEitBack,
        ALLOCit,
        PREFETCHit
    } cache_state_t;

    cache_state_t state, next_state;

    //captures the pending request during multi-cycle miss
    logic [ADDR_WIDTH-1:0] miss_addr;
    logic [DATA_WIDTH-1:0] miss_din;
    logic [1:0] miss_type_control;
    logic miss_write_en;
    logic miss_sign_ext;

    //prefetch control
    logic prefetch_needed;
    /* verilator lint_off UNUSED */
    logic [ADDR_WIDTH-1:0] prefetch_addr;
    /* verilator lint_on UNUSED */
    logic [TAG_BITS-1:0] prefetch_tag;
    logic [INDEX_BITS-1:0] prefetch_index;

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

    //prefetch next sequential line (increment by line size = 4 bytes)
    assign prefetch_addr = miss_addr + 4;
    assign prefetch_tag = prefetch_addr[ADDR_WIDTH-1:INDEX_BITS+2];
    assign prefetch_index = prefetch_addr[INDEX_BITS+1:2];

    assign L1_read_index = (state == PREFETCHit) ? prefetch_index : index;
    assign L1_write_index = (state == PREFETCHit) ? prefetch_index : index;

    //hit dtect
    logic hit_way0, hit_way1, hit;
    logic is_word_access, is_halfword_access, is_byte_access, is_cacheable_access;

    assign is_word_access = (current_type_control == 2'b10);
    assign is_halfword_access = (current_type_control == 2'b01);
    assign is_byte_access = (current_type_control == 2'b00);

    //cacheable access depends on BYTE_BYPASS parameter so we can pass pdf test
    assign is_cacheable_access = BYTE_BYPASS ? (is_word_access || is_halfword_access) : (is_word_access || is_halfword_access || is_byte_access);

    assign hit_way0 = L1_valid_way0 && (L1_tag_way0 == tag) && is_cacheable_access;
    assign hit_way1 = L1_valid_way1 && (L1_tag_way1 == tag) && is_cacheable_access;
    assign hit = hit_way0 || hit_way1;

    logic victim_way;
    logic evict_dirty;
    logic prefetch_hit_way0, prefetch_hit_way1, prefetch_hit;
    logic prefetch_victim_way;
    logic prefetch_evict_dirty;

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

        //prefetch hit detection
        prefetch_hit_way0 = L1_valid_way0 && (L1_tag_way0 == prefetch_tag);
        prefetch_hit_way1 = L1_valid_way1 && (L1_tag_way1 == prefetch_tag);
        prefetch_hit = prefetch_hit_way0 || prefetch_hit_way1;

        // prefetch victim selection
        if (!L1_valid_way0)
            prefetch_victim_way = 1'b0;
        else if (!L1_valid_way1)
            prefetch_victim_way = 1'b1;
        else
            prefetch_victim_way = L1_lru_bit;

        //prefetch eviction check
        prefetch_evict_dirty = (prefetch_victim_way == 1'b0) ?
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

    //stall genrator
    always_comb begin
        next_state = state;
        stall = 1'b0;
        prefetch_needed = 1'b0;

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

            ALLOCit:begin
                //after allocating the missed line, prefetch next line if not already present
                if (!prefetch_hit && !prefetch_evict_dirty) begin
                    next_state = PREFETCHit;
                    prefetch_needed = 1'b1;
                    stall = 1'b1;  //complete allocation cycle
                end else begin
                    next_state = IDLE;
                    stall = 1'b1;
                end
            end

            PREFETCHit: begin
                next_state = IDLE;
                stall = 1'b0;  //prefetch doesn't stall CPU
            end

            default: next_state = IDLE;
        endcase
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

    always_comb begin
        write_to_mem = 1'b0;
        write_addr = current_addr;
        write_data = current_din;
        write_type = current_type_control;

        case (state)
            IDLE: begin
                if (BYTE_BYPASS && is_byte_access && current_write_en) begin
                    write_to_mem = 1'b1;
                end
            end

            WRITEitBack: begin
                write_to_mem = 1'b1;
                write_addr= {victim_tag, index, 2'b00};
                write_data = victim_data;
                write_type = 2'b10;
            end

            ALLOCit: begin
                write_to_mem = 1'b0;
            end

            PREFETCHit: begin
                write_to_mem = 1'b0;
            end

            default: begin
                write_to_mem = 1'b0;
            end
        endcase
    end

    assign mem_write_en = write_to_mem;
    assign mem_type_control = write_type;
    //for prefetch, read next line address
    assign mem_addr = (state == PREFETCHit) ? {prefetch_tag, prefetch_index, 2'b00} :
                      (write_to_mem ? write_addr : current_addr);
    assign mem_din = write_to_mem ? write_data : current_din;
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

    always_comb begin
        if (hit && !current_write_en) begin
            dout = extracted_read_data ;
        end else begin
            dout = mem_dout;
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

    // L1 write control logic
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

        if (is_cacheable_access && current_write_en && state == IDLE) begin
            if (hit_way0) begin
                L1_write_en_way0 = 1'b1;
                L1_write_data_way0 = merged_cache_data;
                L1_write_tag_way0 = tag;
                L1_write_valid_way0 = 1'b1;
                L1_write_dirty_way0 = 1'b1;
                L1_write_lru = 1'b1;
                L1_lru_value = 1'b1;  //way1 now Lru
            end else if (hit_way1) begin

                L1_write_en_way1 = 1'b1;
                L1_write_data_way1 = merged_cache_data;
                L1_write_tag_way1 = tag;
                L1_write_valid_way1 = 1'b1;
                L1_write_dirty_way1 = 1'b1;
                L1_write_lru = 1'b1;
                L1_lru_value = 1'b0;  //lru is way0
            end
            // Clean miss writes removed - handled in ALLOCit state
        end else if (is_cacheable_access && !current_write_en && state == IDLE) begin
            if (hit_way0) begin
                L1_write_lru = 1'b1;
                L1_lru_value = 1'b1;
            end else if (hit_way1) begin
                L1_write_lru = 1'b1;
                L1_lru_value = 1'b0 ;
            end
            // Clean miss writes removed - handled in ALLOCit state
        end else if (is_cacheable_access && state == ALLOCit) begin
            //alloc line aftr wb
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
        end else if (state == PREFETCHit && prefetch_needed) begin
            //prefetch: allocate next line if not present, mark as clean (not dirty)
            if (prefetch_victim_way == 1'b0) begin
                L1_write_en_way0 = 1'b1;
                L1_write_data_way0 = mem_dout;
                L1_write_tag_way0 = prefetch_tag;
                L1_write_dirty_way0 = 1'b0;  //prefetched data is clean
            end else begin
                L1_write_en_way1 = 1'b1;
                L1_write_data_way1 = mem_dout;
                L1_write_tag_way1 = prefetch_tag;
                L1_write_dirty_way1 = 1'b0;  //prefetched data is clean
            end
            L1_write_lru = 1'b1;
            L1_lru_value = ~prefetch_victim_way;
        end
    end

endmodule
