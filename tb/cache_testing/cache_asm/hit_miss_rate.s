# many misses
main:
    li s0, 0x00010000 

    # Phase 1: all misses
    li t0, 1
    sw t0, 0(s0) 
    li t0, 2
    sw t0, 4(s0) 
    li t0, 3
    sw t0, 8(s0)
    li t0, 4
    sw t0, 12(s0)
    li t0, 5
    sw t0, 16(s0)
    li t0, 6
    sw t0, 20(s0)
    li t0, 7
    sw t0, 24(s0)
    li t0, 8
    sw t0, 28(s0)
    li t0, 9
    sw t0, 32(s0)
    li t0, 10
    sw t0, 36(s0)

    # repeated acceses
    lw t1, 0(s0)
    lw t1, 4(s0)
    lw t1, 8(s0)
    lw t1, 12(s0)
    lw t1, 16(s0)
    lw t1, 20(s0)
    lw t1, 24(s0)
    lw t1, 28(s0)
    lw t1, 32(s0)
    lw t1, 36(s0)

    lw t2, 0(s0)
    lw t2, 4(s0)
    lw t2, 8(s0)
    lw t2, 12(s0)
    lw t2, 16(s0) 

    add a0, t1, t2 
    li a0, 100

finish:
    bne a0, zero, finish