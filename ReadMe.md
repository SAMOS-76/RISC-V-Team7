# RISC-V 32IM CPU

## Introduction
We developed two distinct CPUs: a single-cycle processor featuring an integrated multiplication unit and a high-performance pipelined RV32IM CPU with cache memory. Our implementation includes advanced features such as branch prediction, ALU-integrated multiplication, and a multicycle division unit for complete M-extension support.

## Quick Access
- **`main` branch**: Fully tested Pipelined RV32IM CPU with cache
- **`SingleCycle` branch**: Verified single-cycle CPU with multiplication support

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
| `./vbuddy_tests/pdf.sh` | Run PDF distribution visualization |
| `./vbuddy_tests/f1.sh` | Run F1 starting lights simulation |

---

## Single Cycle Implementation

### Design Overview
Our single-cycle CPU implements the core RV32I instruction set with M-extension multiplication support, enabling single-cycle execution of arithmetic, logical, memory, and control flow operations.

### Architecture

**Supported Instructions:**
- **R-type**: add, sub, and, or, xor, slt, sltu, sll, srl, sra, mul, mulh, mulhsu, mulhu
- **I-type (ALU)**: addi, andi, ori, xori, slti, sltiu, slli, srli, srai
- **I-type (Load)**: lbu, lw
- **I-type (Jump)**: jalr
- **S-type**: sb, sw
- **B-type**: beq, bne
- **U-type**: lui
- **J-type**: jal

### Module Contributions

| Component | Samuel | Louis | Archie | Adil |
|-----------|--------|-------|--------|------|
| Program Counter | | | | |
| ALU & Multiplication | | | | |
| Register File | | | | |
| Instruction Memory | | | | |
| Control Unit | | | | |
| Sign Extension | | | | |
| Data Path Integration | | | | |
| Data Memory | | | | |
| Top-Level Assembly | | | | |
| Unit Testing | | | | |
| Integration Testing | | | | |
| F1 Program | | | | |
| Documentation | | | | |

### Project Structure
```
├── rtl/
│   ├── fetch/
│   │   ├── pc_register.sv
│   │   ├── instr_mem.sv
│   │   └── fetch_top.sv
│   ├── decode/
│   │   ├── reg_file.sv
│   │   ├── control.sv
│   │   ├── signextend.sv
│   │   └── decode_top.sv
│   ├── execute/
│   │   ├── alu.sv
│   │   ├── multiply_unit.sv
│   │   └── execute_top.sv
│   ├── memory/
│   │   ├── datamem.sv
│   │   └── memory_top.sv
│   ├── mux.sv
│   └── top.sv
├── tb/
│   ├── asm/
│   │   ├── 1_addi_bne.s
│   │   ├── 2_li_add.s
│   │   ├── 3_lbu_sb.s
│   │   ├── 4_jal_ret.s
│   │   ├── 5_pdf.s
│   │   └── f1_fsm.s
│   ├── our_tests/
│   │   └── [unit test files]
│   ├── vbuddy_test/
│   │   ├── f1_fsm_tb.cpp
│   │   └── pdf_tb.cpp
│   ├── doit.sh
│   └── assemble.sh
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
├── rtl/
│   ├── fetch/
│   │   ├── fetch_top.sv
│   │   ├── fetch_pipeline_regfile.sv
│   │   └── pc_register.sv
│   ├── decode/
│   │   ├── decode_top.sv
│   │   ├── decode_pipeline_regfile.sv
│   │   ├── register_file.sv
│   │   ├── control_unit.sv
│   │   └── sign_ext.sv
│   ├── execute/
│   │   ├── execute_top.sv
│   │   ├── execute_pipeline_regfile.sv
│   │   ├── alu.sv
│   │   ├── branch_logic.sv
│   │   └── hazard_unit.sv
│   ├── memory/
│   │   ├── memory_top.sv
│   │   ├── memory_pipeline_regfile.sv
│   │   ├── data_mem.sv
│   │   └── loadstore_parsing_unit.sv
│   ├── top-module-interfaces/
│   │   ├── interfaceD.sv
│   │   ├── interfaceE.sv
│   │   ├── interfaceM.sv
│   │   └── interfaceW.sv
│   └── top.sv
└── tb/
```

### Testing & Validation

#### Core Test Suite (Tests 1-5)
All baseline tests pass with correct register states and memory contents.

#### Extended Test Suite (Tests 6-8)

**Test 6 - Shift Operations:**
- Tests sll, srl, sra instructions
- Validates immediate shift variants (slli, srli, srai)
- Confirms correct shift amounts and direction

**Test 7 - Logic Operations:**
- Verifies xor, or, and operations
- Tests comparison instructions (slt, sltu)
- Validates immediate variants

**Test 8 - Memory Operations:**
- Tests lb, lh, lw load variants
- Validates sh, sw store operations
- Confirms proper byte/halfword alignment

All 8 tests pass successfully, validating complete RV32IM support.

#### Performance Analysis
Compared to single-cycle, the pipelined version achieves:
- Higher instruction throughput (approaching 1 IPC with good hazard management)
- Better cycle time due to shorter critical path
- Overall speedup on multi-instruction programs

---

## Cache Implementation

### Design Overview
We implement a 2-way set-associative cache with write-back policy and LRU replacement. This cache design balances hit rate, hardware complexity, and access latency.

**Cache Specifications:**
- 2-way set associative
- 512 sets (1024 total cache lines)
- 32-bit word size
- Write-back policy
- LRU replacement algorithm

### Architecture

**Cache Organization:**
```
Address breakdown:
[Tag | Set Index | Byte Offset]
```

Each set contains:
- Two cache lines (ways)
- Valid bit per line
- Dirty bit per line
- Tag per line
- LRU bit (0 = way 0 recently used, 1 = way 1 recently used)

### Module Contributions

| Component | Samuel | Louis | Archie | Adil |
|-----------|--------|-------|--------|------|
| Cache Controller | | | | |
| SRAM Module | | | | |
| 2-Port RAM | | | | |
| Memory Top Integration | | | | |
| Cache Testing | | | | |
| Performance Analysis | | | | |

### Implementation Details

#### Cache Controller Logic

**Read Hit:**
1. Compare tag with both ways
2. Return data from matching way
3. Update LRU bit

**Read Miss:**
1. Check LRU to determine eviction way
2. If dirty bit set, write back to memory
3. Fetch new line from memory
4. Update cache line (data, tag, valid, clear dirty)
5. Update LRU bit

**Write Hit:**
1. Update data in matching way
2. Set dirty bit
3. Update LRU bit

**Write Miss:**
1. Follow read miss procedure
2. Update fetched line with new data
3. Set dirty bit

#### Memory Interface

The cache interfaces with:
- **Upstream (CPU)**: Receives read/write requests with addresses and data
- **Downstream (Main Memory)**: Issues memory reads on misses, writes on dirty evictions

Stall signal indicates when CPU must wait for cache miss handling.

### Project Structure
```
├── rtl/
│   ├── memory/
│   │   ├── two_way_cache_top.sv
│   │   ├── two_way_cache_controller.sv
│   │   ├── sram.sv
│   │   ├── ram2port.sv
│   │   └── memory_top.sv
│   └── ...
└── tb/
    └── our_tests/
        └── cache_top_tb.cpp
```

### Testing Strategy

Our cache testing validates:

**Functional Correctness:**
- Basic read/write operations
- Hit detection for both ways
- Miss handling and memory fetch
- LRU replacement policy
- Dirty bit and write-back mechanism
- Byte and word addressing

**Edge Cases:**
- Cache line boundaries
- Simultaneous hits in both ways (shouldn't occur)
- Full cache scenarios
- Alternating access patterns

**Performance Metrics:**
- Hit rate across different workloads
- Average memory access time
- Stall cycle analysis

#### Results

Cache implementation passes all unit tests. Performance improvement over single-cycle:
- Execution time: **[X] ms** (cached) vs **[Y] ms** (uncached)
- Hit rate: **~XX%** on typical workloads
- Significant reduction in memory access latency

VBuddy tests (F1, PDF) run correctly with cache enabled.

---

## Complete System

### Integration Overview
Our complete RISC-V processor combines pipelining and caching into a unified, high-performance design supporting the full RV32IM instruction set.

**System Features:**
- 4-stage pipeline
- 2-way set-associative cache
- Complete RV32IM ISA
- Hazard detection and forwarding
- Branch prediction
- Multicycle division
- Integrated multiplication

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




