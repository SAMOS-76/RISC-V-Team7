#include "memory_testbench.h"
#include <iostream>

class MemoryTests : public MemoryTestbench {
protected:
    void SetUp() override {
        MemoryTestbench::SetUp();
        reset(); 
    }
};

TEST_F(MemoryTests, CompulsoryMissAndRefill){

    //cache empty
    uint32_t data = cpuRead(0x10000);
    
    // did it return?, wait for stall finsihed
    EXPECT_EQ(top_->stall, 0);
    std::cout <<"  Data read: 0x" << std::hex << data << std::dec << std::endl;
}

TEST_F(MemoryTests, ReadHit_LatencyCheck) {
    // load it in - miss pennalty intially
    cpuRead(0x10004); 
    cpuRead(0x10004);
    
    runSimulation(1);
    
    // shoudlnt miss again or stall 
    EXPECT_EQ(top_->stall, 0);
    
    top_->mem_read = 0;
}

TEST_F(MemoryTests, WriteHit_And_ReadBack) {

    cpuWrite(0x10008, 0xA4C1EAFF);

    uint32_t val = cpuRead(0x10008);
    
    EXPECT_EQ(val, 0xA4C1EAFF);
    std::cout << "  Read value: 0x" << std::hex << val << std::dec << std::endl;
}

TEST_F(MemoryTests, TwoWayAssociativity){
    // [31:11] Tag (21 bits) , [10:4] Set (7 bits) , [3:0] Offset (4 bits)
    // chnage tag bits 

    uint32_t addrA = 0x00010000; // Tag=0x00008, set=0, Offset=0
    uint32_t addrB = 0x00010800; // Tag=0x00008 + 1, Set=0, offset=0
    uint32_t addrC = 0x00011000; // Tag=0x00008 + 2, Set=0, Offset=0

    cpuWrite(addrA, 0xAAAAAAAA);
    cpuWrite(addrB, 0xBBBBBBBB);
    
    uint32_t valA1 = cpuRead(addrA);
    uint32_t valB1 = cpuRead(addrB);
    EXPECT_EQ(valA1, 0xAAAAAAAA);
    EXPECT_EQ(valB1, 0xBBBBBBBB);

    // c - evict absed on LRU ofc 
    cpuWrite(addrC, 0xCCCCCCCC);
    
    // c should be incache now
    uint32_t valC = cpuRead(addrC);
    EXPECT_EQ(valC, 0xCCCCCCCC);
    
    //hard to test without all signals but
    //reading A should miss now
    // but main mem should still be correct.
    uint32_t valA2 = cpuRead(addrA);
    EXPECT_EQ(valA2, 0xAAAAAAAA);
}

TEST_F(MemoryTests, ByteAndHalfwordAccess){
   
    uint32_t addr = 0x00012000;
    uint32_t data = 0x12345678;
    cpuWrite(addr, data);
    
    //bytes
    uint32_t byte0 = cpuReadByte(addr + 0);  //78
    uint32_t byte1 = cpuReadByte(addr + 1);  //56
    uint32_t byte2 = cpuReadByte(addr + 2);  //34
    uint32_t byte3 = cpuReadByte(addr + 3);  //12
    
    EXPECT_EQ(byte0, 0x00000078);
    EXPECT_EQ(byte1, 0x00000056);
    EXPECT_EQ(byte2, 0x00000034);
    EXPECT_EQ(byte3, 0x00000012);
    
    //halfss
    uint32_t half0 = cpuReadHalf(addr + 0);  //5678
    uint32_t half1 = cpuReadHalf(addr + 2);  //1234
    
    EXPECT_EQ(half0, 0x00005678);
    EXPECT_EQ(half1, 0x00001234);
}

TEST_F(MemoryTests, DirtyWriteback){

    uint32_t addr1 = 0x00013000;
    uint32_t addr2 = 0x00013000 + 0x1000;  //same set, different tag, conflicts with addr1
    
    //write 1,  brings into cache, sets dirty bit
    cpuWrite(addr1, 0x00112233);
    
    // evict 1 if same set, force wb
    cpuWrite(addr2, 0x99991111);
    
    // read 1, fetch from main now
    uint32_t val = cpuRead(addr1);
    
    EXPECT_EQ(val, 0x00112233);
}

int main(int argc, char **argv) {
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
