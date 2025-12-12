main:
    li s0, 0x00010000

    li t1, 0xDEADBEEF
    sw t1, 0(s0)
    lw t2, 0(s0)

    li t3, 0x12345678
    sw t3, 4(s0)
    li t4, 0xABCDEF00
    sw t4, 8(s0) 
    li t5, 0x11223344
    sw t5, 12(s0)

    li t6, 0xFFFFFFFF
    sw t6, 0(s0)
    lw a1, 0(s0)

    li s1, 0x00011000
    li a2, 0xCAFEBABE
    sw a2, 0(s1)

    li s2, 0x00012000 
    li a3, 0x99887766
    sw a3, 0(s2)

    lw a4, 4(s0)
    lw a5, 8(s0)
    lw a6, 12(s0)

    li s3, 0x00010100
    li t0, 0x55555555
    sw t0, 0(s3)
    lw t1, 0(s3)

    li s4, 0x00010200
    li a7, 0x10101010
    sw a7, 0(s4)
    li s5, 0x00010400
    li t2, 0x20202020
    sw t2, 0(s5)
    li s6, 0x00010800
    li t3, 0x30303030
    sw t3, 0(s6)

    lw t4, 0(s4)
    lw t5, 0(s5)
    lw t6, 0(s6)


    li s7, 0x00020000
    li ra, 0xAAAAAAAA
    sw ra, 0(s7)
    li s8, 0x00040000
    li sp, 0xBBBBBBBB
    sw sp, 0(s8)

    lw gp, 0(s7)

    li s9, 0x00060000
    li tp, 0xCCCCCCCC
    sw tp, 0(s9)


    xor a0, t2, a1
    xor a0, a0, a4
    xor a0, a0, a5
    xor a0, a0, a6
    xor a0, a0, t1
    xor a0, a0, t4
    xor a0, a0, t5
    xor a0, a0, t6
    xor a0, a0, gp


finish:
    bne a0, zero, finish