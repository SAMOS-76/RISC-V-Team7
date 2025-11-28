module alu_decoder(
    input  logic [1:0] aluOp,
    input  logic [2:0] funct3,
    input  logic       funct7_5,
    input  logic [6:0] opcode,        
    output logic [3:0] aluControl
);
    always_comb begin
        case (aluOp)
            2'b00: aluControl = 4'b0000;  // add
            
            2'b01: begin  // Branch operations
                case (funct3)
                    3'b000, 3'b001: aluControl = 4'b1000;  // BEQ/BNE
                    3'b100, 3'b101: aluControl = 4'b0010;  // BLT/BGE
                    3'b110, 3'b111: aluControl = 4'b0011;  // BLTU/BGEU
                    default: aluControl = 4'b1000;
                endcase
            end
            
            2'b10: begin  // R & I Type
                case (funct3)
                    3'b000: begin
                        if (opcode == 7'b0110011 && funct7_5)
                            aluControl = 4'b1000;  // SUB (R-type - normal)
                        else
                            aluControl = 4'b0000;  // ADD/ADDI
                    end
                    
                    3'b001: aluControl = 4'b0001;  // SLL/SLLI
                    
                    3'b010: aluControl = 4'b0010;  // SLT/SLTI
                    
                    3'b011: aluControl = 4'b0011;  // SLTU/SLTIU
                    
                    3'b100: aluControl = 4'b0100;  // XOR/XORI
                    
                    3'b101: begin
                        // SRL/SRLI or SRA/SRAI
                        if (funct7_5)
                            aluControl = 4'b1101;  // SRA/SRAI
                        else
                            aluControl = 4'b0101;  // SRL/SRLI
                    end
                    
                    3'b110: aluControl = 4'b0110;  // OR/ORI
                    
                    3'b111: aluControl = 4'b0111;  // AND/ANDI
                    
                    default: aluControl = 4'b0000;
                endcase
            end
            
            default: aluControl = 4'b0000;
        endcase
    end
endmodule
