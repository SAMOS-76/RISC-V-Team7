.text
.globl main
main:
    li s0, 0x00010000

    li t0, 0x00010000
    li t1, 0x00012000
    li t2, 0x00014000

    # load address 1 (MISS - allocate to way 0)
    li t3, 100
    sw t3, 0(t0)
    lw t4, 0(t0)

    # Access 2: Load address 2 (MISS - allocate to way 1)
    li t3, 200
    sw t3, 0(t1)
    lw t4, 0(t1)

    lw t4, 0(t0)             # update LRU, way1 is now LRU

    # miss must evict way1 [addr2]
    # This should evict address 2 from way 1 (LRU)
    li t3, 300
    sw t3, 0(t2)
    lw t4, 0(t2)

    lw t4, 0(t1)             # MISS - addr2 was evicted

    # Set result to signal completion
    li a0, 42

finish:
    bne a0, zero, finish
