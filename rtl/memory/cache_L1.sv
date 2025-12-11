module cache_L1 #(
    parameter NUM_SETS = 512,
    parameter LINE_WIDTH = 32,
    parameter TAG_BITS = 21,
    parameter INDEX_BITS = 9
)(
    input logic clk,
    input logic rst,

    //read
    input logic [INDEX_BITS-1:0] read_index,
    output logic [LINE_WIDTH-1:0] data_way0,
    output logic [LINE_WIDTH-1:0] data_way1,
    output logic [TAG_BITS-1:0] tag_way0,
    output logic [TAG_BITS-1:0] tag_way1,
    output logic valid_way0,
    output logic valid_way1,
    output logic dirty_way0,
    output logic dirty_way1,
    output logic lru_bit,

    // write
    input logic write_en_way0,
    input logic write_en_way1,
    input logic [INDEX_BITS-1:0] write_index,
    input logic [LINE_WIDTH-1:0] write_data_way0,
    input logic [LINE_WIDTH-1:0] write_data_way1,
    input logic [TAG_BITS-1:0] write_tag_way0,
    input logic [TAG_BITS-1:0] write_tag_way1,
    input logic write_valid_way0,
    input logic write_valid_way1,
    input logic write_dirty_way0,
    input logic write_dirty_way1,
    input logic write_lru,
    input logic lru_value
);

    logic [LINE_WIDTH-1:0] cache_data [1:0][NUM_SETS-1:0];
    logic [TAG_BITS-1:0] cache_tags [1:0][NUM_SETS-1:0];
    logic cache_valid [1:0][NUM_SETS-1:0];
    logic cache_dirty [1:0][NUM_SETS-1:0];
    logic lru_bits [NUM_SETS-1:0];

    // continuous read combi
    assign data_way0 = cache_data[0][read_index];
    assign data_way1 = cache_data[1][read_index];
    assign tag_way0 = cache_tags[0][read_index];
    assign tag_way1 = cache_tags[1][read_index];
    assign valid_way0 = cache_valid[0][read_index];
    assign valid_way1 = cache_valid[1][read_index];
    assign dirty_way0 = cache_dirty[0][read_index];
    assign dirty_way1 = cache_dirty[1][read_index];
    assign lru_bit = lru_bits[read_index];


    integer i, w;
    initial begin
        for (w = 0; w < 2; w = w + 1) begin
            for (i = 0; i < NUM_SETS; i = i + 1) begin
                cache_valid[w][i] = 1'b0;
                cache_dirty[w][i] = 1'b0;
                cache_tags[w][i] = '0;
                cache_data[w][i] = '0;
            end
        end
        for (i = 0; i < NUM_SETS; i = i + 1) begin
            lru_bits[i] = 1'b0;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            //rst ahndle dby itnial block
        end else begin
            if (write_en_way0) begin
                cache_data[0][write_index] <= write_data_way0;
                cache_tags[0][write_index] <= write_tag_way0;
                cache_valid[0][write_index] <= write_valid_way0;
                cache_dirty[0][write_index] <= write_dirty_way0;
            end

            // way1 update
            if (write_en_way1) begin
                cache_data[1][write_index] <= write_data_way1;
                cache_tags[1][write_index] <= write_tag_way1;
                cache_valid[1][write_index] <= write_valid_way1;
                cache_dirty[1][write_index] <= write_dirty_way1;
            end

            //lru udpate
            if (write_lru) begin
                lru_bits[write_index] <= lru_value;
            end
        end
    end

endmodule
