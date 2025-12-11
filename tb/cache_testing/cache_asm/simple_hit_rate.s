
main:
    li s0, 0x00010000 
    li s1, 0
    li s2, 10

    # spatial locality
write_loop:
    slli t0, s1, 2
    add t1, s0, t0
    sw s1, 0(t1)
    addi s1, s1, 1
    blt s1, s2, write_loop

    # temporal locality
    li s1, 0
read_loop1:
    slli t0, s1, 2
    add t1, s0, t0
    lw t2, 0(t1)
    addi s1, s1, 1
    blt s1, s2, read_loop1

    
    li s1, 0
    li t3, 0
read_loop2:
    slli t0, s1, 2
    add t1, s0, t0
    lw t2, 0(t1) 
    add t3, t3, t2
    addi s1, s1, 1
    blt s1, s2, read_loop2

    #random accecss
    lw t4, 0(s0)
    lw t4, 16(s0)
    lw t4, 8(s0)
    lw t4, 32(s0)
    lw t4, 4(s0)
    lw t4, 20(s0)

    # sum should b 45
    add a0, t3, zero

finish:
    bne a0, zero, finish
