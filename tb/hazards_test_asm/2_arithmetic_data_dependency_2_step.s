.text
.globl main

main:
addi    x5, zero, 10
addi    x6, zero, 5
addi    x7, zero, 1
add     a0, x6, x5

#should output 15
