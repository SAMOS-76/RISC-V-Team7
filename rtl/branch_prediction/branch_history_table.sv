module branch_history_table #(
    parameter INDEX_BITS = 4  
)(
    input  logic        clk,
    input  logic        rst,
    
    // Fetch signals
    input  logic [31:0] PC_F,
    output logic        predict_taken_F,
    
    // Exectue signals
    input  logic        update_en,      
    input  logic [31:0] PC_E,           
    input  logic        branch_taken_E  
);

    // State encoding
    typedef enum logic [1:0] {
        SNT = 2'b00, // Strongly not taken
        WNT = 2'b01, // Weakly not taken
        WT  = 2'b10, // Weakly taken
        ST  = 2'b11  // Strongly taken
    } state_t;

    // BHT storage
    logic [1:0] bht [2**INDEX_BITS-1:0];
    
    logic [INDEX_BITS-1:0] index_F;
    logic [INDEX_BITS-1:0] index_E;

    always_comb begin
       index_F = PC_F[INDEX_BITS+1:2]; // No lsb because of +4
       index_E = PC_E[INDEX_BITS+1:2]; 

       predict_taken_F = bht[index_F][1];
    end
    
    always_ff @(posedge clk) begin

        if (rst) begin
            // Initialize to WNT
            for (int i = 0; i < 2**INDEX_BITS; i++) begin
                bht[i] = WNT;
            end
        end

        else if (update_en) begin
            case (bht[index_E])
                SNT: bht[index_E] <= branch_taken_E ? WNT : SNT;  
                WNT: bht[index_E] <= branch_taken_E ? WT  : SNT;  
                WT:  bht[index_E] <= branch_taken_E ? ST  : WNT;  
                ST:  bht[index_E] <= branch_taken_E ? ST  : WT;
                default: bht[index_E] <= WNT;
            endcase
        end
    end

endmodule


