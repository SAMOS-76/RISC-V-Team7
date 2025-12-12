.text
.globl main

main:

#######################################
# Test 1: tight arithmetic loop (ALU throughput)
# final a0 = 100000
#######################################

    li      t0, 0          # t0 = iteration counter
    li      t1, 100000     # t1 = loop bound
    li      a0, 0          # accumulator = 0

alu_loop:
    addi    a0, a0, 1      # a0 increments every cycle
    addi    t0, t0, 1      # t0 increments every iteration
    bne     t0, t1, alu_loop

#######################################
# Test 2: predictable branch pattern (always taken)
# final a1 = 50000
#######################################

    li      t0, 0
    li      t1, 50000
    li      a1, 0

taken_loop:
    addi    a1, a1, 1
    addi    t0, t0, 1
    beq     t0, zero, taken_loop   # always taken since t0 != 0 except first pass

#######################################
# Test 3: alternating branch pattern (hard for predictor)
# final a2 = 20000
#######################################

    li      t0, 0
    li      t1, 20000
    li      a2, 0

alt_loop:
    addi    a2, a2, 1
    addi    t0, t0, 1
    andi    t2, t0, 1      # t2 = LSB of loop counter
    bne     t2, zero, alt_skip
    j       alt_next

alt_skip:
    j       alt_next

alt_next:
    bne     t0, t1, alt_loop

#######################################
# Test 4: load–use hazard chain
# final a3 = loaded value + loop count (10000 + 10000)
#######################################

    li      t1, 10000
    la      t2, test_data
    li      a3, 0
    li      t0, 0

load_loop:
    lw      t3, 0(t2)      # load value = 10000
    add     a3, a3, t3     # dependent on previous instruction
    addi    t0, t0, 1
    bne     t0, t1, load_loop

#######################################
# Test 5: random control + ALU mix
# final a4 = deterministic pseudo-random sum
#######################################

    li      t0, 0
    li      t1, 40000
    li      a4, 0

mix_loop:
    addi    a4, a4, 7
    xor     a4, a4, t0
    addi    t0, t0, 1
    andi    t2, t0, 7
    bne     t2, zero, mix_loop
    addi    a4, a4, 3
    bne     t0, t1, mix_loop

#######################################
# End — program loops forever
#######################################

end:
    j end

#######################################
# Data section for Test 4
#######################################

.data
test_data:
    .word 10000
