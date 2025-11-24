#include "control_unit_testbench.h"

class ControlUnitTests : public ControlUnitTestbench{
};

//-------------------------------------------
// R-TYPE (ADD)
TEST_F(ControlUnitTests, RType_Add){

    setOpF7F3(
        0b0110011,   // opcode (R-type)
        0b0000000, 
        0b000
    );

    setFlags(0, 0);
    runSimulation(1);

    EXPECT_EQ(top_->RegWrite, 1);
    EXPECT_EQ(top_->ALUSrc,   0);
    EXPECT_EQ(top_->MemWrite, 0);
    EXPECT_EQ(top_->ResultSrc,0);
    EXPECT_EQ(top_->Branch,   0);
    EXPECT_EQ(top_->Jump,     0);
}

//---------------------------------------------------
// I-TYPE (LW)
TEST_F(ControlUnitTests, LoadWord){

    setOpF7F3(
        0b0000011,   // opcode (LOAD)
        0,           // funct7 unused
        0b010        // funct3 = LW
    );

    runSimulation(1);

    EXPECT_EQ(top_->RegWrite, 1);
    EXPECT_EQ(top_->ALUSrc,   1);
    EXPECT_EQ(top_->MemWrite, 0);
    EXPECT_EQ(top_->ResultSrc,1);
    EXPECT_EQ(top_->ImmSrc,   0); // I-Type
}

//---------------------------------------------------------
// S-TYPE (SW)
TEST_F(ControlUnitTests, StoreWord){

    setOpF7F3(
        0b0100011,   // opcode (STORE)
        0,
        0b010        // SW
    );

    runSimulation(1);

    EXPECT_EQ(top_->RegWrite, 0);
    EXPECT_EQ(top_->MemWrite, 1);
    EXPECT_EQ(top_->ALUSrc,   1);
    EXPECT_EQ(top_->ImmSrc,   1); // S-Type
}

//---------------------------------------------
// B-TYPE (BEQ)
TEST_F(ControlUnitTests, Branch_Taken){

    setOpF7F3(
        0b1100011,   // branch
        0,
        0b000        // BEQ
    );

    setFlags(1, 0);  // zero = 1 (A == B)
    runSimulation(1);

    EXPECT_EQ(top_->Branch, 1);
    EXPECT_EQ(top_->PCSrc,  1);
}

TEST_F(ControlUnitTests, Branch_NotTaken){

    setOpF7F3(
        0b1100011,  
        0,
        0b000        // BEQ
);

    setFlags(0, 0);  // zero = 0 (A != B)
    runSimulation(1);

    EXPECT_EQ(top_->Branch, 1);
    EXPECT_EQ(top_->PCSrc,  0);
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

    EXPECT_EQ(top_->Jump,     1);
    EXPECT_EQ(top_->PCSrc,    1); 
    EXPECT_EQ(top_->RegWrite, 1);
    EXPECT_EQ(top_->ResultSrc,2); // PC+4
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
    EXPECT_EQ(top_->ALUSrc,   1);
    EXPECT_EQ(top_->ImmSrc,   0b011); // correct for LUI
}

TEST_F(ControlUnitTests, UType_AUIPC) {

    // opcode 0010111 = AUIPC
    setOpF7F3(0b0010111, 0, 0);

    runSimulation(1);

    EXPECT_EQ(top_->RegWrite, 1);
    EXPECT_EQ(top_->ALUSrc,   1);
    EXPECT_EQ(top_->ImmSrc,   0b100); // correct for AUIPC
}

//---------------------------------------
//default invalid case opcode
TEST_F(ControlUnitTests, InvalidOpcode){
    setOpF7F3(
        0b1111111,   // invalid opcode
        0b0000000,
        0b000
    );

    runSimulation(1);

    // NOP
    EXPECT_EQ(top_->RegWrite, 0);
    EXPECT_EQ(top_->ALUSrc,   0);
    EXPECT_EQ(top_->MemWrite, 0);
    EXPECT_EQ(top_->ResultSrc,0);
    EXPECT_EQ(top_->ImmSrc,   0);
    EXPECT_EQ(top_->Branch,   0);
    EXPECT_EQ(top_->Jump,     0);
}


int main(int argc, char **argv){
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
