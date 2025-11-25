#include "regfile_testbench.h"

class RegFileTests : public RegFileTestbench{
protected:
    void SetUp() override {
        RegFileTestbench::SetUp();
        reset(); 
    }
};

TEST_F(RegFileTests, DualWriteRead){
    writeReg(3, 0xAAA);
    writeReg(10, 0xBBB);

    top_->a1 = 3;
    top_->a2 = 10;

    runSimulation(1);

    EXPECT_EQ(readReg1(3), 0xAAA);
    EXPECT_EQ(readReg2(10), 0xBBB);
}

//this test is ofc redudant as x0 always 0
//however logic is sueful is we decide to full reset all 32.
TEST_F(RegFileTests, ResetBehavior){
    writeReg(0, 0xFF);
    EXPECT_EQ(readReg1(0), 0);
    top_->rst = 1; 

    runSimulation(5); 
    
    top_->rst = 0;
    EXPECT_EQ(readReg1(0), 0);
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

TEST_F(RegFileTests, WriteEveryone){
    for (int i = 1; i < 32; i++) {
        writeReg(i, i * 0xA1A1A1A1);
    }
    for (int i = 1; i < 32; i++) {
        EXPECT_EQ(readReg1(i), uint32_t(i * 0xA1A1A1A1));
    }
}


TEST_F(RegFileTests, OverwriteBehavior){
    writeReg(2, 100);
    EXPECT_EQ(readReg1(2), 100);
    
    writeReg(2, 200);
    EXPECT_EQ(readReg1(2), 200);
}

//this test may change when we pipeline -pos/negedge
TEST_F(RegFileTests, ReadDuringWriteSameReg){
    writeReg(5, 0xAAAA5555);
    EXPECT_EQ(readReg1(5), 0xAAAA5555);

    //attempt write of new value, but read in same cycle
    top_->a1 = 5;
    top_->a3 = 5; 
    top_->din = 0xDEADBEEF;
    top_->write_en = 1;

    //read before edge
    EXPECT_EQ(readReg1(5), 0xAAAA5555);

    runSimulation(1);   // posedge

    // after - should be new value
    EXPECT_EQ(readReg1(5), 0xDEADBEEF);
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