.text
.globl main

main:
    li      a0, 0   # output register: a0 
    li      t0, 0   # iteration counter: t0
    li      t1, 8   # iteration number
    li      s0, 16   # Stores starting value of random variable


loop:   #loops until t0 = 8 (light sequence complete)
    bge     t0, t1, lights_out    
    jal     ra, delay
    jal     ra, increase       
    addi    t0, t0, 1
    j       loop



increase: #adds another light
    slli    t2, a0, 1
    addi    a0, t2, 1
    RET     #returning to loop


delay:
    li      t3, 20
delay_loop:
    addi    t3, t3, -1
    bnez    t3, delay_loop
    RET

add_one:
    li      s0, 1

lights_out:
    beqz     s0, add_one

    srli    t4, s0, 8
    andi    t4, t4, 1
    srli    t5, s0, 4
    andi    t5, t5, 1
    xor     t6, t4, t5
    slli    s0, s0, 1
    or      s0, s0, t6
    andi    s0, s0, 0x1FF

    bnez    s0, last_delay
    li      s0, 1

last_delay:
    mv      t3, s0
    jal     ra, random_delay

    li      a0, 0
    jal     ra, delay
    j       main

random_delay:
    addi t3, t3, -1
    bnez t3, random_delay
    ret