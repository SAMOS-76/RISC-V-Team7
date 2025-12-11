main:
    li s0, 0x00010000

    li t1, 100
    sh t1, 0(s0)
    li t2, 200
    sh t2, 2(s0)

    # Load them back
    lhu t3, 0(s0)
    lhu t4, 2(s0) 
    add a0, t3, t4
    bne a0, zero, finish

finish:
    bne a0, zero, finish
