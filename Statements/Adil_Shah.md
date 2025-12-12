# Personal Statement - Adil Shah
## RISCV-Team7 CPU Design Project

For the RISC-V CPU design project, I made contributions across both the single-cycle and pipelined implementations. My work focused on control logic design, pipeline architecture, and performance optimizations through dynamic branch prediction. This document details the technical implementation of these contributions.

---

## Single-Cycle CPU Implementation

### Control Unit Design

I designed and implemented the main control unit responsible for decoding all RISC-V RV32I instructions and generating appropriate control signals. The control unit architecture utilized a hierarchical approach with two key sub-modules:

#### ALU Decoder Sub-module
I worked with Louis to define the ALU operation encoding scheme. The decoder translates instruction opcodes and function fields into ALU control signals that determine arithmetic and logical operations. This required analysis of the RV32I instruction set to ensure complete coverage of:
- R-type instructions (ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU)
- I-type arithmetic instructions (ADDI, ANDI, ORI, XORI, SLTI, SLTIU)
- Shift operations with immediate values (SLLI, SRLI, SRAI)

#### Branch Comparator Sub-module
Implemented a dedicated comparator that evaluates branch conditions by examining the ALU output flags and branch type. The comparator supports all six branch instruction variants (BEQ, BNE, BLT, BGE, BLTU, BGEU) by combining:
- Zero flag for equality comparisons
- Sign and overflow flags for signed comparisons
- Unsigned comparison logic for BLTU/BGEU

This modular design proved particularly valuable during the transition to pipelined architecture. Since branch resolution must occur in the Execute stage for a 5-stage pipeline, I could simply relocate the branch comparator module from the control unit to the Execute stage without significant redesign.

### Sign Extension Module

Developed a comprehensive immediate value sign-extension module that handles all RISC-V instruction formats. The implementation required detailed analysis of how immediate values are encoded across different instruction types:

- **I-type**: 12-bit immediate in bits [31:20]
- **S-type**: 12-bit immediate split between bits [31:25] and [11:7]
- **B-type**: 13-bit immediate with implicit least significant bit (0), spread across bits [31:25] and [11:7], with specific bit rearrangement
- **U-type**: 20-bit immediate in bits [31:12]
- **J-type**: 21-bit immediate with implicit LSB, using complex bit ordering across [31:12]

The module uses the opcode to determine the instruction format, then extracts and sign-extends the appropriate bits to produce a full 32-bit signed immediate value.

### Instruction Memory Module

Implemented the instruction memory interface with proper byte-addressable memory access and 32-bit instruction alignment. Key features included:
- Word-aligned address generation (dividing byte addresses by 4)
- Big-endian/little-endian handling considerations
- Integration with the program counter

Collaborated with Archie to refine the byte addressing format to ensure compatibility with the memory subsystem and test infrastructure.

---

## Pipelined CPU Implementation

### Top-Level Architecture and Pipeline Registers

Led the redesign of the top-level module to support 5-stage pipelining (Fetch, Decode, Execute, Memory, Writeback). This required:

**Pipeline Stage Separation**: Carefully partitioned the single-cycle datapath into discrete stages, ensuring each stage had well-defined inputs and outputs.

**Pipeline Register Implementation**: Designed and implemented all four inter-stage pipeline registers (F/D, D/E, E/M, M/W):
- Each register operates on the positive clock edge for synchronous operation
- Includes enable signals for stall handling
- Incorporates flush/clear capability for control hazard resolution
- Propagates all necessary control signals, data values, and metadata through the pipeline

Worked with Archie on formatting and organizing the top-level connections to maintain code readability despite the increased complexity of the pipelined design.

### Hazard Detection and Control Hazard Handling

Focused specifically on control hazard detection and resolution while collaborating with Louis on data hazard handling. The control hazard implementation included:

**Control Hazard Identification**: Detection logic for branch and jump instructions in the pipeline:
- Branch instructions (opcode `7'b1100011`): BEQ, BNE, BLT, BGE, BLTU, BGEU
- Jump instructions: JAL (opcode `7'b1101111`) and JALR (opcode `7'b1100111`)

**Initial Static Not-Taken Prediction**: Implemented a baseline prediction strategy where:
- Branches are assumed not-taken by default
- Pipeline continues fetching sequential instructions
- On branch-taken or jump, the pipeline flushes incorrect instructions and redirects to the target

**Pipeline Flush Mechanism**: Designed the flush control logic to:
- Insert NOPs (bubbles) into F/D and D/E registers when misprediction occurs
- Clear all control signals (RegWrite, MemWrite, etc.) to prevent erroneous state updates
- Ensure flushed instructions have no architectural effect

**PC Selection Logic**: Implemented multiplexing between:
- Sequential PC (PC + 4)
- Branch/jump target address (PC + immediate offset)
- Handled PC redirection timing to minimize penalty cycles

This static prediction baseline allowed other team members to proceed with implementing the multiply extension and cache subsystems while I developed the dynamic prediction circuit.

---

## Branch Prediction - Dynamic Prediction System

### Research and Design Selection

Before implementation, I researched various branch prediction strategies to determine the optimal approach for our CPU design. Key resources included:
- [Correlating Branch Prediction](https://www.geeksforgeeks.org/computer-organization-architecture/correlating-branch-prediction/)
- [Branch Target Prediction (Imperial College)](https://www.doc.ic.ac.uk/~phjk/AdvancedCompArchitecture/Lectures/pdfs/Ch03-part2-BranchTargetPrediction.pdf)

After evaluating several approaches (1-bit prediction, tournament predictors, correlating predictors), I selected a **2-bit saturating counter with Branch Target Buffer** architecture because:
- Provides significant performance improvement over static prediction.
- Manageable implementation within project timeframe.
- Easy to understand state machine.

More sophisticated predictors (tournament, correlating) were deemed out of scope given our project constraints.

### Branch History Table (BHT) Implementation

The BHT uses 2-bit saturating counters to learn branch behavior over time. Each branch instruction maps to an entry in the table based on its PC address.

**Architecture Details**:
- **Table Size**: Parameterized with `INDEX_BITS = 4`, yielding 16 entries (configurable to 64, 256, or larger as needed)
- **Indexing Scheme**: Uses PC bits `[INDEX_BITS+1:2]` as the table index
  - Ignores lower 2 bits since instructions are 4-byte aligned
- **State Encoding**: Four states representing prediction confidence:
  - `2'b00`: Strongly Not-Taken (SNT)
  - `2'b01`: Weakly Not-Taken (WNT)
  - `2'b10`: Weakly Taken (WT)
  - `2'b11`: Strongly Taken (ST)

**Prediction Logic**:
```systemverilog
predict_taken = bht[index_F][1];  // MSB indicates taken (1) or not-taken (0)
```
The most significant bit of the 2-bit counter determines the prediction, this allows an extra prediction in the same direction before changing the prediction. This is the fundamental difference between 1 an 2 bit predictors.

**Update State Machine**:
The counter updates based on actual branch outcomes:

[State transition diagram](https://media.geeksforgeeks.org/wp-content/uploads/20200520205206/pik11.png)

This saturating counter behavior means a branch must be mispredicted twice consecutively to fully change the prediction, which provides robustness against noise and temporary pattern changes.

**Update Timing**: The BHT updates during the Execute stage when:
- A branch instruction completes (`branch_resolved_E` asserted)
- The actual outcome (`branch_taken_E`) is known
- Not during pipeline flushes (critical to prevent corruption of learning)

### Branch Target Buffer (BTB) Implementation

The BTB acts as a cache for branch target addresses, eliminating the need to calculate the target in the Execute stage for predicted-taken branches.

**Architecture Details**:
- **Table Size**: Same parameterized size as BHT (16 entries with `INDEX_BITS = 4`)
- **Entry Structure**: Each entry contains:
  - `valid` bit: Indicates whether the entry contains valid data
  - `tag` field: Upper bits of PC for matching (`PC[31:INDEX_BITS+2]`)
  - `target` field: Full 32-bit target address
- **Indexing**: Uses the same indexing scheme as BHT for consistency

**Lookup Process**:
```systemverilog
assign index_F = PC_F[INDEX_BITS+1:2];
assign index_E = PC_E[INDEX_BITS+1:2];
assign tag_F   = PC_F;
assign tag_E   = PC_E;

assign hit_F    = btb_valid[index_F] && (btb_tag[index_F] == tag_F);
assign target_F = btb_target[index_F];
```
A BTB hit indicates we've seen this branch before and have cached its target address.

**Update Logic**:
- Updates occur in parallel with BHT updates when branches resolve
- Writes the actual target address (`branch_target_E`) to the appropriate entry
- Sets the valid bit and stores the current PC's tag


**Handling BTB Misses**:
When the BTB doesn't have an entry for a branch (first encounter):
- Falls back to static not-taken prediction
- Allows the branch to resolve in Execute stage
- Updates BTB with the target for future predictions
- This penalty occurs only once per unique branch

### Branch Predictor Integration Module

Created a unified branch predictor module that combines BHT and BTB with proper handshaking:

**Prediction Signal Generation**:
```systemverilog
predict_taken_F  = bht_predict_taken && btb_hit;
predict_target_F = btb_target;
predict_valid_F  = btb_hit;    
```

**Critical Design Decision - Prediction Validity**:
The predictor only generates a prediction when `btb_hit` is true. This ensures:
- We don't speculatively execute on first-time branches (unknown targets)
- Static not-taken behavior serves as the fallback
- No incorrect target addresses are used

**Handling JAL vs. Branch Instructions**:
Initially, all jumps (JAL/JALR) were treated as mispredictions. Through debugging, I refined this to:
- **JAL instructions**: Can be predicted since target is PC-relative (now cached in BTB)
- **JALR instructions**: Use static prediction (target depends on register value)
- **Update logic**: `update_predictor = branch_resolved_E || is_jal`

This differentiation significantly improved performance on code with function calls (JAL for call, JALR for return).

### Hazard Unit Integration with Prediction

Modified the hazard unit to incorporate branch prediction feedback:

**Prediction Metadata Pipeline Propagation**:
Added signals that track predictions through the pipeline:
- `F_prediction_made`: Indicates a prediction was made in Fetch
- `F_predicted_taken`: Records the prediction direction
- These propagate through D and E stages alongside the instruction

**Misprediction Detection Logic**:
```systemverilog
if (E_Branch && E_prediction_made) begin
    branch_mispredict = (E_predicted_taken != branch_taken);
end
else if (E_Branch && !E_prediction_made) begin
    branch_mispredict = branch_taken;  // BTB miss, first time seeing branch
end
```

**Flush Control Refinement**:
Flush the pipeline only when necessary:
- Branch mispredicted (prediction existed but was wrong)
- Branch taken but no prediction was made (BTB miss)
- JAL/JALR instructions that weren't correctly predicted

Correct predictions result in zero flush penalty - the pipeline continues seamlessly.

**PC Update Logic**:
On misprediction:
- `PCSrc` selects the correct target address
- If predicted not-taken but taken: redirect to `PC_E + immediate`
- If predicted taken but not-taken: redirect to `PC_E + 4`

## Performance Analysis and Testing

### Test Methodology

Developed comprehensive test programs to validate and benchmark the branch prediction system:

**Correctness Testing**: Verified that predicted execution produces identical results to non-predicted execution (same final register and memory state).

**Performance Measurement**: Implemented cycle counters to measure:
- Total execution cycles
- Number of mispredictions (flush events)
- Misprediction rate

### Benchmark Results

**AddiBNE Test Program**: A loop-intensive program that executes a simple counter loop:

- **Static Prediction (baseline)**: 1277 cycles
- **Dynamic Prediction (2-bit + BTB)**: 771 cycles
- **Improvement**: 506 cycles saved, **~40% reduction**

This significant speedup demonstrates the effectiveness of the dynamic predictor on loop-heavy code, where branches exhibit strong temporal locality.

**Custom Predictor Stress Test (`predictor.s`)**:
Created a test program with deliberately challenging branch patterns:
- Rapidly alternating branches (worst case for 2-bit counters)
- Nested loops with different iteration counts
- Mixed taken/not-taken biases

These tests validated that:
- The predictor correctly handles pathological cases without incorrect execution
- Performance degrades gracefully on unpredictable branches (approaching static prediction performance)
- The predictor learns patterns within a few iterations

### Analysis of Results

**Why the Improvement Occurs**:
- **Loop Behavior**: Loops typically iterate many times with a taken branch, followed by one not-taken exit
- **2-bit Counter Effectiveness**: After the first two iterations, the counter reaches ST state
- **Zero-Cycle Penalty**: Correctly predicted taken branches have no stall - the pipeline continues uninterrupted
- **Reduced Misprediction**: Only the final loop exit is mispredicted (predicted taken, actually not-taken)

**Diminishing Returns on Complex Patterns**:
The `predictor.s` tests showed minimal improvement when branches alternate rapidly, confirming the theoretical limitation of 2-bit predictors on complex patterns. This validates that the implementation behaves as expected.

---

## Technical Skills Demonstrated

### SystemVerilog Design
- Parameterized module design for scalability
- Effective use of structs and typedefs for clarity
- Proper combinational vs. sequential logic separation
- Clock domain understanding and synchronization

### Computer Architecture Principles
- Deep understanding of pipeline hazards and their resolution
- Knowledge of branch prediction algorithms and trade-offs
- Appreciation for timing constraints and critical paths
- Performance analysis and optimization techniques

### Debugging Methodology
- Systematic waveform analysis
- Isolation of failure modes (branch tests vs. jump tests)
- Root cause analysis (symptoms vs. actual problems)
- Incremental testing and validation

### Collaboration and Documentation
- Clear module interfaces for team integration
- Git workflow with feature branches for parallel development
- Code commenting and documentation
- Performance measurement and reporting

---

## Summary and Reflection

My contributions to the RISCV-Team5 project spanned the entire design space from basic control logic to advanced microarchitectural optimizations. The work on branch prediction was particularly rewarding, as it required:

1. **Theoretical Understanding**: Research into prediction algorithms and selection of appropriate techniques
2. **Practical Implementation**: Translation of algorithms into working hardware with proper timing
3. **Integration Challenges**: Combining prediction with existing hazard detection and pipeline control
4. **Debugging Rigor**: Systematic identification and resolution of complex timing and correctness issues
5. **Performance Validation**: Quantitative measurement of improvements and analysis of results

The dynamic branch prediction system achieved a **~40% cycle count reduction** on loop-intensive code while maintaining full correctness.

The project provided hands-on experience with the challenges of hardware design: pipeline complexity, performance-correctness trade-offs, and collaborative development.

---

## Repository Structure

All implementations are available in the team repository:
- **Control Unit:** `rtl/control_unit.sv`
- **Instruction Memory:** `rtl/instrMem.sv`
- **Sign Extend module:** `rtl/sign_extend.sv`
- **Branch:** `Branch-Prediction` (my feature branch for development)
- **Key Files**: 
  - `rtl/branch_history_table.sv` - BHT implementation
  - `rtl/branch_target_buffer.sv` - BTB implementation  
  - `rtl/branch_predictor.sv` - Top-level predictor module
  - `rtl/hazard_unit/hazard_unit.sv` - Integrated hazard detection with prediction
  - `rtl/top.sv` - Pipeline integration
  - `tb/asm/predictor.s` - Custom branch prediction stress test
