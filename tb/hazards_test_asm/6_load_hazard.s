.text
.globl main

main:
addi    x5, zero, 10
addi    x6, zero, 5
sw      x5, 0(x6)
lw      a0, 0(x6)
addi     a0, a0, 1





#should output 41
