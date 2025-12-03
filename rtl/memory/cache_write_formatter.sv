// merges 32-bit CPU write into 128-bit cache line based on offset and type
module cache_write_formatter (
    input  logic [127:0] line_in,      // original cache line
    input  logic [3:0]   offset,       // offset within line
    input  logic [1:0]   size_type,   //  00=byte, 01=half, 10=word
    input  logic [31:0]  wdata,
    input  logic         write_en,
    output logic [127:0] line_out  // updated c line
);

    logic [31:0] word0, word1, word2, word3;
    assign word0 = line_in[31:0];
    assign word1 = line_in[63:32] ;
    assign word2 = line_in[95:64];
    assign word3 = line_in[127:96];

    logic [31:0] new_word0, new_word1, new_word2, new_word3;

    // read-modify-write logic for byte/half/word stores
    always_comb begin
        // default, just pass through unchanged
        new_word0 = word0;
        new_word1 = word1;
        new_word2 = word2;
        new_word3 = word3 ;

        if (write_en) begin
            // mux1 select which word to modify
            case(offset[3:2])
                2'b00: begin // modify word0
                    case(size_type)
                        // byte write
                        2'b00: begin 
                            // inner mux selects which byte to update
                            case(offset[1:0])
                                2'b00: new_word0 = {word0[31:8],  wdata[7:0]};
                                2'b01: new_word0 = {word0[31:16], wdata[7:0], word0[7:0]};
                                2'b10: new_word0 = {word0[31:24], wdata[7:0], word0[15:0]};
                                2'b11: new_word0 = {wdata[7:0],   word0[23:0]};
                            endcase
                        end
                        // half write
                        2'b01: begin 
                            // inner mux selects upper or lower half
                            case(offset[1])
                                1'b0: new_word0 = {word0[31:16], wdata[15:0]};
                                1'b1: new_word0 = {wdata[15:0],  word0[15:0]};
                            endcase
                        end
                        // word write
                        2'b10: new_word0 = wdata; 
                        default: new_word0 = word0;
                    endcase
                end

                2'b01: begin //modify word1
                    case(size_type )
                        // byte write
                        2'b00: begin 
                            case(offset[1:0])
                                2'b00: new_word1 = {word1[31:8],  wdata[7:0]};
                                2'b01: new_word1 = {word1[31:16], wdata[7:0], word1[7:0]};
                                2'b10: new_word1 = {word1[31:24], wdata[7:0], word1[15:0]};
                                2'b11: new_word1 = {wdata[7:0],   word1[23:0]};
                            endcase
                        end
                        //half write
                        2'b01: begin 
                            case(offset[1])
                                1'b0: new_word1 = {word1[31:16], wdata[15:0]};
                                1'b1: new_word1 = {wdata[15:0],  word1[15:0]};
                            endcase
                        end
                        // word write
                        2'b10: new_word1 = wdata;
                        default: new_word1 = word1;
                    endcase
                end

                2'b10: begin // modify word2
                    case(size_type)
                        // byte write
                        2'b00: begin 
                            case(offset[1:0])
                                2'b00: new_word2 = {word2[31:8],  wdata[7:0]};
                                2'b01: new_word2 = {word2[31:16], wdata[7:0], word2[7:0]};
                                2'b10: new_word2 = {word2[31:24], wdata[7:0], word2[15:0]};
                                2'b11: new_word2 = {wdata[7:0],   word2[23:0]};
                            endcase
                        end
                        // half write
                        2'b01: begin 
                            case(offset[1])
                                1'b0: new_word2 = {word2[31:16], wdata[15:0]};
                                1'b1: new_word2 = {wdata[15:0],  word2[15:0]};
                            endcase
                        end
                        // word write
                        2'b10: new_word2 = wdata;
                        default: new_word2 =   word2;
                    endcase
                end

                2'b11: begin // modify word3
                    case(size_type)
                        // byte write
                        2'b00: begin 
                            case(offset[1:0])
                                2'b00: new_word3  = {word3[31:8],  wdata[7:0]};
                                2'b01: new_word3 = {word3[31:16], wdata[7:0], word3[7:0]};
                                2'b10: new_word3 = {word3[31:24], wdata[7:0], word3[15:0]};
                                2'b11: new_word3 = {wdata[7:0],   word3[23:0]};
                            endcase
                        end
                        // half write
                        2'b01: begin 
                            case(offset[1])
                                1'b0: new_word3 = {word3[31:16], wdata[15:0]};
                                1'b1: new_word3 = {wdata[15:0],  word3[15:0]};
                            endcase
                        end
                        // word write
                        2'b10:  new_word3 = wdata;
                        default: new_word3 = word3;
                    endcase
                end
            endcase
        end
    end

    // put togther output line
    assign line_out = {new_word3, new_word2, new_word1, new_word0};

endmodule
