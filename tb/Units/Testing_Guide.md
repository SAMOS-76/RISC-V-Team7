# RISC-V Unit Testing Framework Guide

This framework uses Verilator for simulation and Google Test for assertions. It separates clocked logic (like registers) from combinatorial logic (like ALUs).

## Architecture Overview

The framework has three key layers:

1. **Base Layer** - Infrastructure that handles clocking and waveform generation eg VCD tracing and mem management
2. **Interaction Layer** - Translates function calls into hardware signals
3. **Assertion Layer** - Your actual test cases
4. **doitunit.sh <module_name>** - bash script compatible with all modules to build and extract module data

Noting: waveforms are genrated dynamically per test case -- to isolate test cases when debugging
Similiarly using, `-DMODULE_NAME` in the Bash script to inject the module name into the C++ code at compile time:
so you can write the module name once in the command line (./doitunit.sh regfile). The script passes this to Verilator, which passes it to the C++ compiler, which uses it to name the VCD files -- naming across files remains cosnitent. 
## Testing a New Module

### 1: Create the Testbench Header

Create eg `tb/Units/[module]_testbench.h`

**Key Decision:** Does your module have a clock signal?
- **Yes** → Inherit from `ClockedTestbench`
- **No** → Inherit from `CombTestbench`

Add helper functions to:
- Set inputs, Run the simulation (`tick()` advances time), Read outputs etc. 

### 2: Write Your Tests

Create eg `tb/Units/verify_[module].cpp`

Each test follows this pattern:
1. Set input signals
2. Call `tick()` to run simulation
3. Check outputs with `EXPECT_EQ(actual, expected)`

### 3: Run the Test
```bash
./doitunit.sh [module_name]
```

## Key Concepts

- **`top_`** - Pointer to access your hardware signals (e.g., `top_->data_in`)
- **`tick()`** - Advances simulation (toggles clock for clocked modules)
- **`EXPECT_EQ`** - Checks if two values match (test continues on failure)
- **`ASSERT_EQ`** - Checks if two values match (test stops on failure)

## File structure 
should be obvious from doitunit.sh -- but important to have some form of `tb` -> `Unit Tests`, `rtl` 