typedef enum logic [1:0] {
    b = 2'b00,
    half = 2'b01,
    word = 2'b11
} rw_type;

module datamem #(parameter mem_size = 512)(
    input clk,
    input write_en,

    input rw_type type_control,

    input logic [31:0] write_addr,
    input logic [31:0] read_addr,

    input logic [31:0] din,

    output logic [31:0] dout

);


 logic [7:0] memory [mem_size - 1:0];


always_ff @(posedge clk) begin

    if(write_en) begin
        case(type_control)
        
            b: memory[write_addr] <= din[7:0];
            
            half: begin
                memory[write_addr] <= din[7:0];
                memory[write_addr+1] <= din[15:8];
            end
            
            word: begin
                memory[write_addr] <= din[7:0];
                memory[write_addr+1] <= din[15:8];
                memory[write_addr+2] <= din[23:16];
                memory[write_addr+3] <= din[31:24];
            end
        endcase
    end


end


always_comb begin

    case(type_control)
    
        b: dout = {24'b0,memory[read_addr]};
        
        half: begin
            
            dout = {16'b0,memory[read_addr+1],memory[read_addr]};
        end
        
        word: begin
            dout = {memory[read_addr+3],memory[read_addr+2],memory[read_addr+1],memory[read_addr]};
            
            
            
        end
    endcase




end



endmodule