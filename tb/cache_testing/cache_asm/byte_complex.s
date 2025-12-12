main:
    li s0, 0x00010000

    li t1, 0xAA
    sb t1, 0(s0)
    li t2, 0xBB
    sb t2, 1(s0)
    li t3, 0xCC
    sb t3, 2(s0)
    li t4, 0xDD
    sb t4, 3(s0)

    lbu a1, 0(s0)
    lbu a2, 1(s0)
    lbu a3, 2(s0)
    lbu a4, 3(s0)

    li t5, 0x11
    sb t5, 1(s0)
    lbu a5, 1(s0)
    lbu a6, 0(s0)

    li t6, 0x22
    sb t6, 4(s0)
    li t0, 0x33
    sb t0, 5(s0)
    li t1, 0x44
    sb t1, 6(s0)
    li t2, 0x55
    sb t2, 7(s0)

    li s1, 0x00011000
    li t3, 0x99
    sb t3, 0(s1)
    li t4, 0x88
    sb t4, 1(s1)

    lbu a7, 4(s0)
    lbu s2, 5(s0)
    lbu s3, 6(s0)
    lbu s4, 7(s0)

    li s5, 0x00010010
    li t5, 0x77
    sb t5, 0(s5)
    lbu t6, 0(s5)
    li t0, 0x66
    sb t0, 1(s5)
    lbu t1, 1(s5)

    li s6, 0x00010020
    li t2, 0xFF
    sb t2, 0(s6)
    sb t2, 1(s6)
    sb t2, 2(s6)
    sb t2, 3(s6)
    lw t3, 0(s6)

    li s7, 0x00010030
    li t4, 0xFF
    sb t4, 0(s7)
    lb t5, 0(s7)

    li s8, 0x00010040
    li t6, 10
    sb t6, 0(s8)
    addi t6, t6, 1
    sb t6, 1(s8)
    addi t6, t6, 1
    sb t6, 2(s8)
    addi t6, t6, 1
    sb t6, 3(s8)
    addi t6, t6, 1
    sb t6, 4(s8)
    addi t6, t6, 1
    sb t6, 5(s8)
    addi t6, t6, 1
    sb t6, 6(s8)
    addi t6, t6, 1
    sb t6, 7(s8)

    li s9, 0x00012000
    li ra, 0xAB
    sb ra, 0(s9)
    lbu sp, 0(s9)

    lbu gp, 0(s8)
    lbu tp, 1(s8)
    lbu s10, 2(s8)
    lbu s11, 3(s8)

    add a0, a1, a2
    add a0, a0, a3
    add a0, a0, a4
    add a0, a0, a5
    add a0, a0, a6
    add a0, a0, a7
    add a0, a0, s2
    add a0, a0, s3
    add a0, a0, s4
    add a0, a0, t6
    add a0, a0, t1
    add a0, a0, sp
    add a0, a0, gp
    add a0, a0, tp
    add a0, a0, s10
    add a0, a0, s11

finish:
    bne a0, zero, finish