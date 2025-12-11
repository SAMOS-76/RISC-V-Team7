#include <cstdlib>
#include <utility>

#include "../tests/cpu_testbench.h"

#define CYCLES 10000

// Cache-specific testbench class
class CacheTestbench : public CpuTestbench {
protected:
    void setupCacheTest(const std::string &name) {
        name_ = name;
        std::ignore = system(("./assemble.sh cache_testing/cache_asm/" + name_ + ".s").c_str());
        std::ignore = system("touch data.hex");
    }

    void initSimulation() {
        top_ = new Vdut(context_);
        tfp_ = new VerilatedVcdC;

        Verilated::traceEverOn(true);
        top_->trace(tfp_, 99);
        tfp_->open(("cache_testing/test_out/" + name_ + "/waveform.vcd").c_str());

        top_->clk = 1;
        top_->rst = 1;
        top_->trigger = 0;
        runSimulation(10);
        top_->rst = 0;
    }

    void TearDown() override {
        top_->final();
        tfp_->close();

        if (top_) delete top_;
        if (tfp_) delete tfp_;
        delete context_;

        std::ignore = system(("mv data.hex cache_testing/test_out/" + name_ + "/data.hex").c_str());
        std::ignore = system(("mv program.hex cache_testing/test_out/" + name_ + "/program.hex").c_str());
    }
};


TEST_F(CacheTestbench, TestHalfwordSL)
{
    setupCacheTest("6_halfword");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 300);
}


TEST_F(CacheTestbench, TestWordSL)
{
    setupCacheTest("7_word");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 300);
}


TEST_F(CacheTestbench, TestByteSL)
{
    setupCacheTest("8_byte");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 214);
}


TEST_F(CacheTestbench, TestHalfwordComplex)
{
    setupCacheTest("9_halfword_complex");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 211525);
}


TEST_F(CacheTestbench, TestWordComplex)
{
    setupCacheTest("10_word_complex");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 1987458259); //XOR all
}


TEST_F(CacheTestbench, TestByteComplex)
{
    setupCacheTest("11_byte_complex");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 1645);
}


TEST_F(CacheTestbench, TestByteSeq)
{
    setupCacheTest("12_byte_seq");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 760);
}

int main(int argc, char **argv)
{
    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();
    return res;
}
