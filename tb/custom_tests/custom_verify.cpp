#include <cstdlib>
#include <utility>

#include "custom_cpu_testbench.h"

#define CYCLES 10000

TEST_F(CpuTestbench, arithmetic_data_dependency_1_step)
{
    setupTest("1_arithmetic_data_dependency_1_step");
    initSimulation();
    runSimulation(10);
    EXPECT_EQ(top_->a0, 15);
}

int main(int argc, char **argv)
{
    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();
    return res;
}
