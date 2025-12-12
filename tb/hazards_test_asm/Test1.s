.globl _start
_start:
    li      t0, 10
    li      t1, -5
    mul     t2, t0, t1
    li      t3, 20
    mul     t4, t3, t0
    add     a0, t2, t4      # a0 = 150

stop:
    j       stop
