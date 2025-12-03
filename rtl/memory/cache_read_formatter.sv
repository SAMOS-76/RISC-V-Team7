// extracts 32-bit data from 128-bit cache line based on offset and type
module cache_read_formatter (
    input  logic [127:0] line_in,      // 16-byte cache line
    input  logic [3:0]   offset,       // offset within line (0-15)
    input  logic [1:0]   size_type,    // 00=byte, 01=half, 10=word
    input  logic         sign_ext,
    output logic [31:0]  data_out
);

    logic [31:0] word0, word1, word2, word3 ;
    assign word0 = line_in[31:0];
    assign word1 = line_in[63:32];
    assign word2 = line_in[95:64];
    assign word3 = line_in[127:96];

    //mux1 : word select
    logic [31:0] selected_word;
    always_comb begin
        case(offset[3:2])
            2'b00: selected_word = word0;
            2'b01: selected_word = word1;
            2'b10: selected_word = word2;
            2'b11: selected_word = word3;
        endcase
    end

    // mux 2 : sub word selct nd sign ext
    always_comb begin
        case(size_type)
            //byte
            2'b00: begin 
                // inner mux selects what byte
                case(offset[1:0])
                    2'b00: data_out = {{24{sign_ext & selected_word[7]}},  selected_word[7:0]};
                    2'b01: data_out = {{24{sign_ext & selected_word[15]}}, selected_word[15:8]};
                    2'b10: data_out = {{24{sign_ext & selected_word[23]}}, selected_word[23:16]};
                    2'b11: data_out = {{24{sign_ext & selected_word[31]}}, selected_word[31:24]};
                endcase
            end
            
            //half
            2'b01: begin 
                // inside mux slct upper or lwoer half
                case(offset[1])
                    1'b0: data_out = {{16{sign_ext & selected_word[15]}}, selected_word[15:0]};
                    1'b1: data_out = {{16{sign_ext & selected_word[31]}}, selected_word[31:16]};
                endcase
            end
            
            //word
            2'b10: begin 
                //pass the full thing ofc
                data_out  = selected_word;
            end
            
            default: data_out = 32'b0;
        endcase
    end

endmodule
