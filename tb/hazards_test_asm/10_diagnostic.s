main:
    li a0, 0
    li t0, 5
    li t1, 0
    
loop:
    addi t1, t1, 1
    addi a0, a0, 5
    bne t1, t0, loop
    # a0 = 25 after loop
    
    #adding nop seems to fix here/inbetween
    jal ra, add_seven
    jal ra, add_seven
    
    j end
    
add_seven:
    addi a0, a0, 7
    ret
    
end:
    j end
    