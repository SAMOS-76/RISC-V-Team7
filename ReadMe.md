# RISC-V Single Cycle CPU with Cache Exploration

## Cache - Single Cycle Implementation

### Overview
This branch explores cache implementation on our single-cycle CPU architecture. The design addresses the challenge of integrating realistic memory hierarchies into a single-cycle CPU that originally assumed combinational main memory with near-zero latency.

### Architecture

**Configuration:**
- **Capacity:** 16-byte cache lines (4 words, 32 bits)
- **Associativity:** 2-way set associative
- **Replacement:** LRU (1-bit per set)
- **Write Policy:** Write-back with dirty bit tracking
- **Storage:** BRAM (Block RAM) primitives for FPGA synthesis

**BRAM Storage Structure** (303-bit entries, synchronous write / asynchronous read):
```
[302]       = LRU bit (1 bit)
[301:151]   = Way 1: [Valid(1) | Dirty(1) | Tag(21) | Data(128)]
[150:0]     = Way 0: [Valid(1) | Dirty(1) | Tag(21) | Data(128)]
```

### FSM Controller

The cache controller implements a 4-state FSM with 4-word burst transfers to exploit spatial locality:

```
STATE IDLE:
    If CPU request:
        If hit:
            If write: update line, set dirty
            Update LRU
        Else (miss):
            Stall CPU
            Latch request
            If victim dirty -> WRITEBACK
            Else -> ALLOCATE

STATE WRITEBACK:
    Stall CPU
    Write victim line to memory (4-word burst)
    -> ALLOCATE

STATE ALLOCATE:
    Stall CPU
    Read new cache line from memory (4-word burst)
    Merge CPU write if needed
    -> UPDATE_SRAM

STATE UPDATE_SRAM:
    Write new line into cache
    Set valid/dirty, update LRU
    -> IDLE
```

### Gated Clock Implementation

To avoid pipelining while maintaining cache functionality, the design uses a gated clock approach:

```systemverilog
logic cpu_clk;
assign cpu_clk = clk && !stall;  // freeze fetch/decode/execute stages during cache miss
```

- **cpu_clk:** Gates fetch, decode, and execute stages during cache stalls
- **Full clock:** Memory stage runs on full clock to service cache operations
- **2-bit burst counter:** Generates sequential addresses (0->1->2->3) during 4-word WRITEBACK/ALLOCATE bursts

### Key Features

- **4-word burst transfers:** Improves spatial locality by fetching entire cache lines
- **BRAM integration:** Replaces LUT-based memory for FPGA synthesis readiness
- **Read/write data formatters:** Handle sub-word (byte/halfword/word) access alignment
- **Dirty bit tracking:** Write-back policy minimizes memory traffic

### Known Limitations

- Struggles with complex sub-word cache line replacement (repeated byte stores/loads to same address)
- PDF test particularly stresses byte manipulation patterns
- Burst counter synchronization requires further debugging

### Testing

Basic cache assembly tests pass, but complex tests requiring intensive sub-word operations need debugging.

### Architectural Insights

This exploration provided key learnings that informed the pipelined cache implementation (cache-final branch):
- Reduce cache line size for pipelined CPU (16 bytes -> 4 bytes)
- Simplify FSM (4 states -> 3 states)
- Maintain LRU but start from combinational implementation
- Proper stall handling requires hazard unit integration in pipelined design

---

## Build & Run
```bash
./doit.sh                 # Build full CPU classic tests
./doitunit.sh             # Run unit tests
```
