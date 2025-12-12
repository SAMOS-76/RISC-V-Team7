# My Contribution

This section documents my individual contribution to the Team RISC-V group project.  
I was primarily responsible for datapath components, memory elements, pipeline control, hazard handling, and architectural debugging across the CPU. The work covered both RTL development and microarchitectural correctness/performance validation.

---

## Core Hardware Contributions

### Arithmetic Logic Unit (ALU)
- Designed and implemented the ALU supporting all required RV32I operations.
- Verified correct flag generation, combinational timing, and operand routing.
- **Recommended additions:**  
  - Insert ALU block diagram here (image).  
  - Add link to Verilog file (e.g., `rtl/alu.sv`).  
  - Add link to unit-test waveform screenshot.

---

### Register File
- Implemented the 32×32-bit register file with synchronous writes and dual combinational reads.
- Handled x0 hardwiring, write-enable logic, and cross-module interfacing with decode and execute stages.
- **Recommended additions:**  
  - Add link to file (`rtl/regfile.sv`).  
  - Add commit demonstrating integration.

---

### Data Memory (DataMem)
- Implemented on-chip data memory for load/store instructions.
- Verified byte-array indexing, alignment correctness, and data forwarding interactions.
- **Recommended additions:**  
  - Insert memory diagram or waveform.  
  - Add link to the module file (`rtl/datamem.sv`).

---

## Pipeline Design & Hazard Handling

### Pipeline Implementation
- Integrated the IF, ID, EX, MEM, and WB stages into a fully pipelined RV32I CPU.
- Designed pipeline registers and stage-to-stage data/control signal propagation.
- Ensured full ISA-level correctness through multi-stage execution.
- **Recommended additions:**  
  - Insert datapath pipeline diagram.  
  - Add GIF of the pipeline running a test program.

---

### Data Hazard Resolution
Developed and integrated a complete data hazard subsystem:

#### Forwarding Unit
- Designed EX-to-EX, MEM-to-EX, and MEM-to-ID forwarding paths.
- Implemented combinational forwarding logic with priority ordering.

#### Stalling & Hazard Detection
- Created stall conditions for load-use hazards.
- Coordinated stall/flush signals across pipeline registers.

#### Custom Hazard Testing Scripts
- Wrote custom automated test programs and scripts to stress hazard behavior.
- Covered:
  - Back-to-back dependent ALU operations  
  - Load-use cases  
  - Mixed ALU/memory/branch dependency chains  
- **Recommended additions:**  
  - Insert link to hazard test scripts directory.  
  - Add waveform screenshot showing forwarding and stall timing.

---

### Control Hazard Debugging (with Adil)
- Assisted in diagnosis and correction of control-hazard behavior in branch and jump sequences.
- Verified the interactions between pipeline flush logic, PC selection, and instruction fetch.
- Contributed to debugging issues involving:
  - Incorrect PC redirection
  - Early/late flush events
  - Jump target generation
- **Recommended additions:**  
  - Add link to commits related to control hazard fixes.  
  - Add before/after diagrams of control logic.

---

## Top-Level Integration & Debugging
- Conducted cross-module debugging at the `top.sv` integration layer.
- Identified mismatches in control-signal timing, pipeline register propagation, and hazard interactions.
- Coordinated testing with teammates to validate end-to-end program execution.
- **Recommended additions:**  
  - Insert link to `rtl/top.sv`.  
  - Insert screenshot of full-system simulation.

---

# Performance Analysis and Testing

## Test Methodology

### Correctness Testing
Developed comprehensive test programs to validate that predicted execution produced identical architectural state (register file + memory) compared to a baseline non-predicted pipeline.

### Performance Measurement
Implemented cycle-counting infrastructure to track:
- Total cycle count  
- Number of mispredictions (flush events)  
- Misprediction rate  

**Recommended additions:**  
- Link to testbench counter code  
- Screenshot of waveform showing cycle counter increments  

---

## Benchmark Results

### AddiBNE Loop Program
A loop-heavy benchmark with a simple increment + branch structure.

| Predictor | Cycle Count | Notes |
|----------|-------------|-------|
| Static (baseline) | 1277 cycles | Predict-not-taken |
| Dynamic (2-bit + BTB) | 771 cycles | Full predictor pipeline |

**Improvement:** 506 cycles saved (~40% faster).

Shows strong effectiveness of the dynamic predictor on predictable loop patterns.

---

### Custom Predictor Stress Test (`predictor.s`)
Purposefully difficult branch patterns tested:
- Rapid alternation (worst-case for 2-bit saturating counters)
- Nested loops with different iteration counts
- Mixed biases and non-uniform behavior

Results showed:
- Correctness maintained even in pathological cases  
- Performance gracefully degrades to static baseline when prediction is impossible  
- Predictor learns stable patterns after a few iterations  

**Recommended additions:**  
- Link to `tb/asm/predictor.s`.  
- Add waveform showing prediction state transitions.

---

## Analysis of Results

### Why the Predictor Improves Performance
- Loop branches are taken repeatedly, then fall through once.  
- 2-bit counters quickly saturate to strongly-taken state.  
- Correct predictions = zero penalty; pipeline continues uninterrupted.  
- Only the final exit branch is mispredicted.

### Behavior on Complex Patterns
- Alternating patterns prevent counters from stabilizing.  
- Performance approaches static prediction, validating expected theoretical limits.

---

# Technical Skills Demonstrated

### SystemVerilog RTL Design
- Parameterized module development  
- Use of `typedef` and `struct` for clean interfaces  
- Proper synthesis-safe separation of sequential vs. combinational logic  
- Understanding of clocking, timing, and critical paths  

### Computer Architecture
- Pipeline design, data/structural hazards, control hazards  
- Branch prediction algorithms and design trade-offs  
- Performance profiling and cycle-accurate measurement  

### Debugging Methodology
- Systematic waveform-driven debugging  
- Failure mode isolation  
- Incremental integration and test-driven verification  

### Collaboration & Documentation
- Clean module interfaces for team integration  
- Effective Git branching workflow  
- Clear commit messages and inline documentation  
- Reproducible performance analysis  

---

# Summary and Reflection

My contributions spanned core datapath development, pipeline implementation, hazard resolution, microarchitectural debugging, and performance optimization.  
The branch prediction subsystem—which delivered approximately **40% cycle reduction** on loop-focused code—was particularly challenging and rewarding. It required:

- Algorithmic understanding  
- Careful hardware implementation  
- Tight integration with pipeline control logic  
- Rigorous correctness and performance validation  

This project provided deep, hands-on exposure to CPU design challenges: timing, hazards, correctness versus performance trade-offs, and collaborative hardware development.

---

# Repository Structure (Relevant to My Work)

Below are the files most closely associated with my contributions.  
**Replace the placeholders with actual links** once added to GitHub.
