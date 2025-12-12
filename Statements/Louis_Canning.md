# My Contribution

This section documents my individual contribution to the Team RISC-V group project.  
I was primarily responsible for datapath components, memory elements, pipeline control, hazard handling, and architectural debugging across the CPU. The work covered both RTL development and microarchitectural correctness/performance validation.

---

## Core Hardware Contributions - Single Cycle

### Arithmetic Logic Unit (ALU)
- Designed and implemented the ALU supporting all required RV32I operations.
- Worked with adil to enable correct alu, control unit control
- **Recommended additions:**  
  - Insert ALU block diagram here (image).  
  - Add link to Verilog file (e.g., `rtl/alu.sv`).  
  - Add link to unit-test waveform screenshot.

---

### Register File
- Implemented the 32×32-bit register file with negedge synchronous writes and dual combinational reads.
- Handled x0 hardwiring, write-enable logic, and the rst signal reseting register values to 32'b0.
- **Recommended additions:**  
  - Add link to file (`rtl/regfile.sv`).  
  - Add commit demonstrating integration.

---

### Data Memory (DataMem)
- Implemented data memory for load/store instructions.
- Verified byte-array indexing, byte/half-word/word operations, and a sign extension signal for loading half-words and bytes into 32 bit.
- **Recommended additions:**  
  - Insert memory diagram or waveform.  
  - Add link to the module file (`rtl/datamem.sv`).

---

### Top-Level Integration & Debugging
- Conducted complete cpu debugging at the `top.sv` integration layer.
- Used provided assembly files, my own assembly instructions, and GTKWave to identify specific instructions causing issue
- Identified problematic assembly instructions to be:
  ```asm
   lbu  rd  imm(rs1)
  ```
  ```asm
  lbu  rd  imm(rs1)
  ```
- As these both involved the signed/unsigned input I first tracked this input on GTKWave and detected an error, it was the wrong value.
- I traced the wire into the control unit where the ouput driving this wire was called:
  ```verilog
  memUnsigned
  ```
- This had caused confusion for Sam when he was connecting up on the top level, and meant that the control unit asserted 1 for unsigned whereas the datamem expected 0 for unsigned.
- I modified the Control Unit to correct this, and also clean up some of the datamem relevant instructions with my knowledge from building it.
- You can see this in this commit [Top level debug](https://github.com/SAMOS-76/RISC-V-Team7/commit/1eb67f8c9796f942b4225ac20abad4cb5b40a267)
- Once this was fixed our single cycle cpu passed all tests - including pdf. 
- **Recommended additions:**  
  - Insert link to `rtl/top.sv`.  
  - Insert screenshot of full-system simulation.
 
### F1 program
- I wrote the assembly program for the f1.
- Used the rv32i isa to put together instructions to behave as desired
- Design was taken further / randomised / put on VBuddy by Sam.
 
---

## Pipeline Design & Hazard Handling
- Archie and Sam had implemented pipelining.
- I was tasked with modifying current hardware and developing a hazard unit to detect data hazards and resolve them in the most efficient way. 
- I used forwarding for data dependencies in the execute stage dependant on writebacks in either the mem or writeback stage.
- I used stalls + bubble insertion for load dependencies to simulate real word latency limitations of datamemory reading.
- Developed my own assembly files + testing script with GTest to thoroughly test all data dependencies and ensure correctness.
- **Recommended additions:**  
  - Insert datapath pipeline diagram.  
  - Add GIF of the pipeline running a test program.


### Forwarding - Top level
- Modified regfile to negedge write as is standard this resolves dependency between instruction currently in decode and writeback as the regfile is combinational read, the writtenback values can be be read into the D_E pipeline reg correctly.
- Designed Writeback to Ex and Mem to Ex forwarding paths with hazard unit controlled MUX's enabling forwarding.
- This is the mux controlling the forwarding.
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


### Forwarding - Hazard Unit
- Implemented combinational forwarding logic with mem stage forwarding priority if there is dependency in mem and writeback stages.
- Used enum types to make forwarding logic more maintainable:
  ```verilog
  typedef enum logic [1:0]{
    none = 2'b00,
    mem  = 2'b01,
    writeback = 2'b10
  } forward_type;
  ```
- Checks if register values that have been read are dependent on values being writen to in later stages.
- 
### Hazard Unit - opcode Check
I found an issue that isn't commonly mentioned: as the ra and rb values passed through to the execute stage come from the same bit field every time, which can represent immediate values in some instructions.
Which means that if you have an immediate value of #10, and previous instruction is loading to x10, this could incorrectly flag an issue and cause forwarding, this could also happen the other way round with an immmediate value in the rd of the writing instruction.
- Now theoritically this might not have a huge impact as the mux's in the execute pick the immediate values instead of the forwarded values anyway
- However, it is technically incorrect behaviour, which could have unexpected impacts in forwarding or stalling behaviour, so to be consistent and robust my hazard unit performs checks to see if the fields we are comparing between the execute stage and mem/writeback stage to see if there is a dependency are actually register fields, and then using this outcome to decide whether to forward/stall.
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

- This uses the opcode to check if the 'register' value passed through actually represents a register in that instruction type - not an imm.
- opcode check combines with wirte flags to producee 'reg_valid' flags that are used in comparisons to make sure only valid stall/forward operations occur.
- I modified the pipeline registers to save the opcode of the instruction in the stage to use in the hazard unit.


### Stalling
#### Implementation
- Checks if instruction in decode is dependent on a load instruction in execute.
  ```verilog
  assign A_L_haz = (E_opcode == 7'b0000011 && (((d_reg_a == ex_reg_d) && d_reg_1_valid) || ((d_reg_b == ex_reg_d) && d_reg_2_valid)));
  ```
- Modified D_E pipeline register to have no_op input that sets all values to 0 - producing a bubble in execute stage, load instruction continues to mem stage.
  Bubble mechanism:
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
- Makes PC_en, F_D_reg_en and D_E_reg_en low: instructions in fetch, and decode stall.

#### Comments + verilator limitation

Load stalls occur in physical cpu's because there is a delay on getting the data out the memory block, so it cant then be forwarded to the execute block as there won't be enough time for it to get there before the next tick.
A stall is used to hold back the instruction in execute - insert a noop bubble where it was - and allow the load instruction to move into the writeback stage - where it can be forwarded into the execute stage.

Verilator doesnt simulate these propagation delays - which means that it 'passes' all load hazard tests without stalling. However conceptually it is very important to implement to understand, so I implemented.

##### So how did I know it was stalling and passing instead of just not stalling and passing?

I wouldnt just b happy with all the tests passing - I needed to check that all the stalls that should occur, had occured. I used gtkwave to track the number of no-op signals and compared this to the expected number of stalls from the program.
My implementation met this expectation which signals that it was correctly implementing the stalls - behaving like a real cpu, with timing closure in mind.


### Custom Hazard Testing Scripts
Hazards by nature are rare exceptions that need to be handled correctly to ensure that the processor performs accurately and consistently with ALL possible commands, it is essential that it is extremely well teste to ensure it correctly handles all cases. It is for this reason I developed a directory containing my own custom assembly instructions - aiming to ramp up in complexity and target different potential weaknesses until Im confident the hazard unit functions correctly
I targeted potential bug-points such as:
- forwarding into either register or both
- checking mem forward priority is implemented
- checking forwarding occurs correctly for data AND address for load and store instruction
- continuous rewrites to the same register
- load hazards
- multiple sequential loads with a dependent instruction after
- multiple instructions dependent on a single load

After this I modified the provided verify.cpp and doit.sh to run and test the cpu with those assembly files I developed, storing the output waveform in its own folder.
This was very helpful and enabled me to pinpoint issues in the cpu quickly, other team members later adopted these scripts and used it to test the cpu with their own custom assembly instructions.

---

### Control Hazard Debugging (with Adil)
- Assisted in diagnosis and correction of control-hazard behavior in branch and jump sequences.
- Verified the interactions between pipeline flush logic, PC selection, and instruction fetch.
- We developed several testing programs and extensively used GTKWave to find why it was incorrectly jumping / branching
- We identified the issue and corrected it, enabling the cpu to pass all of our own (control and data hazards) and the provided programs.



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
