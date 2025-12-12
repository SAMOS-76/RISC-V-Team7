# Personal Statement - Adil Shah
## RISCV-Team7 CPU Design Project

For the RISC-V CPU design project, I made contributions across both the single-cycle and pipelined implementations. My work focused on control logic design, pipeline architecture, and performance optimizations through dynamic branch prediction. This document details the technical implementation of these contributions.

---

## Single-Cycle CPU Implementation

### Control Unit Design

I designed and implemented the main control unit responsible for decoding all RISC-V RV32I instructions and generating appropriate control signals. The control unit architecture utilized a hierarchical approach with two key sub-modules:

#### ALU Decoder Sub-module
Worked with Louis to define the ALU operation encoding scheme. The decoder translates instruction opcodes and function fields into ALU control signals for all R-type instructions (ADD, SUB, AND, OR, XOR, shifts, comparisons) and I-type arithmetic instructions (ADDI, logical immediates, shift immediates).

#### Branch Comparator Sub-module
Implemented a dedicated comparator that evaluates branch conditions using ALU flags and branch type, supporting all six variants (BEQ, BNE, BLT, BGE, BLTU, BGEU) through zero flags for equality, sign/overflow flags for signed comparisons, and unsigned comparison logic. This modular design proved valuable during pipelining - I simply relocated the comparator from the control unit to the Execute stage without significant redesign.

### Sign Extension Module

Developed the immediate value sign-extension module handling all RISC-V instruction formats (I-type, S-type, B-type, U-type, J-type). Each format has unique bit arrangements - for example, B-type splits a 13-bit immediate with implicit LSB across bits [31:25] and [11:7] with specific rearrangement, while J-type uses 21 bits with complex ordering across [31:12]. The module uses the opcode to determine the format, then extracts and sign-extends the appropriate bits to produce a full 32-bit signed immediate.

### Instruction Memory Module

Implemented the instruction memory interface with proper byte-addressable memory access and 32-bit instruction alignment. Collaborated with Archie on refining the byte addressing format to ensure compatibility with the memory subsystem and test infrastructure.

---

## Pipelined CPU Implementation

### Top-Level Architecture and Pipeline Registers

Redesigned the top-level module to support 5-stage pipelining (Fetch, Decode, Execute, Memory, Writeback), building upon Sam's single-cycle top-level architecture. This required:

**Pipeline Stage Separation**: Partitioned the single-cycle datapath into discrete stages with well-defined inputs and outputs.

**Pipeline Register Implementation**: Implemented all four inter-stage pipeline registers (F/D, D/E, E/M, M/W) with enable signals for stall handling, flush capability for control hazards, and metadata propagation. Archie reformatted and organized the pipeline registers to improve code readability and maintainability.

### Hazard Detection and Control Hazard Handling

Collaborated with Louis on the hazard unit implementation, with Louis focusing on data hazard forwarding and load-use stall detection, while I concentrated on control hazard detection and resolution. The control hazard implementation included:

**Control Hazard Identification**: Detection logic for branch and jump instructions in the pipeline:
- Branch instructions (opcode `7'b1100011`): BEQ, BNE, BLT, BGE, BLTU, BGEU
- Jump instructions: JAL (opcode `7'b1101111`) and JALR (opcode `7'b1100111`)

**Initial Static Not-Taken Prediction**: Implemented a baseline prediction strategy where:
- Branches are assumed not-taken by default
- Pipeline continues fetching sequential instructions
- On branch-taken or jump, the pipeline flushes incorrect instructions and redirects to the target

**Pipeline Flush Mechanism**: Designed flush control logic to insert NOPs into F/D and D/E registers, clearing all control signals (RegWrite, MemWrite, etc.) to ensure flushed instructions have no architectural effect.

**PC Selection Logic**: Implemented multiplexing between sequential PC (PC + 4) and branch/jump target addresses, handling redirection timing to minimize penalty cycles.

This static prediction baseline allowed Louis to proceed with data hazard forwarding and other team members to implement the multiply extension and cache subsystems while I developed the dynamic prediction system.

---

## Branch Prediction - Dynamic Prediction System

<img width="620" height="397" alt="Image" src="https://github.com/user-attachments/assets/53c4c2fd-3119-476f-a4a4-a0d2aafa374a" />

### Research and Design Selection

After researching various branch prediction strategies ([Correlating Branch Prediction](https://www.geeksforgeeks.org/computer-organization-architecture/correlating-branch-prediction/), [Branch Target Prediction - Imperial College](https://www.doc.ic.ac.uk/~phjk/AdvancedCompArchitecture/Lectures/pdfs/Ch03-part2-BranchTargetPrediction.pdf)), I selected a **2-bit saturating counter with Branch Target Buffer** architecture for its significant performance improvement over static prediction, manageable implementation complexity, and well-understood behavior. More sophisticated predictors (tournament, correlating) were out of scope for our project constraints.

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

![State transition diagram](https://media.geeksforgeeks.org/wp-content/uploads/20200520205206/pik11.png)

This saturating counter behavior means a branch must be mispredicted twice consecutively to fully change the prediction, which provides robustness against noise and temporary pattern changes.

**Update Timing**: The BHT updates during Execute stage when a branch completes (`branch_resolved_E`), the outcome is known, and not during pipeline flushes (critical to prevent learning corruption).

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

**Update and Miss Handling**:
Updates occur in parallel with BHT when branches resolve, writing the target address to the appropriate entry and setting the valid bit. On BTB misses (first encounter), the system falls back to static not-taken prediction, resolves in Execute, then updates BTB for future predictions - this cold-start penalty occurs only once per unique branch.

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
Initially, all jumps were treated as mispredictions. Through debugging, I refined this: JAL instructions can be predicted (PC-relative target cached in BTB), JALR uses static prediction (register-dependent target), with update logic: `update_predictor = branch_resolved_E || is_jal`. This significantly improved performance for function call-heavy code.

### Hazard Unit Integration with Prediction

Modified the hazard unit (in collaboration with Louis who handled data forwarding) to incorporate branch prediction:

**Prediction Metadata**: Added signals (`F_prediction_made`, `F_predicted_taken`) that propagate through D and E stages alongside instructions.

**Misprediction Detection**:
```systemverilog
if (E_Branch && E_prediction_made) begin
    branch_mispredict = (E_predicted_taken != branch_taken);
end
else if (E_Branch && !E_prediction_made) begin
    branch_mispredict = branch_taken;  // BTB miss
end
```

**Flush Control**: Flushes only on mispredictions or unpredicted taken branches. Correct predictions incur zero penalty.

**PC Update**: Selects between `PC_E + immediate` (predicted not-taken but taken) or `PC_E + 4` (predicted taken but not-taken).

---

## Debugging Challenges and Solutions

Throughout the implementation of branch prediction, I encountered several complex debugging challenges that required systematic analysis and careful solutions. These issues highlight the intricate interactions between pipeline control, prediction logic, and timing constraints in a pipelined processor.

### Pipeline Flush Timing Issues

**Problem**: Instructions were being lost during flushes - the first instruction after a branch would sometimes disappear, resulting in incorrect program execution or infinite loops.

**Investigation**: Traced through waveforms showing `F_instr` and `D_instr` values cycle-by-cycle during flush events. Discovered that `CTRL_Flush` was being asserted during the first few clock cycles after reset.

**Root Cause**: The `CTRL_Flush` signal was being asserted spuriously at startup due to uninitialized control signals propagating through the Execute stage. The hazard unit calculates `Flush = (Branch_E && branch_taken_E) || Jump_E`, and when these signals were undefined (X) or incorrectly high during reset, the flush would trigger inappropriately.

**Solution**: Added reset gating to the hazard unit to ensure flush logic only operates after proper initialization. Additionally, ensured all pipeline registers properly reset their control signals to known values (typically 0) to prevent X propagation.

### Instruction Corruption Bug

**Problem**: After implementing branch prediction, some instructions would become corrupted - displaying wrong opcodes or operands in the waveform viewer. This led to illegal instruction exceptions or incorrect computation results.

**Investigation**: Monitored instruction values through each pipeline stage (F_instr → D_instr → E_instr) to identify where corruption occurred. Found that prediction metadata signals (`prediction_made`, `predicted_taken`) were not being cleared during flushes.

**Root Cause**: When a flush occurred, the instruction itself was converted to a NOP (typically `32'h00000013`), but the prediction metadata signals continued to propagate with their old values. In subsequent cycles, these stale prediction signals would affect new instructions entering the pipeline, causing the hazard unit to make incorrect decisions about whether to flush or redirect.

**Solution**: Modified pipeline registers to explicitly clear prediction signals during flush operations, ensuring that flushed instructions carried no prediction metadata that could corrupt subsequent operation.

### BTB/BHT Clock Synchronization

**Problem**: The BTB would sometimes return incorrect targets even though the tag matched correctly. Performance testing showed unpredictable behavior where the same branch would sometimes hit in the BTB and sometimes miss, despite no apparent reason for the inconsistency.

**Investigation**: Examined BTB write and read timing in waveforms, checking for race conditions between update and lookup operations. Discovered that the BTB was using `negedge clk` for updates.

**Root Cause**: The initial BTB implementation used `negedge clk` for updates while pipeline registers used `posedge clk`. This created a race condition where:
1. Execute stage writes to BTB on falling edge
2. Fetch stage reads from BTB on rising edge
3. Depending on setup/hold timing, the read might get old or new data unpredictably

**Solution**: Standardized all sequential elements to use `posedge clk`, which eliminated timing violations and ensured predictable, deterministic behavior across all operating conditions.

### PC Target Management and Misprediction Types

**Problem**: After implementing branch prediction, the CPU would sometimes jump to incorrect addresses on mispredictions. Specifically, when branches were predicted taken but actually not-taken, the CPU would still jump to the branch target instead of continuing sequentially.

**Investigation**: Initially, all mispredictions used the same PC correction path - redirecting to the calculated branch target (`PCTarget` from Execute stage). Through waveform analysis, I identified cases where:
- Branch predicted taken (BTB provided target)
- Branch actually not-taken (should continue to PC+4)
- CPU incorrectly redirected to branch target instead of PC+4

This caused infinite loops in test programs and incorrect execution paths.

**Root Cause Analysis**: The hazard unit was receiving only a single target address (`PCTarget`) and couldn't distinguish between different types of mispredictions:
- **Predicted taken, actually not-taken**: Should redirect to PC+4 (sequential address)
- **Predicted not-taken, actually taken**: Should redirect to branch target
- **BTB target mismatch**: Predicted taken with wrong cached target address
- **First-time branch**: No prediction made, need to redirect if taken

**Solution - Misprediction Type Classification**: Redesigned the hazard unit to receive multiple signals and classify different misprediction scenarios. Required additional inputs:
- `E_btb_PCtarget`: The predicted target from BTB (for mismatch detection)
- `E_pc_out4`: PC+4 value from Execute stage (for not-taken correction)
- `E_prediction_made`: Whether a prediction was actually made
- `E_predicted_taken`: The direction that was predicted

Implemented misprediction classification logic:
```systemverilog
// Classify specific misprediction types
mispred_take     = Branch && branch_taken && !E_predicted_taken;
mispred_not_take = Branch && !branch_taken && E_predicted_taken;
target_mismatch  = (E_btb_PCtarget != PCTarget);

// Select correct recovery address based on misprediction type
if (Jump)
    Hazard_target = PCTarget;
else if (mispred_take)
    Hazard_target = PCTarget;
else if (mispred_not_take)
    Hazard_target = E_pc_out4;
else if (Branch && branch_taken && ~E_prediction_made)
    Hazard_target = PCTarget;
else
    Hazard_target = E_pc_out4;
```

Also refined branch misprediction detection to handle target mismatches:
```systemverilog
if (Branch) begin
    if (E_prediction_made) begin
        if (branch_taken) begin
            // Check direction AND target match
            branch_mispredict = (~E_predicted_taken) || target_mismatch;
        end else begin
            // Only check direction
            branch_mispredict = E_predicted_taken;
        end
    end else begin
        // No prediction: mispredict if taken
        branch_mispredict = branch_taken;
    end
end
```

**Impact**: This refinement was crucial for correct operation with dynamic prediction. The solution demonstrates the complexity of integrating prediction with hazard resolution - it's not enough to detect misprediction; you must also classify the type of misprediction to compute the correct recovery path.

### Preventing Predictor Update During Flushes

**Problem**: The branch predictor's accuracy was not improving as expected over time. Loops that should have quickly trained to "strongly taken" remained in weaker states, and some branches would oscillate between states unpredictably.

**Investigation**: Added counters to track BHT state changes and BTB updates. Discovered that the predictor was updating far more frequently than expected - multiple times per actual branch execution.

**Root Cause**: The predictor's `update_en` signal was being asserted whenever a branch instruction reached the Execute stage, regardless of whether that instruction was being flushed. This meant:
1. Branch mispredicts and triggers flush
2. Flushed instructions still in Execute stage update the predictor
3. Predictor learns from "ghost" branches that never actually completed
4. This corrupted the learning process with incorrect branch outcomes

**Solution**: Gated the predictor update signal to prevent updates during flush cycles:
```systemverilog
assign update_predictor = (branch_resolved_E || is_jal) && !CTRL_Flush;
```

This ensures the predictor only learns from instructions that actually complete their execution, not from those being discarded due to control hazards. This fix was essential for achieving the expected prediction accuracy and performance improvements.

### JAL vs JALR Differentiation

**Problem**: Jump instructions (both JAL and JALR) were always causing pipeline flushes and being counted as mispredictions, even after implementing branch prediction. This meant no performance improvement for code with function calls.

**Investigation**: Analyzed the behavior of JAL (unconditional PC-relative jump) versus JALR (unconditional register-indirect jump). JAL has a calculable target that could be predicted, while JALR's target depends on register values.

**Root Cause**: The initial implementation treated all jumps identically, always flushing for any jump.

**Solution**: Modified the hazard unit to distinguish between JAL and JALR using the opcode (`7'b1100111` for JALR), and check predictions for JAL. This allowed the branch predictor to cache JAL targets in the BTB and predict them correctly on subsequent executions, significantly improving performance for code with function calls. JALR instructions (typically used for function returns) still incur the misprediction penalty, but this is unavoidable without a dedicated Return Address Stack (RAS) structure.

---

## Performance Analysis and Testing

### Test Methodology

Developed comprehensive tests to validate the branch prediction system, verifying correctness (identical results to non-predicted execution) and measuring performance through cycle counters tracking execution cycles, mispredictions, and misprediction rate.

### Benchmark Results

**AddiBNE Test Program**: A loop-intensive program that executes a simple counter loop:

- **Static Prediction (baseline)**: 1277 cycles
- **Dynamic Prediction (2-bit + BTB)**: 771 cycles
- **Improvement**: 506 cycles saved, **~40% reduction**

This significant speedup demonstrates the effectiveness of the dynamic predictor on loop-heavy code, where branches exhibit strong temporal locality.

**Custom Predictor Stress Test (`predictor.s`)**:
Created tests with challenging patterns (rapidly alternating branches, nested loops, mixed biases) that validated correct handling of pathological cases, graceful performance degradation on unpredictable branches, and pattern learning within a few iterations.

### Analysis of Results

**Why the Improvement Occurs**: Loops typically have many taken-branch iterations before one not-taken exit. The 2-bit counter reaches ST state after two iterations, and correctly predicted taken branches have zero-cycle penalty. Only the final loop exit is mispredicted.

**Diminishing Returns on Complex Patterns**: The `predictor.s` tests showed minimal improvement on rapidly alternating branches, confirming theoretical 2-bit predictor limitations and validating expected behavior.

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
- Clear module interfaces for team integration (Louis: data forwarding, Archie: memory/formatting, Sam: single-cycle base)
- Git workflow with feature branches for parallel development
- Effective division of labor on hazard unit (control vs. data hazards)
- Code commenting and documentation
- Performance measurement and reporting

---

## Summary and Reflection

My contributions to the RISCV-Team7 project spanned from basic control logic to advanced microarchitectural optimizations. Working collaboratively with Louis on hazard detection (splitting control and data hazards), with Archie on memory interfaces and code organization, and building upon Sam's single-cycle architecture, I focused particularly on branch prediction implementation.

The branch prediction work required:

1. **Theoretical Understanding**: Research and algorithm selection
2. **Practical Implementation**: Hardware translation with proper timing
3. **Integration**: Combining prediction with existing hazard detection (coordinating with Louis's data forwarding logic)
4. **Debugging Rigor**: Systematic identification and resolution of timing/correctness issues
5. **Performance Validation**: Quantitative measurement and analysis

The dynamic branch prediction system achieved a **~40% cycle count reduction** on loop-intensive code while maintaining correctness. The project provided hands-on experience with hardware design challenges: pipeline complexity, performance-correctness trade-offs, and collaborative development.

---

## Repository Structure

All implementations are available in the RISCV-Team7 repository:
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