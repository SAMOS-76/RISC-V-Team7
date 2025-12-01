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

TEST_F(CpuTestbench, arithmetic_data_dependency_1_step_rb)
{
    setupTest("1_5_arithmetic_data_dependency_1_step_rb");
    initSimulation();
    runSimulation(20);
    EXPECT_EQ(top_->a0, 15);
}


TEST_F(CpuTestbench, arithmetic_data_dependency_2_step)
{
    setupTest("2_arithmetic_data_dependency_2_step");
    initSimulation();
    runSimulation(40);
    EXPECT_EQ(top_->a0, 15);
}

TEST_F(CpuTestbench, memory_write_address_dependency)
{
    setupTest("3_memory_write_address_dependency");
    initSimulation();
    runSimulation(60);
    EXPECT_EQ(top_->a0, 5);
}

TEST_F(CpuTestbench, memory_write_data_dependency)
{
    setupTest("4_memory_write_data_dependency");
    initSimulation();
    runSimulation(60);
    EXPECT_EQ(top_->a0, 10);
}

int main(int argc, char **argv)
{
    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();
    return res;
}
