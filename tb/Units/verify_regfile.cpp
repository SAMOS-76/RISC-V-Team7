#include "regfile_testbench.h"

class RegFileTests : public RegFileTestbench{
protected:
    void SetUp() override {
        RegFileTestbench::SetUp();
        reset(); 
    }
};

TEST_F(RegFileTests, WriteAndRead){
    // 1. Write 0x12345678 to Register 1
    writeReg(1, 0x12345678);
    
    // 2. Read it back
    EXPECT_EQ(readReg1(1), 0x12345678);
    EXPECT_EQ(readReg2(1), 0x12345678);
}

TEST_F(RegFileTests, ResetBehavior){
    // 1. Write data to register 5
    writeReg(5, 0xFF);
    EXPECT_EQ(readReg1(5), 0xFF);
    top_->rst = 1; 

    runSimulation(5); 
    
    top_->rst = 0;
    EXPECT_EQ(readReg1(5), 0);
}

TEST_F(RegFileTests, CheckZeroBehavior){
    // RISC-V Rule: x0 is hardwired to 0
    writeReg(0, 0xDEADBEEF); 
    EXPECT_EQ(readReg1(0), 0);
}

TEST_F(RegFileTests, WriteEnableLow){
    top_->a3 = 10;
    top_->din = 0xAAAA;
    top_->write_en = 0; 

    runSimulation(1); 
    
    EXPECT_EQ(readReg1(10), 0); 
}

TEST_F(RegFileTests, OverwriteBehavior){
    writeReg(2, 100);
    EXPECT_EQ(readReg1(2), 100);
    
    writeReg(2, 200);
    EXPECT_EQ(readReg1(2), 200);
}

TEST_F(RegFileTests, SimulationStressTest){
    // run for 100 cycles to ensure no drift/glitches
    runSimulation(100); 
    EXPECT_EQ(readReg1(0), 0);
}

int main(int argc, char **argv){
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}