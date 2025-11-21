module control_unit (
    input  logic [31:0] instr,
    input  logic        alu_zero,     // ALU signal for if the result is 0
    input  logic        alu_result_0, // LSB of ALU result
    
    // Original signals
    output logic [3:0]  ALUControl,
    output logic        ALUSrc,       
    output logic        MemWrite,     
    output logic        RegWrite,     
    output logic [1:0]  ResultSrc,  
    output logic [2:0]  ImmSrc,

    output logic [1:0]  memSize,      // Memory access size
    output logic        memUnsigned,  // Unsigned load flag
    output logic        Branch,       // Branch instruction flag
    output logic        Jump,         // Jump instruction flag
    output logic [2:0]  branchType,   // BEQ,BGT
    output logic        PCSrc         // PC source
);

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic       funct7_5;  // Only need bit 5 of funct7

    assign opcode   = instr[6:0];
    assign funct3   = instr[14:12];
    assign funct7   = instr[31:25];
    assign funct7_5 = instr[30];

    logic [1:0] aluOp;
    logic branch_taken;

    always_comb begin
        RegWrite    = 1'b0;    // Reg write enable
        ResultSrc   = 2'b00;   // ALU or Mem or PC+4 to register
        ALUSrc      = 1'b0;    // Reg or imm values
        MemWrite    = 1'b0;    // Mem write enable
        memSize     = 2'b10;   // byte or half word or word (word by default)
        memUnsigned = 1'b0;    // Default is signed integer
        ImmSrc      = 3'b000;  // Format of imm value depending on insr type
        Branch      = 1'b0;    // Branch flag
        Jump        = 1'b0;    // Jump flag
        branchType  = 3'b000;  // Type of branch BEQ BGT etc.
        aluOp       = 2'b00;   // Intermediate signal decoded later

        case (opcode)
            7'b0110011: begin  // R type
                RegWrite  = 1'b1;
                ResultSrc = 2'b00;  // ALU result
                ALUSrc    = 1'b0;   // Use reg values
                aluOp     = 2'b10;
            end

            7'b1100011: begin  // B type (Branches)
                Branch     = 1'b1;      // Branch flag set HIGH
                ALUSrc     = 1'b0;      
                ImmSrc     = 3'b010;    // B-type imm
                aluOp      = 2'b01;
                branchType = funct3;    // Used by comparator
            end

            7'b0000011: begin //I type (Load instructions)
                RegWrite  = 1'b1;
                ResultSrc = 2'b01;
                ALUSrc    = 1'b1;

                case(funct3)
                    3'b000: memSize = 2'b00;
                    3'b001: memSize = 2'b01;
                    3'b010: memSize = 2'b10;

                    3'b100: begin // load byte unsigned
                        memSize     = 2'b00;
                        memUnsigned = 1'b1;
                    end

                    3'b101: begin // load half unsigned
                        memSize     = 2'b01;
                        memUnsigned = 1'b1;
                    end
                endcase
            end

            7'b0010011: begin // I type (ALU)
                RegWrite  = 1'b1;
                ResultSrc = 2'b00;
                ALUSrc    = 1'b1;
                ImmSrc    = 3'b000;
                aluOp     = 2'b10;
            end

            7'b0100011: begin // S type (store instruction)
                ImmSrc    = 3'b001;
                MemWrite  = 1'b1;
                ALUSrc    = 1'b1;

                case(funct3)
                    3'b000: memSize = 2'b00;
                    3'b001: memSize = 2'b01;
                    3'b010: memSize = 2'b10;
                endcase
            end

            7'b0010111: begin // U type (add upper immediate to PC)
                ImmSrc   = 3'b100;
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
            end

            7'b0110111: begin // Load upper immediate
                RegWrite  = 1'b1;    
                ResultSrc = 2'b00;   
                ALUSrc    = 1'b1;    
                ImmSrc    = 3'b011;  
                aluOp     = 2'b00;
            end

            7'b1100111: begin // I type jump
                RegWrite  = 1'b1;
                ResultSrc = 2'b10;
                ALUSrc    = 1'b1;     
                Jump      = 1'b1;    
            end

            7'b1101111: begin // JAL
                RegWrite  = 1'b1;    // Write return address to rd
                ResultSrc = 2'b10;   // PC+4 goes to register
                ImmSrc    = 3'b100;  // J-type immediate
                Jump      = 1'b1;   
            end
        endcase
    end

    // More decode blocks related to ALU signals.
    alu_decoder alu_dec (
        .aluOp(aluOp),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .opcode(opcode),
        .aluControl(ALUControl)
    );

    branch_comparator branch_comp (
        .zero(alu_zero),
        .alu_result_0(alu_result_0),
        .branchType(branchType),
        .Branch(Branch),
        .branch_taken(branch_taken)
    );

    assign PCSrc = Jump | (Branch & branch_taken);

endmodule