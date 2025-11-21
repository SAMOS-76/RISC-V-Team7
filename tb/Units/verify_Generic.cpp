#include "[MODULE]_testbench.h"

// 1: Define a Test Fixture
// This allows us to run setup code (like resetting) before EVERY test
class [Module]Tests : public [Module]Testbench{
protected: 
    void SetUp() override {
        [Module]Testbench::SetUp();
        // Optional: Always reset before a test starts
        // reset(); 
    }
};

//2: Write Test Cases
// TEST_F(TestFixtureName, TestCaseName)

TEST_F([Module]Tests, SanityCheck){
    // setup Inputs
    top_->[input_signal] = 10;
    
    // execute (Tick the clock or Evaluate)
    //top -> eval(); evaluate at current point
    tick(); 

    // check Outputs
    EXPECT_EQ(top_->[output_signal], 10);
}

TEST_F([Module]Tests, EdgeCaseExample){
    // Example: Testing Max Value
    top_->[input_signal] = 0xFFFFFFFF;
    tick();
    EXPECT_EQ(top_->[output_signal], 0);
}

// Step 3: Main Function
// Required because I removed -lgtest_main from the doitunit script
int main(int argc, char **argv) {
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}