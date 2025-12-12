# RISC-V 32IM CPU

## Introduction
We developed four distinct CPUs: a single-cycle processor, pipelined RV32IM, pipelined with cache, pipelined with branch prediction and a pipelined CPU that combines all cache multiply & branch prediction capabilities.

## Quick Access
- **`main` branch**: Final Pipelined CPU with multiply, data cache and branch prediction capabilites combined.
- **`SingleCycle` branch**: Verified single-cycle CPU
- **`*MUL` branch**: Pipelined RV32IM perofrming complex maths instructions
- **`Cache-final` branch**: Pipelined with Cache
- **`Branch Prediction` branch**: Pipelined with branch prediction
- *some branches left for other utiilties and referencing, but all inherit from their main function name eg Cache, Mul, Pipelined etc* 

## Project Progression

<p align="center">
  <img width="1348" height="348" alt="image" src="https://github.com/user-attachments/assets/03a4a94f-fa6a-4048-80e9-199f22cce99d" />
</p>

## The Team

<div align="center">

| Name | Personal Statement |
|------|-------------------|
| Samuel Amos-Osebeyo | [Statement](./personal%20statements/) |
| Louis Canning | [Statement](./personal%20statements/) |
| Archie Kendall | [Statement](./personal%20statements/) |
| Adil Shah | [Statement](./personal%20statements/) |

</div>

### Project Structure
```
.
├── .gitignore
├── ReadMe.md
├── rtl
│   ├── adder.sv
│   ├── branch_prediction
│   │   ├── branch_history_table.sv
│   │   ├── branch_predictor.sv
│   │   └── branch_target_buffer.sv
│   ├── decode
│   │   ├── D_E_reg.sv
│   │   ├── alu_decoder.sv
│   │   ├── control_unit.sv
│   │   ├── decode.sv
│   │   ├── regfile.sv
│   │   └── sign_extend.sv
│   ├── execute
│   │   ├── E_M_reg.sv
│   │   ├── alu.sv
│   │   ├── branch_comparator.sv
│   │   ├── div.sv
│   │   └── execute.sv
│   ├── fetch
│   │   ├── F_D_reg.sv
│   │   ├── fetch.sv
│   │   ├── instrMem.sv
│   │   └── pc_reg.sv
│   ├── hazard_unit
│   │   ├── control_hazard.sv
│   │   └── hazard_unit.sv
│   ├── memory
│   │   ├── M_W_reg.sv
│   │   ├── cache.sv
│   │   ├── cache_L1.sv
│   │   ├── cache_controller.sv
│   │   ├── cache_data_parser.sv
│   │   ├── datamem.sv
│   │   └── memory.sv
│   ├── mux.sv
│   ├── mux4.sv
│   ├── top.sv
│   └── writeback
│       └── writeback.sv
└── tb
    ├── Units
    │   ├── Testing_Guide.md
    │   ├── [testbench headers]
    │   ├── [verify implementations]
    │   └── doitunit.sh
    ├── asm
    │   ├── 1_addi_bne.s
    │   ├── 2_li_add.s
    │   ├── 3_lbu_sb.s
    │   ├── 4_jal_ret.s
    │   ├── 5_pdf.s
    │   ├── f1.s
    │   └── predictor.s
    ├── cache_testing
    │   └── [cache test assemblies]
    ├── hazards_test_asm
    │   ├── [data hazard tests]
    │   ├── div.s
    │   └── mul.s
    ├── custom_tests
    │   ├── custom_cpu_testbench.h
    │   └── custom_verify.cpp
    ├── reference
    │   └── [PDF reference materials]
    ├── assemble.sh
    ├── cacheit.sh
    ├── custom_doit.sh
    └── doit.sh
```

## Running the Project

All commands should be executed from the `/tb` directory or the subsequent test folder
```use +chmod +x *<scriptname>```  *to give yourself access*

<div align="center">

| Command | Purpose |
|---------|---------|
| `./doit.sh` | Execute standard test suite |
| `./doitunit.sh [unit name]` | Run module tests in Units folder |
| `./custom_doit.sh` | Run our directory of our own tests |
| `./pdf.sh [distribution name]` | Run PDF distribution visualization |
| `./f1.sh` | Run F1 starting lights simulation |
| `./cacheit.sh` | Run Cache Test suite and performance tests

</div>

---

## Single Cycle Implementation
<img width="1810" height="1028" alt="ICA-ALAS-EXAMPLE - Page 13" src="https://github.com/user-attachments/assets/ae4a27e7-325e-446e-9207-5a62b0c3f370" />

### Design Overview
Our single-cycle CPU implements the complete RV32I instruction set, enabling single-cycle execution of arithmetic, logical, memory, and control flow operations.

### Module Contributions

<div align="center">

| Component | Samuel | Louis | Archie | Adil |
|-----------|--------|-------|--------|------|
| Program Counter | x | | | |
| ALU | | x | | |
| Register File | | x | | |
| Instruction Memory | | | x | x |
| Control Unit | | | | x |
| Sign Extension | | | | x |
| Data Path Integration | x | x | | |
| Data Memory | | x | x | |
| Top-Level Assembly | x | x | | |
| Unit Testing | | | x | |
| Integration Testing | | x | x | |
| F1 Program | x | | | |
| Vbuddy integration | x | | | |

</div>

### Testing & Verification

<p align="center">
  <img width="414" height="308" alt="Single cycle test results" src="https://github.com/user-attachments/assets/ae19b3ca-cd87-465d-a798-5379ba36bf8f" />
</p>

### Integration onto VBuddy


#### F1 Starting Lights Sequence

Our F1 implementation demonstrates correct timing and state machine behavior:

https://github.com/user-attachments/assets/702fc385-e185-4802-9f70-d9fd016ca3c9

https://github.com/user-attachments/assets/0647b38b-375b-400a-8f1c-8b7e6f01f379

https://github.com/user-attachments/assets/7b674cfa-fa40-462f-b8c4-2e32a44cbaa1

https://github.com/user-attachments/assets/b1ecc930-c15e-4e76-9a75-f5d051aa57e9

#### PDF Distribution Tests

Successfully visualizes probability distributions with proper data handling:

**Gaussian Distribution**: Smooth bell curve with correct statistical properties

**Noisy Distribution**: Demonstrates proper random number generation

**Triangle Distribution**: Linear probability distribution correctly implemented

**Implementation Detail**: To achieve smooth visualization, we display values every 3 clock cycles:
```cpp
bool is_paused = vbdFlag();
top->trigger = is_paused;
if (!is_paused) {
    j++;
    if (j % 3 == 0) {
        vbdCycle(j);
        vbdPlot(top->a0, 0, 255);
    }
}
```

---

## Pipelined Implementation
<img width="891" height="520" alt="image" src="https://github.com/user-attachments/assets/72d564ac-dfd6-4343-b2bb-9b7d3f8027bf" />



### Architecture Overview
Our pipelined processor achieves higher throughput through instruction-level parallelism across four pipeline stages: fetch, decode, execute, and memory. This design processes multiple instructions concurrently, with each stage handling a different instruction simultaneously. As well as continuing to pass key fundamental tests. 

**Key Features:**
- Full RV32IM instruction set support
- Data and Control Hazard Detection with forwarding and stalling

### Testing & Validation

We developed custom testing scripts to test our specialised assembly files to ensure the design behaved as desired.

<p align="center">
  <img width="853" height="595" alt="image" src="https://github.com/user-attachments/assets/d9592c7a-84ae-434f-8503-0933824459d1" />
</p>

---

## Implementing Further Extensions

### Integration Overview
<img width="3498" height="2086" alt="ICA-ALAS-EXAMPLE - Page 13 (2)" src="https://github.com/user-attachments/assets/298ec862-6f0b-4bc2-9c57-cbcbbf186d05" />


**Our extensions:**
These were all done on a fully pipelined cpu and all worked correctly
- RV32IM extension
- Branch Prediction
- Cache

### Extention Contributions

<div align="center">

| Component | Samuel | Louis | Archie | Adil |
|-----------|--------|-------|--------|------|
| Pipelining | x | x | x | x |
| Forwarding | | x | | |
| Load stalls | | x | | |
| Control Hazards | | | | x |
| Branch Predictions | | | | x |
| Pipeline debug | | x | | x |
| RV32IM extension | x | | | |
| Cache | | | x | |

</div>

### Key Integration Challenges

- **Hazard Coordination**: Synchronizing data forwarding, load-use stalls, and cache stalls while handling simultaneous conditions from cache misses and division operations without corrupting the pipeline.

- **Clock Synchronization**: Standardizing all modules to `posedge clk` after early race conditions from mixed edge triggers in the BTB and register file caused unpredictable behavior.

- **Metadata Propagation**: Ensuring branch prediction flags and opcode validity bits propagate correctly through stages and clear during flushes to prevent spurious stalls and incorrect forwarding.

- **Multi-Cycle Stalls**: Coordinating 32-cycle division and cache miss stalls with selective pipeline freezing strategies while preventing instruction loss or state corruption.

- **Interface Consistency**: Resolving signal naming ambiguities and polarity mismatches between modules (e.g., `memUnsigned` control signal) that caused instruction-specific bugs requiring GTKWave debugging.

##### Integration Success Through Modular Development

Our strategy of isolating and thoroughly testing individual modules before integration proved essential to the project's success. Each team member developed and verified their components independently using comprehensive unit tests, ensuring correct functionality before system-level assembly. This modular approach enabled parallel development across multiple extensions simultaneously - with in person code reviews of modules to ensure each member gained insight into each feature. 

 This collaborative workflow demonstrated our team coordination, with clear interfaces and regular communication ensuring smooth integration of complex features into a fully functional enhanced, pipelined CPU.


---

## Appendix

### Development Tools
- Verilator for simulation
- GTest for C++ testbenches
- GTKWave for waveform analysis
- RISC-V GNU toolchain for assembly
- VBuddy for hardware visualization

### References
- Harris & Harris: *Digital Design and Computer Architecture: RISC-V Edition*
