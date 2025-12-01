.text
.globl main

main:
addi    x5, zero, 10
addi    x6, zero, 5
sb      x6, 0(x5)
add zero, zero, zero
add zero, zero, zero
add zero, zero, zero
lb      a0, 0(x5)



#should output 5
