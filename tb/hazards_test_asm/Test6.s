.globl _start
_start:
    li      t0, 5
    li      t1, 4
    li      t2, 3
    li      t3, 2

    mul     s0, t0, t1      # s0 = 20
    mul     s1, s0, t2      # s1 = 60

    add     s2, s1, t0      # s2 = 60 + 5 = 65 (Just noise)
    div     a0, s1, t3      # a0 = 30

stop:
    j       stop
