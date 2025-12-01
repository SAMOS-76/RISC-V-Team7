typedef enum logic [1:0] {
    b    = 2'b00,
    half = 2'b01,
    word = 2'b10
} rw_type;

module datamem #(
    parameter MEM_SIZE = 32'h20000,
    parameter MEM_LATENCY = 1
)(
    input clk,
    input rst,
    
    // word interface
    input write_en,
    input rw_type type_control,
    input logic [31:0] addr,
    input logic [31:0] din,
    input logic sign_ext,
    output logic [31:0] dout,

    //  block interface
    input  logic        block_read,
    input  logic        block_write,
    input  logic [31:0] block_addr,
    input  logic [127:0] block_din,
    output logic [127:0] block_dout,
    output logic        block_ready
);

    logic [7:0] memory [MEM_SIZE-1:0];

    initial begin
        $readmemh("data.hex", memory, 32'h00010000);
    end

    always_ff @(posedge clk) begin
        if(write_en) begin
            case(type_control)
                b: memory[addr] <= din[7:0];
                
                half: begin
                    memory[addr]   <= din[7:0];
                    memory[addr+1] <= din[15:8];
                end
                
                word: begin
                    memory[addr]   <= din[7:0];
                    memory[addr+1] <= din[15:8];
                    memory[addr+2] <= din[23:16];
                    memory[addr+3] <= din[31:24];
                end

                default: ;
            endcase
        end
    end

    always_comb begin
        case(type_control)
            b: begin
                dout = {{24{sign_ext & memory[addr][7]}}, memory[addr]};
            end
            
            half: begin
                dout = {{16{sign_ext & memory[addr+1][7]}}, memory[addr+1], memory[addr]};           
            end
            
            word: begin
                dout = {memory[addr+3], memory[addr+2], memory[addr+1], memory[addr]}; 
            end

            default: dout = 32'b0;
        endcase
    end

    
    //new block interface
    logic [3:0] latency_counter;
    logic       mem_busy;
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            latency_counter <= 4'b0;
            mem_busy        <= 1'b0;
            block_ready     <= 1'b0;
            block_dout      <= 128'b0;
        end
        else begin
            block_ready <= 1'b0;
            
            if ((block_read || block_write) && !mem_busy) begin
                mem_busy        <= 1'b1;
                latency_counter <= MEM_LATENCY - 1;
            end
            else if (mem_busy) begin
                if (latency_counter == 0) begin
                    mem_busy    <= 1'b0;
                    block_ready <= 1'b1;
                    
                    if (block_read) begin
                        // Read block (4 words = 16 bytes)
                        block_dout[31:0]   <= {memory[block_addr+3],  memory[block_addr+2],  memory[block_addr+1],  memory[block_addr+0]};
                        block_dout[63:32]  <= {memory[block_addr+7],  memory[block_addr+6],  memory[block_addr+5],  memory[block_addr+4]};
                        block_dout[95:64]  <= {memory[block_addr+11], memory[block_addr+10], memory[block_addr+9],  memory[block_addr+8]};
                        block_dout[127:96] <= {memory[block_addr+15], memory[block_addr+14], memory[block_addr+13], memory[block_addr+12]};
                    end
                    else if (block_write) begin
                        // Write block (4 words = 16 bytes)
                        memory[block_addr+0]  <= block_din[7:0];
                        memory[block_addr+1]  <= block_din[15:8];
                        memory[block_addr+2]  <= block_din[23:16];
                        memory[block_addr+3]  <= block_din[31:24];
                        memory[block_addr+4]  <= block_din[39:32];
                        memory[block_addr+5]  <= block_din[47:40];
                        memory[block_addr+6]  <= block_din[55:48];
                        memory[block_addr+7]  <= block_din[63:56];
                        memory[block_addr+8]  <= block_din[71:64];
                        memory[block_addr+9]  <= block_din[79:72];
                        memory[block_addr+10] <= block_din[87:80];
                        memory[block_addr+11] <= block_din[95:88];
                        memory[block_addr+12] <= block_din[103:96];
                        memory[block_addr+13] <= block_din[111:104];
                        memory[block_addr+14] <= block_din[119:112];
                        memory[block_addr+15] <= block_din[127:120];
                    end
                end
                else begin
                    latency_counter <= latency_counter - 1;
                end
            end
        end
    end

endmodule
