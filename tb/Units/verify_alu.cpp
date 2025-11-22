#include "alu_testbench.h"

#define ALU_ADD  0 // 4'b0000
#define ALU_SUB  8 // 4'b1000
#define ALU_AND  7 // 4'b0111 
#define ALU_OR   6 // 4'b0110
#define ALU_SLT  2 // 4'b0010

TEST_F(AluTestbench, AdditionTest){
    // 10 + 20 = 30
    evalALU(ALU_ADD, 10, 20); 
    EXPECT_EQ(top_->result, 30);
    EXPECT_EQ(top_->zero, 0);
}

TEST_F(AluTestbench, SubtractionTest){
    // 100 - 100 = 0
    evalALU(ALU_SUB, 100, 100);
    EXPECT_EQ(top_->result, 0);
    EXPECT_EQ(top_->zero, 1); // Check Zero Flag
}

TEST_F(AluTestbench, NegativeResult){
    // 10 - 20 = -10 (represented as unsigned 32-bit in C++
    //be explicit with expected type
    evalALU(ALU_SUB, 10, 20);
    uint32_t expected = -10; 
    EXPECT_EQ(top_->result, expected);
}

TEST_F(AluTestbench, SetLessThanSigned){
    // -10 < 5 ? Yes: 1
    //casting int32_t to ensure C++ handles the negative literal correctly for input
    evalALU(ALU_SLT, (uint32_t)-10, 5);
    EXPECT_EQ(top_->result, 1);
    
    // 10 < 5 ? No:0
    evalALU(ALU_SLT, 10, 5);
    EXPECT_EQ(top_->result, 0);
}

int main(int argc, char **argv){
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}