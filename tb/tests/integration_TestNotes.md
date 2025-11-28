
## Understanding Testbench Functionalities  
*(`CpuTestbench` class - Integration Testing)*
*(read @verification_Brief.md also)*

---

## `CpuTestbench` Overview

CPU created **after** assembling the test program == so correct instruction memory is loaded for each test.

General flow of a test:

1. `SetUp()` → create clean Verilator context, reset internal cycle counter
2. `setupTest()` → assemble program + prepare memory , empty data.hex exists
Verilator reads `program.hex` at DUT creation, so programs must be assembled first.
3. `initSimulation()` → instantiate DUT, enable tracing, run reset  
4. Run test using `runSimulation()`  
5. `TearDown()` → close tracer, save output memory files  

---