#  controlled miss rate scenario
# to validate AMAT = t_cache + (MR * t_memory)e
# Expected AMAT = 1 + (0.2 * 100) = 21 cycles per access


main:
    li s0, 0x00010000

    #4 hits for every 1 miss
    # Use a pattern where we access same location 4 times (3 hits after 1 miss)
    # then move to a new location

    li s1, 0
    li s2, 20

loop:
    #miss
    slli t0, s1, 2
    add t1, s0, t0
    li t2, 42
    sw t2, 0(t1)

    # accesscess 2-4
    lw t3, 0(t1)
    addi t3, t3, 1
    sw t3, 0(t1)
    lw t3, 0(t1)

    addi s1, s1, 1
    blt s1, s2, loop

    li s1, 0
read_loop:
    slli t0, s1, 2
    add t1, s0, t0
    lw t3, 0(t1) 
    addi s1, s1, 1
    blt s1, s2, read_loop

    # Result
    li a0, 200

finish:
    bne a0, zero, finish
