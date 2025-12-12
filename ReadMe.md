# RISC-V Pipelined CPU with L1 Cache

<img width="985" height="520" alt="image" src="https://github.com/user-attachments/assets/70228a26-ae90-47c7-92a2-ab10943d516f" />


## Cache Implementation

### Architecture
- **Capacity:** 4-byte cache lines (32 bits)
- **Associativity:** 2-way set associative
- **Replacement:** LRU (1-bit per set)
- **Write Policy:** Write-back with dirty bit tracking
- **Address Parsing:** TAG [31:11] | INDEX [10:2] | OFFSET [1:0]

### Module Structure
- **cache_controller.sv** - 3-state FSM managing cache operations (IDLE, WRITEitBack, ALLOCit)
- **cache_L1.sv** - Dual-way storage with tag, data, valid, dirty, and LRU bits
- **cache_data_parser.sv** - Byte/halfword/word access handler and data merger

### FSM States
```
IDLE    Cache hit: serve request, update LRU
        Cache miss: stall CPU
        Dirty victim: WRITEitBack -> ALLOCit -> IDLE
        Clean victim: ALLOCit -> IDLE
```

### Key Features
- **LRU Replacement:** Updates on both read and write hits; prioritizes filling invalid ways before eviction
- **Write-back Policy:** Modified lines marked dirty, written to memory only on eviction
- **Sub-word Access:** Supports byte/halfword/word operations via data parser
- **Immediate Stall:** Combinational stall assertion on miss detection prevents pipeline corruption
- **Pipeline Integration:** Stall signal freezes PC/F_D/D_E, allows E_M/M_W to drain

### Stall Penalties
- Clean miss: 1 cycle (IDLE -> ALLOCit -> IDLE)
- Dirty miss: 2 cycles (IDLE -> WRITEitBack -> ALLOCit -> IDLE)

### Performance Metrics
- Hit/miss counters track cache effectiveness
- AMAT calculation: `t_hit + (miss_rate * t_miss) + dirty_eviction_penalty`

### Testing
Run full cache test suite: `./cacheit.sh` from [tb](tb/) folder

Tests include:
- [word_complex.s](cache_testing/word_complex.s) - Word-aligned operations
- [byte_complex.s](cache_testing/byte_complex.s) - Byte manipulation (debugging required)
- [eviction_test.s](cache_testing/eviction_test.s) - LRU eviction patterns

### Known Issues
- Byte operations corrupting cache lines in repeated sub-word stores
- Stall strategy requires refinement for selective stage freezing

### Branch Structure
- **Cache-final** - Main L1 cache implementation
- **Cache-Single-Cycle** - Single-cycle exploration with 4-word burst and BRAM
- **Cache-Prefetch** - Zero-penalty sequential prefetch extension

### Prefetch Extension (Cache-Prefetch branch)
- Fetches next sequential cache line during allocation stall
- Zero additional stall penalty
- Requires debugging for state-dependent address muxing

---

## Build & Run
```bash
./cacheit.sh              # Run cache test suite on CPU
./doit.sh                 # Build full CPU classic tests
./doitunit.sh             # Run unit tests
```

