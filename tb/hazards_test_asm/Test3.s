.globl _start
_start:
    li      a0, 3

    mul     a0, a0, a0      
    mul     a0, a0, a0      
    mul     a0, a0, a0      
    mul     a0, a0, a0     

stop:
    j       stop
