#include <cstdlib>
#include <utility>
#include <iostream>
#include <iomanip>

#include "../tests/cpu_testbench.h"
#include "Vdut___024root.h"

#define CYCLES 1000000

// Cache-specific testbench class
class CacheTestbench : public CpuTestbench {
protected:
    //cache stats
    unsigned long total_cache_accesses = 0;
    unsigned long cache_hits = 0;
    unsigned long cache_misses = 0;
    unsigned long evictions = 0;
    unsigned long dirty_evictions = 0;

    void setupCacheTest(const std::string &name) {
        name_ = name;
        std::ignore = system(("./assemble.sh cache_testing/cache_asm/" + name_ + ".s").c_str());
        std::ignore = system("touch data.hex");

        //reset stats
        total_cache_accesses = 0;
        cache_hits = 0;
        cache_misses = 0;
        evictions = 0;
        dirty_evictions = 0;
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

    // Track cache metrics during simulation
    void runSimulationWithMetrics(int cycles = 1) {
        bool prev_stall = false;
        bool program_finished = false;
        int stall_cycles = 0;
        bool in_miss = false;

        for (int i = 0; i < cycles; i++) {
            // Stop tracking when program completes (a0 != 0)
            if (top_->a0 != 0 && !program_finished) {
                program_finished = true;
            }

            //sample cache stall at positive edge
            bool current_stall = top_->rootp->top__DOT__stall;
            bool mem_operation = (top_->rootp->top__DOT__mem_write == 1) ||  (top_->rootp->top__DOT__result_src == 0b01);

            // Track stall cycles independently of mem_operation
            if (current_stall && !prev_stall && mem_operation && !top_->rootp->rst && !program_finished) {
                // Start of a new miss
                cache_misses++;
                total_cache_accesses++;
                stall_cycles = 1;
                in_miss = true;
            } else if (current_stall && in_miss) {
                // Continue counting stall cycles
                stall_cycles++;
            } else if (!current_stall && in_miss) {
                // Stall ended - determine if it was dirty or clean eviction
                // Clean miss: 5 cycles (ALLOCATE 4 + UPDATE_SRAM 1)
                // Dirty miss: 9 cycles (WRITEBACK 4 + ALLOCATE 4 + UPDATE_SRAM 1)
                if (stall_cycles == 9) {
                    dirty_evictions++;
                }
                stall_cycles = 0;
                in_miss = false;
            }

            // Count cache hits
            if (mem_operation && !current_stall && !prev_stall && !top_->rootp->rst && !program_finished) {
                cache_hits++;
                total_cache_accesses++;
            }

            prev_stall = current_stall;
            runSimulation(1);

            if (Verilated::gotFinish() || (program_finished && i > 100)){
                break;
            }
        }
    }

    void printMetrics() {
        double hit_rate = 0.0;
        double miss_rate = 0.0;
        double amat = 1.0;

        if (total_cache_accesses > 0) {
            hit_rate = (double)cache_hits / total_cache_accesses * 100.0;
            miss_rate = (double)cache_misses / total_cache_accesses * 100.0;

            // AMAT = t_hit + (miss_rate × t_miss)
            // t_hit = 1 cycle (no stall)
            // t_miss_clean = 5 cycles (ALLOCATE 4 + UPDATE_SRAM 1)
            // t_miss_dirty = 9 cycles (WRITEBACK 4 + ALLOCATE 4 + UPDATE_SRAM 1)

            unsigned long clean_misses = cache_misses - dirty_evictions;
            double clean_miss_penalty = (double)clean_misses / total_cache_accesses * 5.0;
            double dirty_miss_penalty = (double)dirty_evictions / total_cache_accesses * 9.0;

            amat = 1.0 + clean_miss_penalty + dirty_miss_penalty;
        }

        std::cout << "\n=== Cache Performance Metrics ===" << std::endl;
        std::cout << "Total Memory Accesses: " << total_cache_accesses << std::endl;
        std::cout << "Cache Hits:            " << cache_hits << std::endl;
        std::cout << "Cache Misses:          " << cache_misses << std::endl;
        std::cout << "Dirty Evictions:       " << dirty_evictions;
        if (dirty_evictions > 0) {
            std::cout << " (" << (double)dirty_evictions / cache_misses * 100.0 << "% of misses)";
        }
        std::cout << std::endl;
        std::cout << "Hit Rate (HR):         " << std::fixed << std::setprecision(2) << hit_rate << "%" << std::endl;
        std::cout << "Miss Rate (MR):        " << std::fixed << std::setprecision(2) << miss_rate << "%" << std::endl;
        std::cout << "AMAT:                  " << std::fixed << std::setprecision(3) << amat << " cycles" << std::endl;
        std::cout << "================================\n" << std::endl;
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
    setupCacheTest("halfword");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 300);
}


TEST_F(CacheTestbench, TestWordSL)
{
    setupCacheTest("word");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 300);
}


TEST_F(CacheTestbench, TestByteSL)
{
    setupCacheTest("byte");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 214);
}


TEST_F(CacheTestbench, TestHalfwordComplex)
{
    setupCacheTest("halfword_complex");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 211525);
}


TEST_F(CacheTestbench, TestWordComplex)
{
    setupCacheTest("word_complex");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 1987458259); //XOR all
}


TEST_F(CacheTestbench, TestByteComplex)
{
    setupCacheTest("byte_complex");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 1645);
}


TEST_F(CacheTestbench, TestByteSeq)
{
    setupCacheTest("byte_seq");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 760);
}


//cache performance


TEST_F(CacheTestbench, TestHitMissRate)
{
    setupCacheTest("hit_miss_rate");
    initSimulation();
    runSimulationWithMetrics(CYCLES);

    printMetrics();

    EXPECT_EQ(top_->a0, 100);

}


TEST_F(CacheTestbench, TestAMAT)
{
    setupCacheTest("amat_test");
    initSimulation();
    runSimulationWithMetrics(CYCLES);

    printMetrics();

    EXPECT_EQ(top_->a0, 200);

}



TEST_F(CacheTestbench, TestEviction)
{
    setupCacheTest("eviction_test");
    initSimulation();
    runSimulationWithMetrics(CYCLES);

    printMetrics();

    // Expected result: a0 = 42
    EXPECT_EQ(top_->a0, 42);
}


TEST_F(CacheTestbench, TestSimpleHitRate)
{
    setupCacheTest("simple_hit_rate");
    initSimulation();
    runSimulationWithMetrics(CYCLES);

    printMetrics();
    EXPECT_EQ(top_->a0, 45);

}


int main(int argc, char **argv)
{
    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();
    return res;
}