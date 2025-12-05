.text
.globl main
.equ base_data, 0x10000
.equ array_len, 512

main:
    li      a0, 0
    li      a1, base_data
    li      a2, array_len
    
loop:
    lw      t0, 0(a1)      # miss, hit, hit, hit

    add     a0, a0, t0
    addi    a1, a1, 4
    addi    a2, a2, -1
    bne     a2, zero, loop
    
    j       finish

finish:
    j       finish
