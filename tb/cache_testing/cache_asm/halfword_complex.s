main:
    li s0, 0x00010000   # Base address for testing

    #halfs same chae line
    li t1, 0xABCD
    sh t1, 0(s0)
    li t2, 0x1234
    sh t2, 2(s0)

    lhu t3, 0(s0)
    lhu t4, 2(s0)

    # overwrite first halfword
    li t5, 0x5678
    sh t5, 0(s0)
    lhu t6, 0(s0)


    li s1, 0x00011000
    li a1, 0xDEAD
    sh a1, 0(s1)

    lhu a2, 2(s0)
    lhu a3, 0(s0)


    li s2, 0x00010004
    li a4, 0xBEEF
    sh a4, 0(s2)
    li a5, 0xCAFE
    sh a5, 2(s2)


    li t0, 0xFFFF
    sh t0, 0x10(s0)
    lh t1, 0x10(s0)

    li s3, 0x00010020
    li a6, 0x1111
    sh a6, 0(s3)
    lhu a7, 0(s3)
    li t2, 0x2222
    sh t2, 2(s3)
    lhu t3, 2(s3)

    add a0, t3, t4
    add a0, a0, t6
    add a0, a0, a2 
    add a0, a0, a3
    add a0, a0, a4
    add a0, a0, a5
    add a0, a0, a7
    add a0, a0, t3

finish:
    bne a0, zero, finish
