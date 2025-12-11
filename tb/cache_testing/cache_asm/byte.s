main:
    li s0, 0x00010000

    li t1, 42
    sb t1, 0(s0)
    li t2, 73
    sb t2, 1(s0)
    li t3, 99
    sb t3, 2(s0)

    # Load them back (unsigned)
    lbu t4, 0(s0)
    lbu t5, 1(s0)
    lbu t6, 2(s0)

    # Sum them all
    add a0, t4, t5
    add a0, a0, t6

    bne a0, zero, finish

finish:
    bne a0, zero, finish 