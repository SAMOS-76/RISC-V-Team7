#include "sign_extend_testbench.h"

#define I 0 // 3'b000
#define S 1 // 3'b001
#define B 2 // 3'b010
#define U 3 // 3'b011
#define J 4 // 3'b100

class SignExtendTests : public SignExtendTestbench{
};

TEST_F(SignExtendTests, I_type_Positive){
    uint32_t instr = 0x12300000; 
    setInputs(I, instr);
    runSimulation(1);
    EXPECT_EQ(getOutput(), 0x00000123);
}

TEST_F(SignExtendTests, I_type_Negative){
    // instr[31] = 1 ... negative
    uint32_t instr = 0xFFF00000; 
    setInputs(I, instr);
    runSimulation(1);
    EXPECT_EQ(getOutput(), 0xFFFFFFFF);
}

// Logic: {{20{instr[31]}}, instr[31:25], instr[11:7]}
TEST_F(SignExtendTests, S_type){
    // 31-25 = 0000001 (1), 11-7 = 00001 (1) -> Imm = 0x021 (33) 00100001
    uint32_t instr = (1 << 25) | (1 << 7);
    setInputs(S, instr);
    runSimulation(1);
    EXPECT_EQ(getOutput(), 0x00000021);
}

TEST_F(SignExtendTests, B_type){
    // instr = 31:25=0 00001, 11:8=0001, 7=1
    uint32_t instr = (1 << 7) | (1 << 25) | (1 << 8);
    //imm  = 0 1 000001 0001 0 = 0x0822 ... LSB always 0
    setInputs(B, instr);
    runSimulation(1);

    EXPECT_EQ(getOutput(), 0x00000822);
}


// U-type immediate = instr[31:12] << 12 (LUI/AUIPC format)
TEST_F(SignExtendTests, U_type){
    //upper 20 bits should be copied, lower 12 zeroed.
    uint32_t instr = 0xABCDE123;
    setInputs(U, instr);
    runSimulation(1);
    EXPECT_EQ(getOutput(), 0xABCDE000);
}

TEST_F(SignExtendTests, J_type_vnegative){
 //obvious instruct setup for ISA - reading tests should be easyier like this
    uint32_t instr = 0;
    instr |= (1 << 31); //negative
    instr |= (0xAC << 12);
    instr |= (1 << 20); 
    instr |= (0x201 << 21);

    uint32_t expected = (1 << 20)
                      | (0xAC << 12)
                      | (1 << 11)
                      | (0x201 << 1);
             expected |= 0xFFE00000; //set 31:21->1

    setInputs(J, instr);
    runSimulation(1);
    EXPECT_EQ(getOutput(), expected);
}


int main(int argc, char **argv){
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
