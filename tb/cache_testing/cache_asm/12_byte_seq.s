.text
.globl main
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

    add a0, a1, a2
    add a0, a0, a3
    add a0, a0, a4

finish:
    bne a0, zero, finish
