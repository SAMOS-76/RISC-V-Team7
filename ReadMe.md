# Dynamic Branch Prediction System

A 2-bit saturating counter branch predictor with Branch Target Buffer (BTB) for the RISC-V CPU pipeline, achieving ~40% cycle reduction on loop-intensive workloads.

## Architecture Overview

![Branch Prediction Architecture](https://github.com/user-attachments/assets/53c4c2fd-3119-476f-a4a4-a0d2aafa374a)

The system combines two key components:
- **Branch History Table (BHT)**: 2-bit saturating counters that learn branch behavior
- **Branch Target Buffer (BTB)**: Caches branch target addresses for predicted-taken branches

## Branch History Table (BHT)

### Design Parameters
- **Table Size**: 16 entries (configurable via `INDEX_BITS = 4`)
- **Indexing**: Uses PC bits `[INDEX_BITS+1:2]` (ignores lower 2 bits for alignment)
- **State Encoding**: 
  - `2'b00`: Strongly Not-Taken (SNT)
  - `2'b01`: Weakly Not-Taken (WNT)
  - `2'b10`: Weakly Taken (WT)
  - `2'b11`: Strongly Taken (ST)

### Prediction Logic
```systemverilog
predict_taken = bht[index_F][1];  // MSB indicates taken (1) or not-taken (0)
```

### State Machine
![State Machine](https://media.geeksforgeeks.org/wp-content/uploads/20200520205206/pik11.png)

The saturating counter requires two consecutive mispredictions to fully change direction, providing robustness against noise and temporary pattern changes.

### Update Timing
- Updates occur during Execute stage when branches resolve
- Updates are **disabled during flushes** to prevent learning corruption
- Critical implementation: `update_en = (branch_resolved_E || is_jal) && !CTRL_Flush`

## Branch Target Buffer (BTB)

### Entry Structure
Each BTB entry contains:
- **Valid bit**: Indicates entry contains valid data
- **Tag**: `PC[31:INDEX_BITS+2]` for address matching
- **Target**: 32-bit cached branch target address

### Operation
- **Lookup**: BTB hit indicates cached target is available
- **Updates**: Parallel with BHT when branches resolve
- **Miss Handling**: Falls back to static not-taken prediction, resolves in Execute stage, updates BTB (one-time penalty)

## Predictor Integration

### Prediction Generation
```systemverilog
predict_taken_F  = bht_predict_taken && btb_hit;
predict_target_F = btb_target;
predict_valid_F  = btb_hit;
```

**Critical Design Decision**: Predictor only generates predictions on BTB hit, ensuring no speculative execution on first-time branches with unknown targets.

### JAL vs JALR Handling
- **JAL** (PC-relative jumps): Predicted using BHT+BTB, target cached in BTB
- **JALR** (register-indirect jumps): Uses static prediction (unavoidable without Return Address Stack)
- Update logic: `update_predictor = branch_resolved_E || is_jal`

## Hazard Unit Integration

### Prediction Metadata Pipeline
Added signals propagating through pipeline stages:
- `F_prediction_made`: Indicates predictor made a prediction
- `F_predicted_taken`: The prediction (taken/not-taken)

### Misprediction Detection
```systemverilog
if (E_Branch && E_prediction_made) begin
    branch_mispredict = (E_predicted_taken != branch_taken);
end
else if (E_Branch && !E_prediction_made) begin
    branch_mispredict = branch_taken;  // BTB miss case
end
```

### PC Target Management
Handles multiple misprediction scenarios:
```systemverilog
mispred_take     = Branch && branch_taken && !E_predicted_taken;
mispred_not_take = Branch && !branch_taken && E_predicted_taken;
target_mismatch  = (E_btb_PCtarget != PCTarget);

// Select correct recovery address
if (Jump)
    Hazard_target = PCTarget;
else if (mispred_take)
    Hazard_target = PCTarget;
else if (mispred_not_take)
    Hazard_target = E_pc_out4;
else if (Branch && branch_taken && ~E_prediction_made)
    Hazard_target = PCTarget;
else
    Hazard_target = E_pc_out4;
```

### Flush Control
- Flushes occur **only** on mispredictions or unpredicted taken branches
- Correct predictions have **zero-cycle penalty**
- Pipeline registers clear prediction metadata during flush operations

## Performance Results

### Benchmark: AddiBNE Test (Loop-Intensive)
| Prediction Type | Cycles | Improvement |
|----------------|--------|-------------|
| Static Baseline | 1277 | - |
| Dynamic (2-bit + BTB) | 771 | **~40% reduction** |

### Why It Works
- Loops execute many taken-branch iterations before one not-taken exit
- 2-bit counter reaches Strongly Taken (ST) state after two iterations
- All subsequent iterations predicted correctly with zero penalty

## Key Implementation Files

```
rtl/
├── branch_history_table.sv    # BHT implementation with 2-bit counters
├── branch_target_buffer.sv    # BTB implementation with tags and targets
├── branch_predictor.sv        # Top-level predictor integration module
├── hazard_unit/
│   └── hazard_unit.sv        # Modified hazard detection with prediction
└── top.sv                     # Pipeline integration

tb/asm/
└── predictor.s               # Branch prediction stress test
```

## Critical Debugging Lessons

### 1. Predictor Update Gating
**Problem**: Predictor updated during flushes, corrupting learning process.
**Solution**: Gate updates with flush signal: `update_en && !CTRL_Flush`

### 2. Pipeline Flush Metadata Clearing
**Problem**: Prediction metadata persisted through flushes, affecting new instructions.
**Solution**: Explicitly clear prediction signals during flush operations.

### 3. Misprediction Type Classification
**Problem**: Single target address couldn't handle all misprediction scenarios.
**Solution**: Classify mispredictions and select appropriate recovery address (PC+4 vs. target).

## Future Enhancements

### Tournament Predictor
Combine multiple prediction schemes (local + global) with meta-predictor selection for complex patterns.

### Return Address Stack (RAS)
Dedicated stack for function returns to eliminate JALR mispredictions (~3-cycle penalty currently).

### Larger Tables
Increase `INDEX_BITS` to 8 (256 entries) to reduce aliasing conflicts.

## Testing

Use the provided stress test:
```bash
./testbench tb/asm/predictor.s
```

Tests include:
- Loop-heavy code (optimal case)
- Alternating branches (worst case)
- Nested loops
- Mixed biases
