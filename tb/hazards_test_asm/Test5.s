.globl _start
_start:
    li      t0, -16    
    li      t1, 2
    divu    t2, t0, t1     
    remu    t3, t0, t1     

    or      a0, t2, t3  

stop:
    j       stop
