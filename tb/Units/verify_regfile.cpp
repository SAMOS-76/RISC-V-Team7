#include "regfile_testbench.h"

class RegFileTests : public RegFileTestbench{
protected:
    void SetUp() override {
        RegFileTestbench::SetUp();
        reset(); // reset before every test
    }
};

TEST_F(RegFileTests, WriteAndRead){
    writeReg(1, 0x12345678);
    EXPECT_EQ(readReg1(1), 0x12345678);
    EXPECT_EQ(readReg2(1), 0x12345678);
}

TEST_F(RegFileTests, ResetBehavior){
    writeReg(5, 0xFF);
    EXPECT_EQ(readReg1(5), 0xFF);
    
    top_->rst = 1; 
    tick();
    top_->rst = 0;
    
    //REG 5 should now be cleared to 0
    EXPECT_EQ(readReg1(5), 0);
}

TEST_F(RegFileTests, CheckZeroBehavior){
    // RISC-V Rule,  Register 0 is HARDWIRED to 0.
    // it shouldn't be writable -- even if write_en is high.
    
    writeReg(0, 0xDEADBEEF); // Try to write to x0
    
    // expect to Read back 0
    EXPECT_EQ(readReg1(0), 0);
}

TEST_F(RegFileTests, WriteEnableLow){
    top_->a3 = 10;
    top_->din = 0xAAAA;
    top_->write_en = 0; 
    
    tick();
    
    // 2. Read back Register 10 (should still be 0)
    EXPECT_EQ(readReg1(10), 0); 
}

TEST_F(RegFileTests, OverwriteBehavior){
    writeReg(2, 100);
    EXPECT_EQ(readReg1(2), 100);
    
    //Overwrite
    writeReg(2, 200);
    EXPECT_EQ(readReg1(2), 200);
}

int main(int argc, char **argv){
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}

//Note:
// doitunit.sh COULD include the flag -lgtest_main in the LDFLAGS:
// -LDFLAGS "-L... -lgtest -lgtest_main -lpthread"
//which would run all tests -- making the main redudant
//But I kept as I thought would be ncie to have and more obvious