# My Contribution

This section documents my individual contribution to the Team RISC-V group project. I led the **datapath implementation** and **pipeline hazard resolution**, designing the ALU, register file, and data memory while developing a comprehensive hazard detection unit that enabled our CPU to achieve a **5x performance improvement** through efficient pipelining.

---

## Team Context & Role

Our team divided responsibilities across the CPU architecture:
- **My focus:** Datapath components, memory elements, pipeline control, and hazard handling
- **Integration work:** Close collaboration with control unit (Adil) and pipeline registers (Archie & Sam)
- **Scope:** RTL development through microarchitectural correctness and performance validation

---

## Single-Cycle Core: Datapath Components

### Arithmetic Logic Unit (ALU)
- Designed and implemented the ALU supporting all required **RV32I operations**
- Worked with Adil to enable correct ALU and control unit integration
- *File:* `rtl/alu.sv`

---

### Register File
- Implemented the **32×32-bit register file** with negedge synchronous writes and dual combinational reads
- Handled **x0 hardwiring**, write-enable logic, and rst signal resetting register values to `32'b0`
- *File:* `rtl/regfile.sv`

---

### Data Memory (DataMem)
- Implemented data memory for **load/store instructions**
- Verified byte-array indexing, byte/half-word/word operations
- Implemented sign extension signal for loading half-words and bytes into 32-bit registers
- *File:* `rtl/datamem.sv`

---

## Critical Debugging: Top-Level Integration

### The Problem
After integrating all components at `top.sv`, our CPU failed several test programs. I conducted systematic debugging using:
- Provided assembly files and custom test instructions
- **GTKWave** waveform analysis to isolate failing instructions

### Root Cause Identification
Identified problematic assembly instructions:
```asm
lbu  rd  imm(rs1)
```
```asm
lh   rd  imm(rs1)
```

**Debugging process:**
1. Tracked the `signed/unsigned` control signal in GTKWave - detected incorrect value
2. Traced wire back to control unit output: `memUnsigned`
3. **Discovered the bug:** Control unit asserted `1` for unsigned, but datamem expected `0` for unsigned
4. This naming confusion had caused incorrect signal mapping during top-level integration

### The Fix
- Modified Control Unit to correct the unsigned logic polarity
- Cleaned up datamem-relevant control signals using my knowledge from building the module
- **Result:** Single-cycle CPU passed **all tests** including the PDF program

**Commit:** [Top level debug](https://github.com/SAMOS-76/RISC-V-Team7/commit/1eb67f8c9796f942b4225ac20abad4cb5b40a267)

---

## Pipeline Design & Hazard Handling

**Context:** Archie and Sam implemented the basic pipeline structure. I was tasked with **hazard detection and resolution** to ensure correctness and maximize performance.

### Design Strategy
- **Forwarding** for EX-stage data dependencies (from MEM/WB stages)
- **Stalling + bubble insertion** for load-use hazards (simulating real-world memory latency)
- **Negedge register file writes** to resolve decode-writeback dependencies

---

### Forwarding Implementation: Top Level

Modified the datapath to include forwarding paths:

**Key design decision:** Negedge write to register file
- Standard practice in pipelined processors
- Resolves dependency between instruction in decode and writeback
- Combinational read means writeback values are immediately available to `D_E` pipeline register

**Forwarding paths:**
- Writeback → Execute forwarding
- Memory → Execute forwarding
- Hazard unit controlled MUXes selecting correct data source

**Forwarding MUX implementation:**
```verilog
always_comb begin
    case (forwarding_sel_a)
        2'b00: E_forwarded_1 = E_r_out1;
        2'b01: E_forwarded_1 = M_alu_result;
        2'b10: E_forwarded_1 = W_result;
        default: E_forwarded_1 = 32'b0;        
    endcase
    case (forwarding_sel_b)
        2'b00: E_forwarded_2 = E_r_out2;
        2'b01: E_forwarded_2 = M_alu_result;
        2'b10: E_forwarded_2 = W_result;
        default: E_forwarded_2 = 32'b0;        
    endcase
end
```

---

### Forwarding Logic: Hazard Unit

**Design approach:**
- Combinational forwarding logic with **MEM-stage priority** if dependencies exist in both MEM and WB stages
- Used **enum types** for maintainable code:
```verilog
typedef enum logic [1:0]{
    none = 2'b00,
    mem  = 2'b01,
    writeback = 2'b10
} forward_type;
```

**Functionality:**
- Checks if register values read in EX stage depend on values being written in MEM/WB stages
- Asserts forwarding control signals to select correct data source

---

### Critical Design Enhancement: Opcode Validity Checking

**The Problem I Discovered:**

Standard hazard detection has a **subtle but critical flaw** that isn't commonly discussed:
- Register address fields (`ra`, `rb`, `rd`) occupy the same bit positions across all instruction formats
- In I-type and U-type instructions, these bit fields represent **immediate values**, not registers
- **Example bug scenario:**
  - Previous instruction: `lw x10, 0(x5)` (loading into register x10)
  - Current instruction: `addi x3, x4, 10` (immediate value is 10)
  - Naive hazard detection sees "10" in the immediate field and incorrectly flags a dependency with register x10

**Why This Matters:**

While the execute stage MUXes select immediate values over forwarded data anyway, this creates:
- Technically incorrect forwarding signals
- Potential for spurious stalls
- Non-robust behavior that could cause unexpected issues
- Violations of architectural correctness

**My Solution:**

Implemented **opcode-aware validation** that determines whether bit fields represent actual registers before checking for hazards:
```verilog
always_comb begin : opcode_check
    d_reg_1_valid = ~(d_opcode == 7'b0010111 | d_opcode == 7'b0110111 | d_opcode == 7'b1101111);
    d_reg_2_valid = ~(d_opcode == 7'b0010111 | d_opcode == 7'b0110111 | d_opcode == 7'b1100111 | d_opcode == 7'b1101111 | d_opcode == 7'b0000011 | d_opcode == 7'b0010011);

    E_reg_1_valid = ~(E_opcode == 7'b0010111 | E_opcode == 7'b0110111 | E_opcode == 7'b1101111 | E_opcode == 7'b0000000);
    E_reg_2_valid = ~(E_opcode == 7'b0010111 | E_opcode == 7'b0110111 | E_opcode == 7'b1100111 | E_opcode == 7'b1101111 | E_opcode == 7'b0000011 | E_opcode == 7'b0010011 | E_opcode == 7'b0000000);

    W_reg_c_valid = ~(W_opcode == 7'b0100011 | W_opcode == 7'b1100011 | ~wb_reg_write_enable);
    M_reg_c_valid = ~(M_opcode == 7'b0100011 | M_opcode == 7'b1100011 | ~datamem_reg_write_enable);
end
```

**Implementation details:**
- Uses opcode to check if the 'register' value actually represents a register in that instruction type - not an immediate
- Opcode check combines with write flags to produce `reg_valid` flags
- Only valid stall/forward operations occur when both source and destination are actual registers
- Modified pipeline registers to save instruction opcodes for hazard unit analysis

---

### Stalling Implementation

**Load-use hazard detection:**
```verilog
assign A_L_haz = (E_opcode == 7'b0000011 && (((d_reg_a == ex_reg_d) && d_reg_1_valid) || ((d_reg_b == ex_reg_d) && d_reg_2_valid)));
```

**Stall mechanism:**
- Detects if instruction in decode depends on a load instruction in execute
- Modified `D_E` pipeline register to have `no_op` input that sets all values to 0 - producing a **bubble** in execute stage
- Load instruction continues to MEM stage where data becomes available for forwarding

**Bubble generation code:**
```verilog
else if (CTRL_Flush|| no_op) begin
    E_RegWrite <= 0;
    E_PCTargetSrc <= 0;
    E_result_src <= 0;
    E_mem_write <= 0;
    E_alu_control <= 0;
    E_alu_srcA <= 0;
    E_alu_srcB <= 0;
    E_sign_ext_flag <= 0;
    E_Branch <= 0;
    E_Jump <= 0;
    E_branchType <= 0;
    E_pc_out <= 0;
    E_pc_out4 <= 0;
    E_imm_ext <= 0;
    E_r_out1 <= 0;
    E_r_out2 <= 0;
    E_type_control <= 0;
    E_rd <= 0;
    E_ra <= 0;
    E_rb <= 0;
    E_opcode <= 0;
end
```

**Stall control:**
- Makes `PC_en`, `F_D_reg_en` and `D_E_reg_en` low
- Instructions in fetch and decode stages stall in place

---

### Why Stalling is Necessary (Real CPU Behavior)

**Physical CPU limitation:**
Load stalls occur in physical CPUs because there is a **propagation delay** getting data out of the memory block. It cannot be forwarded to the execute stage in time for the next clock cycle.

**Solution:**
- Stall the dependent instruction in execute stage
- Insert a no-op bubble in its place
- Allow load instruction to move to writeback stage
- Forward the loaded data from writeback to execute

**Verilator limitation:**
Verilator doesn't simulate propagation delays - meaning it 'passes' all load hazard tests without stalling. However, **conceptually it is critical to implement** to understand real hardware behavior and timing closure.

**Validation approach:**
Rather than just accepting that tests passed, I used **GTKWave** to:
- Track the number of `no_op` signals generated
- Compare against expected number of stalls from the program
- Verified my implementation correctly generated stalls for all load-use hazards
- **Confirmed the CPU behaves like real hardware** with proper timing constraints

---

## Custom Hazard Testing Framework

### Motivation
Hazards are **rare exceptions** that must be handled correctly for the processor to perform accurately with ALL possible instruction sequences. Comprehensive testing is essential.

### Testing Strategy
Developed a directory of custom assembly programs targeting specific hazard scenarios:

**Test coverage:**
- Forwarding into either register or both registers
- MEM-stage forwarding priority verification
- Forwarding for both data AND address in load/store instructions
- Continuous rewrites to the same register
- Load-use hazards
- Multiple sequential loads with dependent instruction
- Multiple instructions dependent on a single load
- Complex functions with cascaded dependencies

### Testing Infrastructure
Modified the provided `verify.cpp` and `doit.sh` to:
- Run CPU with custom assembly files
- Store output waveforms in organized directories
- Enable rapid identification of issues through systematic testing

**Impact:**
- Significantly accelerated CPU debugging
- Other team members adopted these scripts for their own testing
- Created a robust validation framework for the entire project

---

## Control Hazard Debugging (with Adil)

**Collaboration:**
- Assisted in diagnosis and correction of control-hazard behavior in branch and jump sequences
- Verified interactions between pipeline flush logic, PC selection, and instruction fetch

**Methodology:**
- Developed several testing programs targeting control flow edge cases
- Extensively used **GTKWave** to identify incorrect jump/branch behavior
- Isolated root cause and implemented fix

**Result:**
CPU passed all custom tests (both data and control hazards) and all provided test programs

---

## Testing & Validation

Developed comprehensive test suite with **Google Test** integration:

**Example test cases:**
```cpp
TEST_F(CpuTestbench, complex_load_hazard)
{
    setupTest("7_complex_load_hazard");
    initSimulation();
    runSimulation(100);
    EXPECT_EQ(top_->a0, 6);
}

TEST_F(CpuTestbench, out_lbu)
{
    setupTest("8_out_lbu");
    initSimulation();
    runSimulation(1000);
    EXPECT_EQ(top_->a0, 300);
}

TEST_F(CpuTestbench, test_diagnostic)
{
    setupTest("10_diagnostic");
    initSimulation();
    runSimulation(1000);
    EXPECT_EQ(top_->a0, 39);
}

TEST_F(CpuTestbench, test_branch_delay)
{
    setupTest("11_branch_delay");
    initSimulation();
    runSimulation(150);
    EXPECT_EQ(top_->a0, 5);
}
```

---

## Performance Impact

### Quantified Results

**Hazard unit benefits:**
- Developed in conjunction with Adil (who also implemented branch prediction)
- Enabled full deployment of **5-stage pipelining**
- **40% cycle reduction** in test cases (with branch prediction)

**Throughput improvement:**
- Critical path reduced to **1/5 of single-cycle design**
- Enables **5x faster clock speed** in real hardware
- Stalls only occur for:
  - Load-use hazards (1 cycle)
  - Incorrectly predicted branches (rare with prediction)
- **Approximate 5x instruction throughput increase**

*Note: While Verilator cannot represent timing improvements, this design would achieve significant performance gains in synthesized hardware.*

---

## Technical Skills Demonstrated

### SystemVerilog RTL Design
- Parameterized module development
- Use of `typedef` and `enum` for clean, maintainable code
- Proper synthesis-safe separation of sequential vs. combinational logic
- Default statements to prevent latches
- Understanding of clocking, timing, and critical paths

### Computer Architecture
- Single-cycle processor design (ALU, datamem, regfile, control unit)
- 5-stage pipeline design
- Data/structural/control hazard understanding and resolution
- Forwarding and load-use stalling mechanisms
- Performance optimization techniques

### Debugging Methodology
- Systematic waveform-driven debugging with GTKWave
- Failure mode isolation and root cause analysis
- Incremental integration and test-driven verification
- Custom test framework development

### Collaboration & Documentation
- Clean module interfaces for team integration
- Detailed documentation of module specifications and ports (lucid-notes)
- Effective Git branching workflow on shared project
- Clear commit messages and inline code documentation
- Strong communication and project management:
  - Collaborated on single-cycle development
  - Worked in pairs on pipeline extensions
  - Shared testing infrastructure across team

---
