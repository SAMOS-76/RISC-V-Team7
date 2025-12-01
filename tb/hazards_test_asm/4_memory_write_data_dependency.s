.text
.globl main

main:
addi    x5, zero, 10
addi    x6, zero, 5
sb      x5, 0(x6)
add zero, zero, zero
add zero, zero, zero
add zero, zero, zero
lb      a0, 0(x6)



#should output 10
