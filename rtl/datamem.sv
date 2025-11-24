typedef enum logic [1:0] {
    b = 2'b00,
    half = 2'b01,
    word = 2'b10
} rw_type;

module datamem #(parameter mem_size = 512)(
    input clk,
    input write_en,

    input rw_type type_control,

    input logic [31:0] addr,

    input logic [31:0] din,

    input logic sign_ext,

    output logic [31:0] dout

);

//memsize seems small / wrong 
//0x00000000 – 0x00001FFF  ; see memory map (128 KB)?? 

 logic [7:0] memory [mem_size - 1:0];

//bounds chhecking and byte alignment have been considered.
always_ff @(posedge clk) begin

    if(write_en) begin
        case(type_control)
        
            b: memory[addr] <= din[7:0];
            
            half: begin
                memory[addr] <= din[7:0];
                memory[addr+1] <= din[15:8];
            end
            
            word: begin
                memory[addr] <= din[7:0];
                memory[addr+1] <= din[15:8];
                memory[addr+2] <= din[23:16];
                memory[addr+3] <= din[31:24];
            end

        endcase
    end




end


always_comb begin
    case(type_control)
    
        b: begin
            dout = {24{sign_ext & memory[addr][7]},memory[addr]};
        end
        half: begin
            dout = {16{sign_ext & memory[addr+1][7]},memory[addr+1],memory[addr]};           
        end
        
        word: begin
            dout = {memory[addr+3],memory[addr+2],memory[addr+1],memory[addr]}; 
        end

        default: dout = 32'b0;
    endcase


end








endmodule