### Unit Tests Area

---

### Integration Testing area 

---

### Programme.S

| Test Name       | Loaded Program         | Expected a0 | Passed? | Notes |
|-----------------|------------------------|-------------|---------|-------|
| TestAddiBne     | `1_addi_bne`           | 254         |         |       |
| TestLiAdd       | `2_li_add`             | 1000        |         |       |
| TestLbuSb       | `3_lbu_sb`             | 300         |         |       |
| TestJalRet      | `4_jal_ret`            | 53          |         |       |
| TestPdf         | `5_pdf` + `gaussian.mem` | 15363     |         |       |

---

### Understanding Provided Testbench Functionalities  
*(Before full CPU continuous testing)*

#### `base_testbench.h` Functionality

### **SetUp()**
- Instantiates the DUT (Device Under Test) using a smart pointer (`make_unique`) → `top = Vdut()`
- Enables VCD waveform tracing
- Calls `initializeInputs()`
- Each test receives a **fresh DUT instance**
- Opens output file: `waveform.vcd`
- Calls **derived-class** `initializeInputs()`

### **TearDown()**
- Cleanly shuts down the DUT
- Closes VCD tracing
- Memory deallocates automatically via smart pointers

---

## `testbench.h` Functionality

### **runSimulation(int cycles)**
- Simulates clock cycles with:
  - Rising edge → `eval()`
  - Falling edge → `eval()`
- Dumps VCD **twice per cycle** for cycle-accurate tracing
- `base_testbench` cannot toggle the clock itself
- Derived classes must directly access `top->clk` to toggle the clock

