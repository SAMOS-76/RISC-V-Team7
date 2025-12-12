# test BGE + JALR forwarding issue
# should be a0 = 7
# tests if values are correctly forwarded after BGE branches

main:
    li a0, 0
    li t0, 0
    li t1, 2
    
loop:
    bge t0, t1, done
    
    jal ra, add_one
    
    addi t0, t0, 1
    j loop
    
add_one:
    addi a0, a0, 1
    ret
    
done:
    j end
