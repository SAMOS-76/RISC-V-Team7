#include "[MODULE]_testbench.h"

// define Test Fixture
class [Module]Tests : public [Module]Testbench{
protected: 
    void SetUp() override {
        [Module]Testbench::SetUp();
        // optional isto Reset at the start of every test
        // reset(); 
    }
};

//test cases

TEST_F([Module]Tests, SanityCheck){
    top_->[input_signal] = 10;
    
    // Use tick() for single step or runSimulation(N) for multiple cycles
    runSimulation(1); 

    //check Outputs
    EXPECT_EQ(top_->[output_signal], 10);
}

TEST_F([Module]Tests, LongRunningTest){
    // Example: Wait for 10 cycles to see if output remains stable
    top_->[input_signal] = 0xFF;
    runSimulation(10);
    EXPECT_EQ(top_->[output_signal], 0xFF);
}

int main(int argc, char **argv) {
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}