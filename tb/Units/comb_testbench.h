#pragma once

//we coudl create a pure Base testbench in which 'clocked' inherits,
// but found we'd start having to do this->top-> etc ... as true parent not known till compile time
//cleaner just to have seperate bases for async/sync -- comb/clked
#pragma once

#include "verilated.h"
#include "verilated_vcd_c.h"
#include "gtest/gtest.h"
#include <string>

//need if don't compile with doit...
#ifndef MODULE_NAME
#define MODULE_NAME "module"
#endif

template<class Module> 
class CombTestbench : public ::testing::Test{
protected:
    Module* top_;
    VerilatedContext* context_;
    VerilatedVcdC* tfp_;

    void SetUp() override{
        context_ = new VerilatedContext;
        top_ = new Module{context_};
        tfp_ = new VerilatedVcdC;

        Verilated::traceEverOn(true);
        top_->trace(tfp_, 99);
        
        // dynamic VCD naming
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
    // simple tick: No clock, just time increment
    void tick(){
        top_->eval();
        tfp_->dump(context_->time());
        context_->timeInc(1);
    }

    void runSimulation(int cycles = 1){
        for (int i = 0; i < cycles; i++){
            tick(); 
        }
    }
};