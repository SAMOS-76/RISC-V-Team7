#include "gtest/gtest.h"
#include "Valu.h"
#include "verilated.h"

class TestALU : public ::testing::Test {
protected:
    Valu* alu;

    void SetUp() override {
        alu = new Valu;
    }

    void TearDown() override {
        delete alu;
    }

    void evalALU(int inA, int inB, int alu_op) {
        alu->inA = inA;
        alu->inB = inB;
        alu->alu_op = alu_op;
        alu->eval();  // Evaluate combinational logic
    }
};

TEST_F(TestALU, AddTest) {
    evalALU(2, 4, 0); // op=0: add
    EXPECT_EQ(alu->result, 6);
}

TEST_F(TestALU, SubTest) {
    evalALU(7, 3, 1); // op=1: sub
    EXPECT_EQ(alu->result, 4);
}

TEST_F(TestALU, AndTest) {
    evalALU(6, 3, 2); // op=2: and
    EXPECT_EQ(alu->result, 2);
}

TEST_F(TestALU, OrTest) {
    evalALU(6, 3, 3); // op=3: or
    EXPECT_EQ(alu->result, 7);
}

int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}