# Samuel Amos-Osebeyo's Personal Statement

***Samuel Amos-Osebeyo (SAMOS-76)***

This document provides a comprehensive overview of my contributions to the RISC-V Team7 project.  It outlines the work completed, the design methodologies employed, the challenges encountered and how they were resolved and the key learnings from this experience.

---

## Overview
- [Single-Cycle CPU Implementation](#single-cycle-cpu-implementation)
  - [Program Counter and Top-Level Architecture](#program-counter-and-top-level-architecture)
  - [F1 Testing](#F1-Testing)
- [Pipelined CPU Implementation](#pipelined-cpu-implementation)
  - [Division Unit - Multi-Cycle Implementation](#division-unit---multi-cycle-implementation)
  - [RV32M Extension in Pipelined Architecture](#rv32m-extension-in-pipelined-architecture)
- [Learnings and Project Summary](#learnings-and-project-summary)

---

# Single-Cycle CPU Implementation

## Program Counter and Top-Level Architecture

[Program Counter Module](https://github.com/SAMOS-76/RISC-V-Team7/blob/single-cycle-multiplication/rtl/fetch/pc_reg.sv) | [Top Level Module](https://github.com/SAMOS-76/RISC-V-Team7/blob/single-cycle-multiplication/rtl/top.sv) | [Supporting Components]([../rtl/](https://github.com/SAMOS-76/RISC-V-Team7/tree/single-cycle-multiplication/rtl))

In the Single-Cycle CPU, I was mainly in charge of implementing all of the top level components, creating the program counter and other top level components, and putting it all together in an intuitive way in the top layer splitting the modules into fetch, decode, and execute.

[Relevant Commits: Creating top level components](https://github.com/SAMOS-76/RISC-V-Team7/commit/7e6b55f1d9ca81e779cba3783e78b7f22bdf5ed7)

### Implementation
#### Top-Level Architecture Components

Created a hierarchical processor structure with the following key modules:

**Program Counter Module** (`pc.sv`):
- 32-bit register storing current instruction address
- Synchronous updates on positive clock edges  
- Multiplexer selects next PC value based on PCSrc control signal

**Adder Module** (`adder.sv`):
- Implements PC + 4 calculation for sequential instruction fetch
- Also supports branch offset addition (PC + immediate)

**Multiplexer** (`mux4.sv`):
- Used for selecting specific inputs into ALU: 

**Fetch Stage** (`fetch_top.sv`):
- Retrieves instructions from instruction memory based on current PC
- Outputs instruction and provides updated PC for next cycle
- Works in conjunction with PC module for proper sequencing

**Decode Stage** (`decode_top.sv`):
- Decodes instruction opcode and function fields
- Performs immediate sign extension for all instruction formats
- Reads operands from register file
- Routes control signals to execute stage

**Execute Stage** (`execute_top.sv`):
- Performs arithmetic and logical operations via ALU
- Evaluates branch conditions
- Computes addresses for memory operations
- Generates results for write-back

**Top-Level Integration** (`top.sv`):
- Coordinates signal routing between all stages
- Manages control signal propagation
- Implements stall and flush logic for hazard handling
- Connects memory subsystems (instruction and data memory)

---
[Relevant Commits: Implementing structure](https://github.com/SAMOS-76/RISC-V-Team7/commit/c5c940690dcef94d10ab96749835a06c019e6db2)

## F1 Testing

[F1 Assembly - Standard](../tb/asm/f1_fsm.s) | [F1 Assembly - Complex](../tb/asm/f1_complex.s) | [F1 Testbench](../tb/vbuddy_test/f1_tb.cpp) | [F1 Test Script](../tb/f1.sh)

Worked with Louis to create an initial basic F1 script taht simply counted up the lights. After this, I worked on creating a more complex one using random delays using shifts and polynomials. Additonally created the tb and bash scripts to run and test.


### Implementation

#### Standard F1 Implementation
[Relevant Commits: Simple F1](https://github.com/SAMOS-76/RISC-V-Team7/commit/d1998e446806f2082b24badcfc069df31cd8bf36)
Designed a basic 9-state finite state machine (S_0 through S_8) with the following characteristics:

**State Structure**:
```assembly
S_0: No LEDs lit
S_1-S_7: Progressive LED lighting 
S_8: All LEDs lit
```

**Fixed Timing**:
- Initially realised the script just ran as fast as possible so implemented delays of 10 clock cycles between each light in the more complex example
```assembly
delay:
    li      t3, 10
delay_loop:
    addi    t3, t3, -1
    bnez    t3, delay_loop
    RET
```

#### Complex F1 with Pseudo-Random Delays

Extended the basic F1 script by implementing psuedo-randomness using polynomials. In this implementation, we turned on the lights at a fixed delay of every 10 cycles. Once fully lit, a random delay is used to then turn them off and start the loop again.

**LFSR-Based Random Delay Generation**: 
Implemented a Linear Feedback Shift Register (LFSR) for pseudo-random number generation:
- Initially set the starting value of the LSFR to 1
- We shift the value a specific amount to get our bit we want to use for our polynomial
- Tested different polynomials to see how they changed to delays

**Delay Application Logic**:
```assembly
loop:   #loops until t0 = 8 (light sequence complete)
    bge     t0, t1, lights_out    
    jal     ra, delay
    jal     ra, increase       
    addi    t0, t0, 1
    j       loop
```
- We loop until we get to state 8 then we enter our random delay loop

```assembly
lights_out:
    beqz     s0, add_one

    srli    t4, s0, 8
    andi    t4, t4, 1
    srli    t5, s0, 4
    andi    t5, t5, 1
    xor     t6, t4, t5
    slli    s0, s0, 1
    or      s0, s0, t6
    andi    s0, s0, 0x1FF

    bnez    s0, last_delay
    li      s0, 1
```
- Here I've implemented the random generator which essentially stores a psuedo-random value into our delay register

```assembly
last_delay:
    mv      t3, s0
    jal     ra, random_delay

    li      a0, 0
    jal     ra, delay
    j       main

random_delay:
    addi t3, t3, -1
    bnez t3, random_delay
```

- This is the logic for the last delay
- Keeps looping until the number of delay cycles is finished and it turns off
- Loops and starts again

#### VBuddy Integration and Testing Infrastructure

 - Created the testbench and bash file to run and test the f1 scripts 
[Relevant Commits: F1 testbench and script](https://github.com/SAMOS-76/RISC-V-Team7/commit/296cbf9485e2521263aba59bff056a542fe236e2)
### Results

Successfully demonstrated F1 operation with:
- Progressing states S_0 to S_8 back to S_0
- Accurate LED lighting patterns
- Proper timing implementation for fixed delays
- Pseudo-random delay generation in complex version

---

# Pipelined CPU Implementation

My main goal with the Pipelined CPU was to further it's capabilities from a standard R32VI cpu to a R32VIM implementing additional single-cycle multiplication and multi-cycle division functionality. Additionally enhance hazard unit to encompass div stalls.

# Pipelined CPU Implementation with RV32M Extension

[ALU Top Module](../rtl/execute/ALU_top.sv) | [Hazard Unit](../rtl/hazard_unit.sv) | [Division Module](../rtl/execute/div.sv) | [Branch:    Pipeline-MUL-DIV](https://github.com/SAMOS-76/RISC-V-Team7/tree/Pipeline-MUL-DIV) | [Branch:  Pipeline-MUL-final](https://github.com/SAMOS-76/RISC-V-Team7/tree/Pipeline-MUL-final)

### Implementation

## Multiplication and Division Instructions

**RV32M Multiplication Operations**:  
- `MUL rd, rs1, rs2`: Lower 32 bits of 64-bit product
- `MULH rd, rs1, rs2`: Upper 32 bits of signed × signed
- `MULHSU rd, rs1, rs2`: Upper 32 bits of signed × unsigned
- `MULHU rd, rs1, rs2`: Upper 32 bits of unsigned × unsigned

**RV32M Division Operations**: 
- `DIV rd, rs1, rs2`: Signed division 
- `DIVU rd, rs1, rs2`: Unsigned division 
- `REM rd, rs1, rs2`: Signed remainder
- `REMU rd, rs1, rs2`: Unsigned remainder

**Instruction Encoding**:
All RV32M instructions use opcode `0110011` (R-type instruction) with funct7 = `0000001`

| Instruction | funct3 |
|-------------|--------|
| MUL         | 000    |
| MULH        | 001    |
| MULHSU      | 010    |
| MULHU       | 011    |
| DIV         | 100    |
| DIVU        | 101    |
| REM         | 110    |
| REMU        | 111    |

#### Control Unit for RV32M Instructions

For this to work the control unit was modified to include these new encodings. Additionally, it sets the is_div flag so the CPU knows a DIV instruction is going to stall the processor.
```systemverilog
7'b0110011: begin  // R type
                RegWrite  = 1'b1;
                ResultSrc = 2'b00;  // ALU result
                ALUSrcB   = 1'b0;   // Use reg values
                aluOp     = 2'b10;

                if (instr[31:25] == 7'b0000001) begin // For detecting RV32M instructions
                    aluOp = 2'b11;

                    case (funct3)
                        3'b100, 3'b101, 3'b110, 3'b111: begin
                            is_div = 1'b1;
                        end
                        default: begin
                            is_div = 1'b0;
                        end
                    endcase
                end
            end
```
#### ALU Decoder for RV32M Instructions

Modified the ALU decoder to decode multiplication, division, and remainder operations.

```systemverilog
2'b11:begin
    case (funct3)
        3'b000: aluControl = 4'b1010; // MUL
        3'b001: aluControl = 4'b1011; // MULH
        3'b010: aluControl = 4'b1100; // MULHSU
        3'b011: aluControl = 4'b1001; // MULHU

        3'b100: aluControl = 4'b1110; // DIV
        3'b101: aluControl = 4'b1111; // DIVU
        3'b110: aluControl = 4'b0110; // REM
        3'b111: aluControl = 4'b0111; // REMU

        default: aluControl = 4'b0000;
    endcase
end
```

#### Multiplication Hardware Integration
**Single-Cycle Multiplier** (`mul.sv`):

For multiplication to work, the ALU was modified to also compute these type of instructions. This was standard single-cycle arithmetic since the multiplication operator automatically handles this when operands are declared with stating their sign.

```systemverilog
always @(*) begin
        case(alu_op)
            4'b0000: result = inA + inB;
            4'b1000: result = inA - inB;
            4'b0001: result = inA << inB[4:0]; //logical left shift 
            4'b0010: result = ($signed(inA) < $signed(inB)) ? {{(WIDTH-1){1'b0}},{1'b1}} : {(WIDTH){1'b0}};   //set less than (signed)
            4'b0011: result = (inA < inB) ? {{(WIDTH-1){1'b0}},{1'b1}} : {(WIDTH){1'b0}}; //set less than (unsigned)
            4'b0100: result = inA ^ inB;
            4'b0101: result = inA >> inB[4:0]; //shift right logical
            4'b1101: result = $signed(inA) >>> inB[4:0]; //shift right arithmetic
            4'b0110: result = inA | inB;
            4'b0111: result = inA & inB;
            // Additional MUL instructions
            4'b1010: result = inA * inB;                                          // MUL
            4'b1011: result = 32'((64'(($signed(inA))) * 64'(($signed(inB)))) >> 32);  // MULH
            4'b1100: result = 32'((64'(($signed(inA))) * 64'(inB)) >> 32);             // MULHSU
            4'b1001: result = 32'((64'(inA) * 64'(inB)) >> 32);
            default: result = {WIDTH{1'b0}};
        endcase
    end
```

## Division Unit - Multi-Cycle Implementation

### Architecture Overview

I used the restoring division method for my implementation. This means it takes 32 cycles for a division to occur instead of doing everything in one cycle which would result in a very large block and a real CPU speed would be affected by the large division hardware.

**Clock cycles as states**:
```
Cycle 0: Load dividend, divisor; initialise quotient, remainder
Cycle 1-32:   Iterative bit-by-bit division (restoring division algorithm)
Cycle 33: Output ready; pipeline continues
```

### Restoring Division Algorithm

The algorithm processes the dividend from MSB to LSB, building the quotient through repeated subtraction attempts. Kind of like long division.

**Iterative Process**:
```systemverilog
// Each iteration processes one dividend bit
assign possible_remainder = {remainder_reg[DATA_WIDTH-2:0], dividend_register[DATA_WIDTH-1]};
// Shift the MSB of dividend into LSB of remainder 

dividend_register <= {dividend_register[DATA_WIDTH-2:0], 1'b0};
// Remove the processed bit from dividend
```

**Conditional Update Logic**:
```systemverilog
if (possible_remainder >= divider_register) begin
    remainder_reg <= possible_remainder - divider_register;
    quotient_reg <= {quotient_reg[DATA_WIDTH-2:0], 1'b1};
end
else begin
    remainder_reg <= possible_remainder;
    quotient_reg <= {quotient_reg[DATA_WIDTH-2:0], 1'b0};
end
```

If we possible have a remainder, meaning our shift has overflower causing our the register to be greater than or equal to the divisor, subtract and set the quotient bit to 1. Otherwise, keep the remainder and set the quotient bit to 0.
This process repeats 32 times, with each iteration adding a bit to the quotient.

### Sign Handling for DIV and REM
A big challenge I faced was handling the signs after each cycle so the sign was propogated forward. To solve this I essentially do unsigned division everytime and then add the sign bit afterwards if the numbers were initially flagged as signed.

```systemverilog
if (!is_unsigned) begin
    signed_remainder    <= dividend[DATA_WIDTH-1];
    signed_result <= dividend[DATA_WIDTH-1] ^ divisor[DATA_WIDTH-1];
    dividend_register <= dividend[DATA_WIDTH-1] ? -dividend : dividend;
    divider_register  <= divisor[DATA_WIDTH-1]  ? -divisor  : divisor;
end 
else begin
    dividend_register <= dividend;
    divider_register  <= divisor;
    signed_remainder       <= 0;
    signed_result    <= 0;
end
```
One thing to note is that, in RISC-V, the remainder takes the sign of the dividend. This is correctly handled in my implementation by preserving the dividend sign throughout and not negating the remainder.   

### Handling Division by Zero
RISC-V specifies that division by zero should return:   
- Quotient:    All 1's 
- Remainder:  The dividend value 

**Implementation**:
```systemverilog
if (divisor == 0) begin
    is_finished     <= 1;
    is_running   <= 0;
    quotient  <= is_unsigned ? 32'h7FFFFFFF : 32'hFFFFFFFF;
    remainder <= dividend;
end 
```

## Hazard Unit Integration for Division Stalls
To correctly implement my division module, the CPU must be stalled for the entire duration of the DIV instruction. To achieve this, I use the is_div flag and the is_finished(div_done) flag to tell the hazard unit that it needs to stall the CPU.

```systemverilog
assign div_stall_flag = (is_div) && !div_done;

```

A small section of the hazard unit was changed to dissable the pipeline registers if the CPU was stalling due to a DIV instruction.

```systemverilog
always_comb begin : reg_enables
        PC_en  = reg_en && !div_stall; 
        F_D_en = reg_en && !div_stall;
        D_E_en = reg_en && !div_stall;
        no_op  = (~reg_en);
    end
```

Another thing to note was that while testing, the DIV would fail due to old values being propergated to the output before the DIV was finished. So to stop this, I set the E_reg and E_mem enable flags to 0 when the cpu is stalling.
```systemverilog
E_M_reg E_M (
    .clk(clk),
    .rst(rst),
    // A bit hacky but just stops any control signals from passion through when div occurs.
    .E_RegWrite(div_stall_flag ? 1'b0 : E_RegWrite),
    .E_mem_write(div_stall_flag ? 1'b0 : E_mem_write),
```
