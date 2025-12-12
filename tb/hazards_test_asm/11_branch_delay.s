# a0 = 5
#if bug exists: a0 = 10 (instruction after branch executes extra time)

main:
    li a0, 0
    li t0, 5
    li t1, 0

loop:
    addi t1, t1, 1
    bne t1, t0, skip # if t1 != 5, jump to skip
    addi a0, a0, 5  # THIS SHOULD ONLY EXECUTE ONCE (when t1=5, branch not taken)
    j end
    
skip:
    j loop

end:
    j end
