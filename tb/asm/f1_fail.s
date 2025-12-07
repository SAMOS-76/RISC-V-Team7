
main:
    li a0, 0
    li t0, 0
    li t1, 8
    
loop:
    bge t0, t1, done
    jal ra, shift_add
    addi t0, t0, 1
    j loop
    
shift_add:
    slli t2, a0, 1
    addi a0, t2, 1
    ret
    
done:
    j done
