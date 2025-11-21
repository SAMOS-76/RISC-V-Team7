#pragma once

#include "verilated.h"
#include "verilated_vcd_c.h"
#include "gtest/gtest.h"
#include <string>

//need if don;t use script to compile
#ifndef MODULE_NAME
#define MODULE_NAME "module"
#endif

template<class Module> 
class ClockedTestbench : public ::testing::Test{
protected:
    Module* top_;
    VerilatedContext* context_;
    VerilatedVcdC* tfp_;

    void SetUp() override {
        context_ = new VerilatedContext;
        top_ = new Module{context_};
        tfp_ = new VerilatedVcdC;

        Verilated::traceEverOn(true);
        top_->trace(tfp_, 99);
        
        // Dynamic VCD naming
        //can debug actual tests with names
        const testing::TestInfo* const test_info = 
            testing::UnitTest::GetInstance()->current_test_info();
        std::string test_name = test_info->name();
        std::string vcd_name = "waveform_" + std::string(MODULE_NAME) + "_" + test_name + ".vcd";
        
        tfp_->open(vcd_name.c_str());
    }

    void TearDown() override{
        top_->final();
        tfp_->close();
        delete top_;
        delete tfp_;
        delete context_;
    }

public:
    // CLOCKED TICK: Toggles clk low-high
    // timeinc use for GTK wave incrementing in time ofc.
    void tick() {
        // Falling Edge
        top_->clk = 0;
        top_->eval();
        tfp_->dump(context_->time());
        context_->timeInc(1);

        // Rising Edge
        top_->clk = 1;
        top_->eval();
        tfp_->dump(context_->time());
        context_->timeInc(1);
    }
};