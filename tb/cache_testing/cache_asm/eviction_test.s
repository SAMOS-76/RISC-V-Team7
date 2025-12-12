.text
.globl main
main:
    # Setup addresses that map to the same cache index (2-way associative)
    # Cache: 512 sets, 4-byte lines → 2048 bytes per full cache = 0x800
    # Addresses 0x800 apart map to same index (wrap around in index bits)
    li t0, 0x00010000  # Address A
    li t1, 0x00010800  # Address B
    li t2, 0x00011000  # Address C
    li t3, 0x00011800  # Address D
    li t4, 0x00012000  # Address E

    # === Pattern to create multiple dirty evictions ===
    # Cache is 2-way associative, so 3rd access to same index causes eviction

    # 1. Write to A (MISS - allocate to way 0, mark dirty)
    li a1, 100
    sw a1, 0(t0)

    # 2. Write to B (MISS - allocate to way 1, mark dirty)
    li a1, 200
    sw a1, 0(t1)

    # 3. Write to C (MISS - evict A from way 0 as LRU, DIRTY EVICTION #1)
    li a1, 300
    sw a1, 0(t2)

    # 4. Access B to update LRU (HIT - way 0 with C is now LRU)
    lw a2, 0(t1)

    # 5. Write to D (MISS - evict C from way 0 as LRU, DIRTY EVICTION #2)
    li a1, 400
    sw a1, 0(t3)

    # 6. Access B again to update LRU (HIT - way 0 with D is now LRU)
    lw a2, 0(t1)

    # 7. Write to E (MISS - evict D from way 0 as LRU, DIRTY EVICTION #3)
    li a1, 500
    sw a1, 0(t4)

    # 8. Access B one more time (HIT - way 0 with E is now LRU)
    lw a2, 0(t1)

    # 9. Write to A again (MISS - evict E from way 0, DIRTY EVICTION #4)
    li a1, 600
    sw a1, 0(t0)

    # Verification: read back final values
    lw a2, 0(t0)  # Should be 600 (HIT)
    lw a3, 0(t1)  # Should be 200 (HIT)

    # Set result to signal completion
    li a0, 42

finish:
    bne a0, zero, finish