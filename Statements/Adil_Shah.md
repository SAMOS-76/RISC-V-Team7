# Personal Statement - Adil Shah
## RISCV-Team7 CPU Design Project

For the RISC-V CPU design project, I made contributions across both the single-cycle and pipelined implementations. My work focused on control logic design, pipeline architecture, and performance optimizations through dynamic branch prediction.

---

## Single-Cycle CPU Implementation

### Control Unit Design

I designed and implemented the main control unit responsible for decoding all RISC-V RV32I instructions and generating appropriate control signals. The control unit architecture utilized a hierarchical approach with two key sub-modules:

#### ALU Decoder Sub-module
Worked with Louis to define the ALU operation encoding scheme. The decoder translates instruction opcodes and function fields into ALU control signals for all R-type instructions (ADD, SUB, AND, OR, XOR, shifts, comparisons) and I-type arithmetic instructions (ADDI, logical immediates, shift immediates).

#### Branch Comparator Sub-module
Implemented a dedicated comparator that evaluates branch conditions using ALU flags and branch type, supporting all six variants (BEQ, BNE, BLT, BGE, BLTU, BGEU). This modular design proved valuable during pipelining - I simply relocated the comparator from the control unit to the Execute stage without significant redesign.

### Sign Extension Module

Developed the immediate value sign-extension module handling all RISC-V instruction formats (I-type, S-type, B-type, U-type, J-type). Each format has unique bit arrangements - for example, B-type splits a 13-bit immediate across bits [31:25] and [11:7], while J-type uses 21 bits with complex ordering. The module uses the opcode to determine the format, then extracts and sign-extends the appropriate bits.

### Instruction Memory Module

Implemented the instruction memory interface with proper byte-addressable memory access and 32-bit instruction alignment. Collaborated with Archie on refining the byte addressing format to ensure compatibility with the memory subsystem.

---

## Pipelined CPU Implementation

### Top-Level Architecture and Pipeline Registers

Redesigned the top-level module to support 5-stage pipelining (Fetch, Decode, Execute, Memory, Writeback), building upon Sam's single-cycle architecture. Implemented all four inter-stage pipeline registers (F/D, D/E, E/M, M/W) with enable signals for stall handling, flush capability for control hazards, and metadata propagation. Archie reformatted and organized the pipeline registers to improve code readability.

### Hazard Detection and Control Hazard Handling

Collaborated with Louis on the hazard unit implementation - Louis focused on data hazard forwarding and load-use stall detection, while I concentrated on control hazard detection and resolution:

**Control Hazard Identification**: Detection logic for branch (opcode `7'b1100011`) and jump instructions (JAL: `7'b1101111`, JALR: `7'b1100111`).

**Static Not-Taken Prediction**: Implemented baseline prediction where branches are assumed not-taken by default, with pipeline flushes on branch-taken or jumps.

**Pipeline Flush Mechanism**: Designed flush control logic to insert NOPs into F/D and D/E registers, clearing all control signals to ensure flushed instructions have no architectural effect.

This baseline allowed Louis to proceed with data hazard forwarding and other team members to implement multiply/cache extensions while I developed dynamic prediction.

---

## Branch Prediction - Dynamic Prediction System

<div align="center">
  <img src="https://github.com/user-attachments/assets/53c4c2fd-3119-476f-a4a4-a0d2aafa374a" alt="Branch Prediction Architecture" width="620" />
  <br>
  <em>Branch Prediction System Architecture</em>
</div>

### Research and Design Selection

After researching various strategies ([Correlating Branch Prediction](https://www.geeksforgeeks.org/computer-organization-architecture/correlating-branch-prediction/), [Branch Target Prediction - Imperial College](https://www.doc.ic.ac.uk/~phjk/AdvancedCompArchitecture/Lectures/pdfs/Ch03-part2-BranchTargetPrediction.pdf)), I selected a **2-bit saturating counter with Branch Target Buffer** architecture for its significant performance improvement, manageable implementation complexity, and well-understood behavior.

### Branch History Table (BHT) Implementation

The BHT uses 2-bit saturating counters to learn branch behavior over time.

**Architecture Details**:
- **Table Size**: Parameterized with `INDEX_BITS = 4` (16 entries, configurable to 64/256)
- **Indexing**: Uses PC bits `[INDEX_BITS+1:2]` (ignores lower 2 bits for 4-byte alignment)
- **State Encoding**: SNT (`2'b00`), WNT (`2'b01`), WT (`2'b10`), ST (`2'b11`)

**Prediction Logic**:
```systemverilog
predict_taken = bht[index_F][1];  // MSB indicates taken (1) or not-taken (0)
```

**Update State Machine**:

<div align="center">
  <img src="https://media.geeksforgeeks.org/wp-content/uploads/20200520205206/pik11.png" alt="State transition diagram" width="500" />
  <br>
  <em>2-bit Saturating Counter State Machine</em>
</div>

This saturating counter behavior requires two consecutive mispredictions to fully change prediction, providing robustness against noise.

**Update Timing**: Updates during Execute stage when branches complete, with updates disabled during flushes (critical to prevent learning corruption).

### Branch Target Buffer (BTB) Implementation

The BTB caches branch target addresses, eliminating Execute stage target calculation for predicted-taken branches.

**Architecture**:
- **Entry Structure**: `valid` bit, `tag` field (`PC[31:INDEX_BITS+2]`), 32-bit `target` address
- **Lookup**: BTB hit indicates cached target available
- **Updates**: Parallel with BHT when branches resolve
- **Miss Handling**: Falls back to static not-taken, resolves in Execute, updates BTB (one-time penalty)

### Branch Predictor Integration Module

```systemverilog
predict_taken_F  = bht_predict_taken && btb_hit;
predict_target_F = btb_target;
predict_valid_F  = btb_hit;    
```

**Critical Design**: Predictor only generates predictions on BTB hit, ensuring no speculative execution on first-time branches with unknown targets.

**JAL Handling**: Initially all jumps were mispredictions. Refined to: JAL predicted (PC-relative target cached in BTB), JALR uses static prediction (register-dependent). Update logic: `update_predictor = branch_resolved_E || is_jal`.

### Hazard Unit Integration with Prediction

Modified hazard unit (coordinating with Louis's data forwarding logic) to incorporate branch prediction:

**Prediction Metadata**: Added `F_prediction_made`, `F_predicted_taken` signals propagating through pipeline stages.

**Misprediction Detection**:
```systemverilog
if (E_Branch && E_prediction_made) begin
    branch_mispredict = (E_predicted_taken != branch_taken);
end
else if (E_Branch && !E_prediction_made) begin
    branch_mispredict = branch_taken;  // BTB miss
end
```

**Flush Control**: Flushes only on mispredictions or unpredicted taken branches. Correct predictions have zero penalty.

---

## Debugging Challenges and Solutions

### Pipeline Flush Timing Issues

**Problem**: Instructions were being lost during flushes - the first instruction after a branch would sometimes disappear, resulting in incorrect program execution or infinite loops.

**Investigation**: Traced through waveforms showing `F_instr` and `D_instr` values cycle-by-cycle during flush events. Discovered that `CTRL_Flush` was being asserted during the first few clock cycles after reset.

**Root Cause**: The `CTRL_Flush` signal was being asserted spuriously at startup due to uninitialized control signals. The hazard unit calculates `Flush = (Branch_E && branch_taken_E) || Jump_E`, and when these signals were incorrectly high during reset, the flush would trigger inappropriately.

**Solution**: Added reset gating to hazard unit to ensure flush logic only operates after proper initialization. Additionally, ensured all pipeline registers properly reset their control signals to known values.

### Instruction Corruption Bug

**Problem**: After implementing branch prediction, some instructions would become corrupted - displaying wrong opcodes or operands in the waveform viewer. This led to illegal instruction exceptions or incorrect computation results.

**Investigation**: Monitored instruction values through each pipeline stage (F_instr → D_instr → E_instr) to identify where corruption occurred. Found that prediction metadata signals (`prediction_made`, `predicted_taken`) were not being cleared during flushes.

**Root Cause**: When a flush occurred, the instruction itself was converted to a NOP (typically `32'h00000013`), but the prediction metadata signals continued to propagate with their old values. In subsequent cycles, these stale prediction signals would affect new instructions entering the pipeline, causing the hazard unit to make incorrect decisions about whether to flush or redirect.

**Solution**: Modified pipeline registers to explicitly clear prediction signals during flush operations, ensuring that flushed instructions carried no prediction metadata that could corrupt subsequent operation.

### PC Target Management and Misprediction Types

**Problem**: CPU jumped to incorrect addresses on mispredictions - particularly predicted-taken-but-not-taken scenarios jumping to target instead of PC+4.

**Root Cause**: Hazard unit received only single target address, couldn't distinguish misprediction types:
- Predicted taken, actually not-taken → needs PC+4
- Predicted not-taken, actually taken → needs branch target
- BTB target mismatch → needs correct target
- First-time branch → needs target if taken

**Solution**: Redesigned hazard unit with misprediction type classification:

```systemverilog
// Classify misprediction types
mispred_take     = Branch && branch_taken && !E_predicted_taken;
mispred_not_take = Branch && !branch_taken && E_predicted_taken;
target_mismatch  = (E_btb_PCtarget != PCTarget);

// Select correct recovery address
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

Required additional inputs: `E_btb_PCtarget`, `E_pc_out4`, `E_prediction_made`, `E_predicted_taken`.

### Preventing Predictor Update During Flushes

**Problem**: The branch predictor's accuracy was not improving as expected over time. Loops that should have quickly trained to "strongly taken" remained in weaker states, and some branches would oscillate between states unpredictably.

**Investigation**: Added counters to track BHT state changes and BTB updates. Discovered that the predictor was updating far more frequently than expected - multiple times per actual branch execution.

**Root Cause**: The predictor's `update_en` signal was being asserted whenever a branch instruction reached the Execute stage, regardless of whether that instruction was being flushed. This meant: (1) Branch mispredicts and triggers flush, (2) Flushed instructions still in Execute stage update the predictor, (3) Predictor learns from "ghost" branches that never actually completed, (4) This corrupted the learning process with incorrect branch outcomes.

**Solution**: Gated the predictor update signal to prevent updates during flush cycles:
```systemverilog
assign update_predictor = (branch_resolved_E || is_jal) && !CTRL_Flush;
```
This ensures the predictor only learns from instructions that actually complete their execution, not from those being discarded due to control hazards. This fix was essential for achieving the expected prediction accuracy and performance improvements.

### JAL vs JALR Differentiation

**Problem**: Jump instructions (both JAL and JALR) were always causing pipeline flushes and being counted as mispredictions, even after implementing branch prediction. This meant no performance improvement for code with function calls.

**Investigation**: Analyzed the behavior of JAL (unconditional PC-relative jump) versus JALR (unconditional register-indirect jump). JAL has a calculable target that could be predicted, while JALR's target depends on register values.

**Root Cause**: The initial implementation treated all jumps identically:
```systemverilog
else if (Jump) begin
    branch_mispredict = 1'b1;  // Always flush for any jump
end
```

**Solution**: Modified hazard unit to distinguish between JAL and JALR using opcode (`7'b1100111` for JALR), and check predictions for JAL. This allowed the branch predictor to cache JAL targets in the BTB and predict them correctly on subsequent executions, significantly improving performance for code with function calls. JALR instructions (typically used for function returns) still incur the misprediction penalty, but this is unavoidable without a dedicated Return Address Stack (RAS) structure.

---

## Performance Analysis and Testing

### Benchmark Results

**AddiBNE Test Program** (loop-intensive):

<div align="center">

| Prediction Type | Cycles | Improvement |
|----------------|--------|-------------|
| Static (baseline) | 1277 | - |
| Dynamic (2-bit + BTB) | 771 | **~40% reduction** |

</div>

This demonstrates the effectiveness on loop-heavy code with strong temporal locality.

**Custom Predictor Stress Test (`predictor.s`)**: Validated correct handling of pathological cases (alternating branches, nested loops, mixed biases), graceful degradation on unpredictable patterns, and learning within iterations. Similar results of loop heavy code having an almost 40% improvement in the best case and in alternating cases it was less effective as expected.

### Analysis

**Why Improvement Occurs**: Loops have many taken-branch iterations before one not-taken exit. 2-bit counter reaches ST state after two iterations, correctly predicted taken branches have zero-cycle penalty.

**Diminishing Returns**: Minimal improvement on rapidly alternating branches confirms theoretical 2-bit predictor limitations.

---

## Lessons Learned and Reflections

### What I Would Do Differently

**More Upfront Research**: The most significant lesson was the importance of comprehensive research before implementation. Discovering the sheer variety of branch prediction approaches (correlating predictors, gshare, tournament predictors, perceptron-based) partway through development was both fascinating and frustrating. I found myself wanting to try alternative implementations but was constrained by project timelines.

**Better Approach**: I would allocate 2-3 days at the start specifically for researching implementation options. This would have:
- Prevented discovering better suited models mid-implementation
- Allowed more informed architectural decisions
- Potentially led to better design choices (e.g., larger BTB, different indexing schemes)

**Systematic Testing Earlier**: I developed comprehensive tests late in the process. Earlier test-driven development would have caught bugs like the flush-update corruption sooner, saving significant debugging time.

**Documentation as I Go**: Writing documentation retrospectively meant reconstructing reasoning. Maintaining a design journal throughout would have preserved decision rationale and simplified the personal statement writing process.

---

## Future Work and Extensions

Given more time, several extensions would significantly enhance the CPU:

### Advanced Branch Prediction

**Tournament Predictor**: Combine multiple prediction schemes (e.g., 2-bit local + global history predictor) with a meta-predictor selecting the best predictor per branch. This addresses the 2-bit predictor's weakness on complex patterns while maintaining its strength on simple loops.

**Return Address Stack (RAS)**: A dedicated stack for function return addresses would eliminate JALR mispredictions for function returns, which currently incur a 3-cycle penalty. This would significantly improve performance for code with frequent function calls.

**Larger Tables**: Increasing `INDEX_BITS` from 4 to 8 (256 entries) would reduce aliasing conflicts where multiple branches map to the same predictor entry.

### Floating-Point Extension (RV32F)

The RISC-V RV32F floating-point extension would add single-precision floating-point support. Key implementation challenges:
- **Separate FP register file**: 32 floating-point registers (`f0`-`f31`)
- **FP ALU**: Pipelined floating-point adder, multiplier, divider
- **Format conversion**: Integer ↔ floating-point conversion units
- **Pipeline integration**: Likely requiring deeper pipeline stages for FP operations

This would enable scientific computing workloads and demonstrate handling multiple execution units.

### Superscalar Implementation

A dual-issue superscalar design would execute two instructions simultaneously when independent. This requires:
- **Dual instruction fetch**: Fetch two aligned instructions per cycle
- **Dependency checking**: Hardware to detect WAR, WAW, RAW hazards between parallel instructions
- **Dual execution units**: Two ALUs, potentially shared memory unit
- **Instruction retirement**: In-order commit to maintain precise exceptions
- **Branch prediction impact**: Predicting two branch outcomes becomes complex

Expected speedup: 1.3-1.6x on IPC (instructions per cycle) for typical code with sufficient instruction-level parallelism.

### Out-of-Order Execution

The most ambitious extension - allowing instructions to execute out of program order while maintaining precise architectural state. Requires:
- **Reservation stations**: Buffer instructions awaiting operands
- **Reorder buffer (ROB)**: Track in-flight instructions for in-order commit
- **Register renaming**: Eliminate false dependencies (WAR, WAW)
- **Complexity**: ~5-10x design complexity of current in-order pipeline

This represents a major architectural shift but would provide significant performance on modern workloads.

---

## Technical Skills Demonstrated

### SystemVerilog Design
- Parameterized module design for scalability
- Proper combinational vs. sequential logic separation
- Clock domain understanding and synchronization

### Computer Architecture Principles
- Pipeline hazards and resolution
- Branch prediction algorithms and trade-offs
- Timing constraints and critical paths
- Performance analysis techniques

### Debugging Methodology
- Systematic waveform analysis
- Root cause analysis
- Incremental testing and validation

### Collaboration and Documentation
- Clear module interfaces (Louis: data forwarding, Archie: memory/formatting, Sam: single-cycle base)
- Git workflow with feature branches
- Effective division of labor
- Performance measurement

---

## Summary

My contributions to the RISCV-Team7 project spanned from basic control logic to advanced microarchitectural optimizations. Working collaboratively with Louis (hazard detection), Archie (memory interfaces/organization), and building upon Sam's single-cycle architecture, I focused particularly on branch prediction implementation. The team communicated well, worked to the set milestones on time and were extremely helpful when hitting a roadblock with debugging.

The branch prediction work required theoretical understanding, practical hardware translation, integration with existing hazard detection, systematic debugging, and quantitative performance validation. The dynamic branch prediction system achieved a **~40% cycle count reduction** on loop-intensive code while maintaining correctness.

The project provided invaluable hands-on experience with hardware design challenges: pipeline complexity, performance-correctness trade-offs, collaborative development, and the importance of thorough upfront research in making informed design decisions.

---

## Repository Structure

All implementations are available in the RISCV-Team7 repository:
- **Control Unit:** `rtl/control_unit.sv`
- **Instruction Memory:** `rtl/instrMem.sv`
- **Sign Extend module:** `rtl/sign_extend.sv`
- **Branch:** `Branch-Prediction` (feature branch)
- **Key Files**: 
  - `rtl/branch_history_table.sv` - BHT implementation
  - `rtl/branch_target_buffer.sv` - BTB implementation  
  - `rtl/branch_predictor.sv` - Top-level predictor module
  - `rtl/hazard_unit/hazard_unit.sv` - Integrated hazard detection
  - `rtl/top.sv` - Pipeline integration
  - `tb/asm/predictor.s` - Branch prediction stress test
