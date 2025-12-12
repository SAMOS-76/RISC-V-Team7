# RISC-V 32IM CPU

## Introduction
We developed four distinct CPUs: a single-cycle processor, 5-stage pipelined, pipelined RV32IM, pipelined with cache, pipelined with branch prediction.
## Quick Access
- **`main` branch**: Fully tested Pipelined RV32I
- **`SingleCycle` branch**: Verified single-cycle CPU
- **`RV32IM` branch**: Pipelined RV32IM perofrming complex maths instructions
- **`Cache` branch**: Pipelined with Cache
- **`Branch Prediction` branch**: Pipelined with branch prediction

## The Team

| Name | Personal Statement |
|------|-------------------|
| Samuel Amos-Osebeyo | [Statement](./personal%20statements/) |
| Louis Canning | [Statement](./personal%20statements/) |
| Archie Kendall | [Statement](./personal%20statements/) |
| Adil Shah | [Statement](./personal%20statements/) |

## Running the Project

All commands should be executed from the `/tb` directory:

| Command | Purpose |
|---------|---------|
| `./doit.sh` | Execute standard test suite |
| `./doitunit.sh [unit name]` | Run module tests |
| `./custom_doit.sh` | Run our directory of our own tests |
| `./pdf.sh [distribution name]` | Run PDF distribution visualization |
| `./f1.sh` | Run F1 starting lights simulation |

---

## Single Cycle Implementation

### Design Overview
Our single-cycle CPU implements the complete RV32I instruction set, enabling single-cycle execution of arithmetic, logical, memory, and control flow operations.

### Module Contributions

| Component | Samuel | Louis | Archie | Adil |
|-----------|--------|-------|--------|------|
| Program Counter | X | | | |
| ALU | | X | | |
| Register File | | X | | |
| Instruction Memory | | X | | |
| Control Unit | | | | X |
| Sign Extension | | | | X |
| Data Path Integration | X | x | | |
| Data Memory | | X | x | |
| Top-Level Assembly | X | x | | |
| Unit Testing | | | X | |
| Integration Testing | | x | X | |
| F1 Program | X | | | |

### Project Structure
```

```

### Implementation Notes

**Multiplication Unit**: Our M-extension implementation includes a dedicated multiplication unit supporting mul, mulh, mulhsu, and mulhu operations, integrated directly into the execute stage for single-cycle multiplication.

**Control Logic**: The control unit generates all necessary signals based on instruction opcode and funct fields, managing ALU operations, memory access, register writes, and branch decisions.

**Data Path**: Clean separation between fetch, decode, execute, and memory stages with well-defined interfaces between components.

### Verification Results

#### Standard Tests (1-5)
All provided test cases pass successfully:

<img width="414" height="308" alt="Single cycle test results" src="https://github.com/user-attachments/assets/ae19b3ca-cd87-465d-a798-5379ba36bf8f" />

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

### Architecture Overview
Our pipelined processor achieves higher throughput through instruction-level parallelism across four pipeline stages: fetch, decode, execute, and memory. This design processes multiple instructions concurrently, with each stage handling a different instruction simultaneously.

**Key Features:**
- Full RV32IM instruction set support
- Hazard detection and forwarding
- Branch prediction capabilities
- Pipeline flushing for control hazards
- Four-stage pipeline architecture

### Design Schematic
*[Insert pipelined architecture diagram]*

### Module Contributions

| Component | Samuel | Louis | Archie | Adil |
|-----------|--------|-------|--------|------|
| Fetch Stage | | | | |
| Decode Stage | | | | |
| Execute Stage | | | | |
| Memory Stage | | | | |
| Fetch Pipeline Register | | | | |
| Decode Pipeline Register | | | | |
| Execute Pipeline Register | | | | |
| Memory Pipeline Register | | | | |
| Hazard Detection Unit | | | | |
| Branch Prediction Logic | | | | |
| Pipeline Integration | | | | |
| Testing & Debugging | | | | |

### Architecture Details

#### Pipeline Stages

**Fetch Stage:**
- Retrieves instructions from instruction memory
- Updates program counter
- Handles branch target calculation
- Passes instruction to decode stage on clock edge

**Decode Stage:**
- Extracts instruction fields
- Reads register file
- Generates control signals
- Sign-extends immediate values
- Detects data hazards

**Execute Stage:**
- Performs ALU operations
- Executes multiplication/division
- Evaluates branch conditions
- Calculates memory addresses
- Forwards results to earlier stages

**Memory Stage:**
- Handles load/store operations
- Manages data cache interface
- Prepares writeback data

#### Hazard Management

**Data Hazards:**
Our hazard unit detects RAW (Read-After-Write) dependencies and implements forwarding:
- Forward from Execute stage to Execute stage (EX-EX forwarding)
- Forward from Memory stage to Execute stage (MEM-EX forwarding)
- Forward from Writeback stage to Execute stage (WB-EX forwarding)
- Stall insertion when load-use hazard detected

**Control Hazards:**
- Branch prediction using simple taken/not-taken predictor
- Pipeline flushing on misprediction
- Branch target buffer for jump address caching

**Structural Hazards:**
Avoided through separate instruction and data memories.

#### Pipeline Registers

Pipeline registers store instruction state between stages:
- **Fetch/Decode**: PC, instruction
- **Decode/Execute**: Control signals, register values, immediate, PC
- **Execute/Memory**: ALU result, control signals, register data
- **Memory/Writeback**: Memory data, ALU result, control signals

All registers update on negative clock edge to prevent race conditions.

### Project Structure
```
.
├── .gitignore
├── ReadMe.md
├── rtl
│   ├── adder.sv
│   ├── branch_history_table.sv
│   ├── decode
│   │   ├── D_E_reg.sv
│   │   ├── alu_decoder.sv
│   │   ├── control_unit.sv
│   │   ├── decode.sv
│   │   ├── regfile.sv
│   │   └── sign_extend.sv
│   ├── execute
│   │   ├── E_M_reg.sv
│   │   ├── alu.sv
│   │   ├── branch_comparator.sv
│   │   └── execute.sv
│   ├── fetch
│   │   ├── F_D_reg.sv
│   │   ├── fetch.sv
│   │   ├── instrMem.sv
│   │   └── pc_reg.sv
│   ├── hazard_unit
│   │   ├── control_hazard.sv
│   │   └── hazard_unit.sv
│   ├── memory
│   │   ├── M_W_reg.sv
│   │   ├── datamem.sv
│   │   └── memory.sv
│   ├── mux.sv
│   ├── mux4.sv
│   ├── top.sv
│   └── writeback
│       └── writeback.sv
└── tb
    ├── Units
    │   └── [module tests]
    ├── asm
    │   ├── 1_addi_bne.s
    │   ├── 2_li_add.s
    │   ├── 3_lbu_sb.s
    │   ├── 4_jal_ret.s
    │   ├── 5_pdf.s
    │   └── f1.s
    ├── assemble.sh
    ├── custom_doit.sh
    ├── custom_test_out
    │   └── [our custom test outputs]
    ├── custom_tests
    │   ├── custom_cpu_testbench.h
    │   └── custom_verify.cpp
    ├── doit.sh
    ├── hazards_test_asm
    │   └── [all our custom assembly tests]
    ├── reference
    ├── test_out
    ├── tests
    │   └── [provided tests]
    ├── vbuddy_tests
    │   ├── f1.sh
    │   ├── f1_tb.cpp
    │   ├── pdf.sh
    │   ├── pdf_tb.cpp
    │   ├── vbuddy.cfg
    │   └── vbuddy.cpp
    ├── verification_Brief.md
    └── verification_Notes.md
```

### Testing & Validation

All provided tests pass with correct register states and memory contents.

<img width="853" height="595" alt="image" src="https://github.com/user-attachments/assets/d9592c7a-84ae-434f-8503-0933824459d1" />


---

## Implementing Extensions

### Integration Overview

**Our extensions:**
- Full RV32I
- RV32IM extension
- Pipelinig + Hazard Unit

### System Architecture
*[Insert complete system diagram showing pipeline + cache integration]*

### Integration Contributions

| Component | Samuel | Louis | Archie | Adil |
|-----------|--------|-------|--------|------|
| Execute Stage | | | | |
| Fetch Stage | | | | |
| Memory Stage | | | | |
| Decode Stage | | | | |
| Cache-Pipeline Interface | | | | |
| Stall Logic | | | | |
| System Integration | | | | |
| Full System Testing | | | | |

### Key Integration Challenges

#### Cache-Pipeline Synchronization
Pipeline must stall when cache misses occur:
- Stall signal propagates from memory stage
- Earlier pipeline stages freeze
- PC holds current value
- Pipeline resumes when cache services miss

#### Hazard Detection with Cache
Hazard unit must account for:
- Variable memory stage latency (cache hits vs misses)
- Stall cycles preventing forwarding
- Load-use hazards exacerbated by cache misses

#### Branch Prediction with Cache
Cache misses on instruction fetch affect:
- Branch prediction accuracy assessment
- Misprediction penalty calculation
- Pipeline flush timing

### System Testing

#### Full Test Suite
Tests 1-8 all pass on complete system, validating:
- Correct instruction execution
- Proper pipeline behavior
- Cache functionality
- Hazard handling
- Branch prediction

#### Performance Characteristics
Complete system achieves:
- Near-1 IPC on cache-friendly code
- Efficient handling of cache misses
- Correct program semantics across all tests

VBuddy demonstrations (F1, PDF) execute correctly on complete system.

---

## Appendix

### Development Tools
- Verilator for simulation
- GTKWave for waveform analysis
- GTest for C++ testbenches
- RISC-V GNU toolchain for assembly
- VBuddy for hardware visualization

### References
- RISC-V 32IM Specification: https://cs.sfu.ca/~ashriram/Courses/CS295/assets/notebooks/RISCV/RISCV_CARD.pdf
- Harris & Harris: *Digital Design and Computer Architecture: RISC-V Edition*
- Patterson & Hennessy: *Computer Organization and Design: RISC-V Edition*




