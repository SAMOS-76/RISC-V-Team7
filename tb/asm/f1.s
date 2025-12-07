main:
    li      a0, 0   # output register: a0 
    li      t0, 0   # iteration counter: t0

    li      t1, 8   # iteration number

loop:   #loops until t0 = 8 (light sequence complete)

    bge     t0, t1, lights_out    
    jal     ra, increase       
    addi    t0, t0, 1
    j       loop

increase: #adds another light

    slli    t2, a0, 1
    addi    a0, t2, 1
    RET     #returning to loop

lights_out:
    li      a0, 0


end:
    j     end
