module cache_sram (
    input  logic         clk,
    input  logic [6:0]   set_index,
    input  logic         write_en,
    input  logic [302:0] wdata,  // [LRU:1][Way1:151][Way0:151]
    output logic [302:0] rdata
);
    //decided on
    // 128 sets
    // width Breakdown: 
    // 1 bit, LRU
    // + 2 Ways x (1(Valid) + 1(Dirty) + 21(Tag) + 128(Data)) 
    // = 1 + 2 * 151 = 303 bits
    
    logic [302:0] ram [0:127];

    //init to 0 (valid bits = 0)
    initial begin
        for (int i = 0; i < 128; i++) begin
            ram[i] = '0;
        end
    end

    //sync Write
    always_ff @(posedge clk) begin
        if (write_en) begin
            ram[ set_index] <= wdata;
        end
    end

    // async read
    assign rdata = ram[set_index];

endmodule
