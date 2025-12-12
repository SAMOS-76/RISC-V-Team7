.globl _start
_start:
    li      t0, 0x80000000
    mulh    t1, t0, t0      
    li      t2, -1          # Loads 0xFFFFFFFF
    mulhu   t3, t2, t2      # t3 = 0xFFFFFFFE
    add     a0, t1, t3

stop:
    j       stop
