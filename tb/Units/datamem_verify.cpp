#include "datamem_testbench.h"
//works with empty datahex as overwrites
// signed and unsigned tests done 

// Define RW Type Macros
#define BYTE 0
#define HALF 1
#define WORD 2

class DataMemTests : public DataMemTestbench {
};

TEST_F(DataMemTests, Word_ReadWrite){
    writeMem(0x100, 0xAABBCCDD, WORD);
    
    uint32_t val  = readMem(0x100, WORD, 0);
    EXPECT_EQ(val, 0xAABBCCDD);
}

TEST_F(DataMemTests, Byte_ReadWrite){
    writeMem(0x200, 0x55, BYTE);
    
    uint32_t val = readMem(0x200, BYTE, 0); // sign_ext = 0
    EXPECT_EQ(val , 0x55);
}

TEST_F(DataMemTests, HalfWord_ReadWrite) {
    writeMem (0x300, 0x1234, HALF);
    
    uint32_t val = readMem(0x300, HALF, 0);
    EXPECT_EQ(val, 0x1234);
}

TEST_F(DataMemTests, SignExtension_Byte){
    writeMem(0x400,  0xFF, BYTE);
    
    uint32_t val_u = readMem(0x400, BYTE, 0); 
    EXPECT_EQ(val_u , 0x000000FF);

    uint32_t val_s = readMem(0x400, BYTE, 1); 
    EXPECT_EQ(val_s,  0xFFFFFFFF);
}

TEST_F(DataMemTests, SignExtension_Half){
    writeMem(0x500, 0xFFFF, HALF);

    uint32_t val_u = readMem(0x500, HALF, 0); 
    EXPECT_EQ(val_u , 0x0000FFFF);

    uint32_t val_s = readMem(0x500, HALF, 1); 
    EXPECT_EQ (val_s, 0xFFFFFFFF);
}

int main(int argc, char **argv) {
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}