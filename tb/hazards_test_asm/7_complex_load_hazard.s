.text
.globl main

main:
addi    x1, zero, 1
addi    a0, zero, 2

sw     a0, 0(x1)
lw     x1, 0(x1)

add    x2, x1, x1

add    a0, x2, x1






#should output 6
