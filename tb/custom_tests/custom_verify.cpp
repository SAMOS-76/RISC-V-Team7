#include <cstdlib>
#include <utility>

#include "custom_cpu_testbench.h"

#define CYCLES 10000

TEST_F(CpuTestbench, Test1)
{
    setupTest("Test1");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 150);
}

TEST_F(CpuTestbench, Test2)
{
    setupTest("Test2");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 1073741822);
}


TEST_F(CpuTestbench, Test3)
{
    setupTest("Test3");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 43046721);
}


TEST_F(CpuTestbench, TestMul)
{
    setupTest("mul");
    initSimulation();
    runSimulation(20000);
    EXPECT_EQ(top_->a0, 1);
}


int main(int argc, char **argv)
{
    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();
    return res;
}
