.text
.globl main
main:
    li s0, 0x00010000

    # Store word values
    li t1, 100
    sw t1, 0(s0)
    li t2, 200
    sw t2, 4(s0)

    # Load them back
    lw t3, 0(s0)
    lw t4, 4(s0)
    add a0, t3, t4
    bne a0, zero, finish

finish:
    bne a0, zero, finish
