.text
.globl main

main:
addi    x1, zero, 1
addi    a0, zero, 2
add    a0, x1, a0
addi   x1, a0, 1
add    a0, a0,x1
addi   a0, a0, -1
#7 in both
sw     a0, 0(x1)
lw     x1, 0(x1)
#6
add    x2, x1, x1
#12 in x2
add    a0, x2, x1






#should output 18
