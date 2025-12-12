# RISC-V Pipelined RV32IM cpu without cache or branch prediction
# RV32IM Extension: Multiplication and Division

Implementation of the RV32IM integer multiplication and division extension for the RISC-V pipelined CPU, adding single-cycle multiplication and multi-cycle division capabilities.

## Overview

This extension adds 8 new instructions to the base RV32I instruction set:
- **4 Multiplication instructions**: Single-cycle hardware multiplication
- **4 Division/Remainder instructions**: Multi-cycle restoring division algorithm

![RV32IM Architecture](https://github.com/user-attachments/assets/45f92ae0-db66-427a-8454-c20a4d85e9a5)

## Instruction Set

### Multiplication Operations (Single-Cycle)

| Instruction | Operation | Description |
|-------------|-----------|-------------|
| `MUL rd, rs1, rs2` | rd = (rs1 × rs2)[31:0] | Lower 32 bits of product |
| `MULH rd, rs1, rs2` | rd = (rs1 × rs2)[63:32] | Upper 32 bits (signed × signed) |
| `MULHSU rd, rs1, rs2` | rd = (rs1 × rs2)[63:32] | Upper 32 bits (signed × unsigned) |
| `MULHU rd, rs1, rs2` | rd = (rs1 × rs2)[63:32] | Upper 32 bits (unsigned × unsigned) |

### Division Operations (Multi-Cycle)

| Instruction | Operation | Description |
|-------------|-----------|-------------|
| `DIV rd, rs1, rs2` | rd = rs1 ÷ rs2 | Signed division (quotient) |
| `DIVU rd, rs1, rs2` | rd = rs1 ÷ rs2 | Unsigned division (quotient) |
| `REM rd, rs1, rs2` | rd = rs1 % rs2 | Signed remainder |
| `REMU rd, rs1, rs2` | rd = rs1 % rs2 | Unsigned remainder |

### Instruction Encoding

All RV32IM instructions use **R-type format** with:
- **Opcode**: `0110011` (same as base R-type)
- **funct7**: `0000001` (identifies RV32IM extension)

| Instruction | funct3 | funct7 |
|-------------|--------|--------|
| MUL         | 000    | 0000001 |
| MULH        | 001    | 0000001 |
| MULHSU      | 010    | 0000001 |
| MULHU       | 011    | 0000001 |
| DIV         | 100    | 0000001 |
| DIVU        | 101    | 0000001 |
| REM         | 110    | 0000001 |
| REMU        | 111    | 0000001 |

## Implementation Details

### Control Unit Modifications

Extended the control unit to detect RV32IM instructions and set appropriate flags:

```systemverilog
7'b0110011: begin  // R-type
    RegWrite  = 1'b1;
    ResultSrc = 2'b00;  // ALU result
    ALUSrcB   = 1'b0;   // Use register values
    aluOp     = 2'b10;

    if (instr[31:25] == 7'b0000001) begin // RV32IM detection
        aluOp = 2'b11;  // Special ALU operation code

        case (funct3)
            3'b100, 3'b101, 3'b110, 3'b111: begin
                is_div = 1'b1;  // Flag for division stall logic
            end
            default: begin
                is_div = 1'b0;
            end
        endcase
    end
end
```

### ALU Decoder Extension

Added RV32IM instruction decoding:

```systemverilog
2'b11: begin  // RV32IM operations
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

### Single-Cycle Multiplication Hardware

Multiplication operations complete in one cycle using SystemVerilog's built-in multiplication operator with proper sign handling:

```systemverilog
always @(*) begin
    case(alu_op)
        // ... existing ALU operations ...
        
        // Multiplication instructions
        4'b1010: result = inA * inB;  // MUL - lower 32 bits
        
        4'b1011: result = 32'((64'(($signed(inA))) * 64'(($signed(inB)))) >> 32);
        // MULH - upper 32 bits (signed × signed)
        
        4'b1100: result = 32'((64'(($signed(inA))) * 64'(inB)) >> 32);
        // MULHSU - upper 32 bits (signed × unsigned)
        
        4'b1001: result = 32'((64'(inA) * 64'(inB)) >> 32);
        // MULHU - upper 32 bits (unsigned × unsigned)
        
        default: result = {WIDTH{1'b0}};
    endcase
end
```

**Design Note**: The multiplication operator automatically handles signedness when operands are declared with sign extensions, enabling clean single-cycle implementation.

## Multi-Cycle Division Unit

### Architecture Overview

Implements the **restoring division algorithm** as a 33-cycle operation:
- **Cycle 0**: Initialize dividend, divisor, quotient, and remainder
- **Cycles 1-32**: Iterative bit-by-bit division (one bit per cycle)
- **Cycle 33**: Output ready, pipeline resumes

**Why Multi-Cycle?**
Single-cycle division would require massive combinational logic, significantly increasing critical path delay and reducing CPU clock frequency. The multi-cycle approach balances hardware complexity with performance.

### Restoring Division Algorithm

The algorithm processes the dividend from MSB to LSB, building the quotient through repeated subtraction attempts (essentially hardware long division):

```systemverilog
// Shift next dividend bit into remainder
assign possible_remainder = {remainder_reg[DATA_WIDTH-2:0], dividend_register[DATA_WIDTH-1]};

// Shift out processed bit from dividend
dividend_register <= {dividend_register[DATA_WIDTH-2:0], 1'b0};
```

**Conditional Update Logic** (repeated 32 times):
```systemverilog
if (possible_remainder >= divider_register) begin
    // Subtraction successful - set quotient bit to 1
    remainder_reg <= possible_remainder - divider_register;
    quotient_reg <= {quotient_reg[DATA_WIDTH-2:0], 1'b1};
end
else begin
    // Subtraction would be negative - restore and set quotient bit to 0
    remainder_reg <= possible_remainder;
    quotient_reg <= {quotient_reg[DATA_WIDTH-2:0], 1'b0};
end
```

Each iteration adds one bit to the quotient, building the final result from LSB to MSB.

### Sign Handling for Signed Division

**Challenge**: Restoring division naturally works with unsigned numbers, but `DIV` and `REM` require signed operation.

**Solution**: Convert to unsigned, divide, then apply sign correction:

```systemverilog
if (!is_unsigned) begin
    // Store sign information
    signed_remainder <= dividend[DATA_WIDTH-1];  // Remainder takes dividend sign
    signed_result    <= dividend[DATA_WIDTH-1] ^ divisor[DATA_WIDTH-1];  // XOR for quotient sign
    
    // Convert to absolute values
    dividend_register <= dividend[DATA_WIDTH-1] ? -dividend : dividend;
    divider_register  <= divisor[DATA_WIDTH-1]  ? -divisor  : divisor;
end 
else begin
    // Unsigned division - use values directly
    dividend_register <= dividend;
    divider_register  <= divisor;
    signed_remainder  <= 0;
    signed_result     <= 0;
end
```

**RISC-V Remainder Convention**: The remainder takes the sign of the **dividend**, not the divisor. This is correctly handled by preserving `dividend[31]` in `signed_remainder`.

### Division by Zero Handling

RISC-V specification for division by zero:
- **Quotient**: All 1's (`0xFFFFFFFF` for signed, `0x7FFFFFFF` for unsigned)
- **Remainder**: The original dividend value

```systemverilog
if (divisor == 0) begin
    is_finished <= 1;
    is_running  <= 0;
    quotient    <= is_unsigned ? 32'h7FFFFFFF : 32'hFFFFFFFF;
    remainder   <= dividend;
end
```

## Hazard Unit Integration

### Division Stall Logic

![Division Stall Diagram](https://github.com/user-attachments/assets/537d2c7a-9c1e-44b4-874c-fba26e0ad2e5)

The CPU must stall for 33 cycles during division operations. Stall control uses two signals:
- `is_div`: Set by control unit when division instruction is decoded
- `div_done`: Set by division unit when computation completes

```systemverilog
assign div_stall_flag = (is_div) && !div_done;
```

### Pipeline Register Control

Modified hazard unit to disable all pipeline register updates during division stall:

```systemverilog
always_comb begin : reg_enables
    PC_en  = reg_en && !div_stall;   // Freeze PC
    F_D_en = reg_en && !div_stall;   // Freeze Fetch/Decode
    D_E_en = reg_en && !div_stall;   // Freeze Decode/Execute
    no_op  = (~reg_en);
end
```

### Preventing Data Corruption During Stall

**Problem**: Without additional protection, stale values from the Execute stage would propagate to Memory and Writeback stages during the 33-cycle stall, potentially corrupting register file or memory.

**Solution**: Disable control signals in Execute/Memory pipeline register during stall:

```systemverilog
E_M_reg E_M (
    .clk(clk),
    .rst(rst),
    // Disable control signals during division stall
    .E_RegWrite(div_stall_flag ? 1'b0 : E_RegWrite),
    .E_mem_write(div_stall_flag ? 1'b0 : E_mem_write),
    // ... other signals ...
);
```

This ensures division instructions don't cause unintended side effects while computing.

## Key Implementation Files

```
rtl/
├── execute/
│   ├── alu.sv                 # Extended ALU with MUL/DIV operations
│   └── division_unit.sv       # Multi-cycle restoring division
├── decode/
│   └── control_unit.sv        # RV32IM instruction detection
├── hazard_unit/
│   └── hazard_unit.sv         # Division stall logic
└── top.sv                     # Integration with pipeline

tb/asm/
└── mul_div_tests.s            # Comprehensive RV32IM test suite
```

## Testing

Extensive testing across various scenarios:
- Basic multiplication and division operations
- Edge cases: division by zero, negative numbers, overflow
- Interaction with other hazards (load-use, control hazards)
- Nested division operations
- Mixed MUL/DIV instruction sequences

![Test Results](https://github.com/user-attachments/assets/4ef5c2b6-436d-4775-888d-9aa462a50066)

## Performance Characteristics

| Operation | Cycles | Notes |
|-----------|--------|-------|
| MUL/MULH/MULHSU/MULHU | 1 | Single-cycle, no stall |
| DIV/DIVU/REM/REMU | 33 | Multi-cycle, pipeline stalls |

**Division Performance**: While 33 cycles seems slow, it's significantly faster than:
- Software division (100+ cycles in loops)
- Non-restoring division with similar hardware
- Single-cycle division (impossible without massive area/delay penalty)

## Design Lessons Learned

### Planning is Critical
Initially attempted non-restoring division without fully understanding the algorithm, wasting significant time. **Lesson**: Thoroughly research and understand algorithms before implementation.

### Standardized Naming Conventions
Lack of standardized input/output naming in early development made module interconnection challenging. **Lesson**: Establish consistent naming schemes before writing code.

### Incremental Testing
Comprehensive testing revealed edge cases (e.g., stall + data hazard combinations) that weren't obvious during design. **Lesson**: Test early and often, especially with complex interactions.

## Future Enhancements

### SRT Division
The industry-standard SRT (Sweeney, Robertson, Tocher) division algorithm provides:
- Faster division (fewer cycles through radix-4 or radix-8)
- More complex quotient selection logic
- Trade-off: increased hardware complexity for better performance

### Hardware Division Acceleration
- **Radix-4 Division**: 2 bits per cycle → 17 cycles total
- **Radix-8 Division**: 3 bits per cycle → 11 cycles total
- **Pipelined Division**: Allow new division to start before previous completes

### Additional Extensions
- **RV32F**: Single-precision floating-point (requires FP register file, FP ALU)
- **RV32A**: Atomic memory operations (requires cache coherence modifications)
- **Custom instructions**: Application-specific accelerators
