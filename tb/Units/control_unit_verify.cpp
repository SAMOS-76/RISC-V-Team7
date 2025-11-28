#include "control_unit_testbench.h"

class ControlUnitTests : public ControlUnitTestbench{
};

//-------------------------------------------
// R-TYPE (ADD)
TEST_F(ControlUnitTests, RType_Add){

    setOpF7F3(
        0b0110011,
        0b0000000, 
        0b000
    );

    setFlags(0, 0);
    runSimulation(1);

    EXPECT_EQ(top_->RegWrite, 1);
    EXPECT_EQ(top_->ALUSrcB,  0);
    EXPECT_EQ(top_->ALUSrcA,  0); // check A is 0
    EXPECT_EQ(top_->MemWrite, 0);
    EXPECT_EQ(top_->ResultSrc,0);
    EXPECT_EQ(top_->PCSrc,    0); // checks logic of Branch/Jump internally
}

//---------------------------------------------------
// I-TYPE (LW)
TEST_F(ControlUnitTests, LoadWord){

    setOpF7F3(
        0b0000011,
        0,
        0b010
    );

    runSimulation(1);

    EXPECT_EQ(top_->RegWrite, 1);
    EXPECT_EQ(top_->ALUSrcB,  1);
    EXPECT_EQ(top_->MemWrite, 0);
    EXPECT_EQ(top_->ResultSrc,1);
    EXPECT_EQ(top_->ImmSrc,   0); 
}

//---------------------------------------------------------
// S-TYPE (SW)
TEST_F(ControlUnitTests, StoreWord){

    setOpF7F3(
        0b0100011,
        0,
        0b010
    );

    runSimulation(1);

    EXPECT_EQ(top_->RegWrite, 0);
    EXPECT_EQ(top_->MemWrite, 1);
    EXPECT_EQ(top_->ALUSrcB,  1);
    EXPECT_EQ(top_->ImmSrc,   1); 
}

//---------------------------------------------
// B-TYPE (BEQ)
TEST_F(ControlUnitTests, Branch_Taken){

    setOpF7F3(
        0b1100011,
        0,
        0b000
    );

    setFlags(1, 0);  // zero = 1 (A == B)
    runSimulation(1);

    EXPECT_EQ(top_->PCSrc,  1);
    EXPECT_EQ(top_->ALUSrcB, 0);
}

TEST_F(ControlUnitTests, Branch_NotTaken){

    setOpF7F3(
        0b1100011,  
        0,
        0b000        // BEQ
    );

    setFlags(0, 0);  // zero = 0 (A != B)
    runSimulation(1);

    EXPECT_EQ(top_->PCSrc,  0); // branch wasnt taken
}

//-------------------------------------
// J-TYPE (JAL)
TEST_F(ControlUnitTests, Jump_JAL){

    setOpF7F3(
        0b1101111, 
        0, 
        0
    );

    runSimulation(1);

    //JAL is using PC-relative addressing, so TargetSrc must be 0
    // using our PCTarget mux 
    EXPECT_EQ(top_->PCTargetSrc, 0); 
    
    EXPECT_EQ(top_->PCSrc,       1); // Jump = 1 implies PCSrc = 1
    EXPECT_EQ(top_->RegWrite,    1); // Write return address (PC+4)
    EXPECT_EQ(top_->ResultSrc,   2); // 2 = PC+4
}

//------------------------------------------
//U-Type
TEST_F(ControlUnitTests, UType_LUI){

    setOpF7F3(
        0b0110111, 
        0, 
        0);

    runSimulation(1);

    EXPECT_EQ(top_->RegWrite, 1);
    EXPECT_EQ(top_->ALUSrcB,  1);
    EXPECT_EQ(top_->ImmSrc,   0b011); 
}

TEST_F(ControlUnitTests, UType_AUIPC) {

    // opcode 0010111 = AUIPC
    setOpF7F3(0b0010111, 0, 0);

    runSimulation(1);

    EXPECT_EQ(top_->RegWrite, 1);
    EXPECT_EQ(top_->ALUSrcA,  1);
    EXPECT_EQ(top_->ALUSrcB,  1);
    EXPECT_EQ(top_->ImmSrc,   0b011);
}

//---------------------------------------
//default invalid case opcode
TEST_F(ControlUnitTests, InvalidOpcode){
    setOpF7F3(
        0b1111111,
        0b0000000,
        0b000
    );

    runSimulation(1);

    // NOP
    EXPECT_EQ(top_->RegWrite, 0);
    EXPECT_EQ(top_->ALUSrcB,  0);
    EXPECT_EQ(top_->MemWrite, 0);
    EXPECT_EQ(top_->ResultSrc,0);
    EXPECT_EQ(top_->ImmSrc,   0);
    EXPECT_EQ(top_->PCSrc,    0);
}

int main(int argc, char **argv){
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}