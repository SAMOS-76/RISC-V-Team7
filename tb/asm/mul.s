.text
.globl main
main:
    li   t0, 5       
    li   t1, 7       
    mul  a0, t0, t1   


finish:     # expected result is 300
    bne     a0, zero, finish     # loop forever
