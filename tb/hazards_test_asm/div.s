.text
.globl main
main:
    li t0, 22
    li t1, 4
    remu a0, t0, t1
finish:
    beq zero, zero, finish
    