typedef enum logic [1:0] {
    b    = 2'b00,
    half = 2'b01,
    word = 2'b10
} rw_type;

module datamem #(parameter mem_size = 32'h20000)(
    input clk,
    input write_en,

    input rw_type type_control,

    input logic [31:0] addr,
    input logic [31:0] din,

    input logic sign_ext,

    output logic [31:0] dout

);

 logic [7:0] memory [mem_size-1:0];

initial begin
    $readmemh("data.hex", memory, 32'h00010000);
end


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

            default: ;

            endcase
        end

        // READ - creates 1cycle latency but infers BRAM
        case(type_control)
            b:    dout <= {{24{sign_ext & memory[addr][7]}},  memory[addr]} ;
            half: dout <= {{16{sign_ext & memory[addr+1][7]}}, memory[addr+1], memory[addr]};
            word: dout <= {memory[addr+3], memory[addr+2], memory[addr+1], memory[addr]};
            default: dout <= 32'b0;
        endcase
    end

endmodule
