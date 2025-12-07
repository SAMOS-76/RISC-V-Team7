main:
    # init mem
    li t0, 0x10000
    li t1, 1
    sb t1, 0(t0)
    li t1, 2
    sb t1, 1(t0)
    li t1, 3
    sb t1, 2(t0)
    li t1, 4
    sb t1, 3(t0)
    li t1, 5
    sb t1, 4(t0)
    
    li a0, 0
    li t2, 0 
    li t3, 5

sum_loop:
    add t4, t0, t2  # t4 = base + index
    lbu t5, 0(t4)   # t5 = mem[base + index]
    add a0, a0, t5
    addi t2, t2, 1
    bne t2, t3, sum_loop

    # a0 should be 15
    
end:
    j end
    