.globl _start
_start:
    li      t0, -100
    li      t1, 7
    div     t2, t0, t1   
    rem     t3, t0, t1   

    add     a0, t2, t3      # a0 = -16

stop:
    j       stop
