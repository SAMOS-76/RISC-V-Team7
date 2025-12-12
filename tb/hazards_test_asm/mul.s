.text
.globl main
main:
    li t0, -1
    li t1, 2
    mulhu a0, t0, t1
finish:
    beq zero, zero, finish
    