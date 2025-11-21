#pragma once

// 1: Select your Base Class
// Option A: For Sequential Logic (CPU, RegFile, Cache, Control)
//           'tick()' function toggles the clock.
#include "clocked_testbench.h" 


// Option B: For Combinatorial Logic (ALU, Mux, SignExtend)
//           'tick()' that simply increments time (no clock).
// #include "comb_testbench.h" 

// STEP 2: Include your Verilated Model
//#include "V[YOUR_MODULE_NAME].h" 

//define the Class
//inherit from ClockedTestbench or CombTestbench depending on step 1.
class [YOUR_MODULE_NAME]Testbench : public ClockedTestbench<V[YOUR_MODULE_NAME]>{
public:
    // 4: Add Helper Functions

    // example - -set an opcode
    void setOpcode(uint32_t op){
        top_->opcode = op; 
    }

    // Eexmaple -read an output
    ///always call eval() before reading to ensure logic is updated.
    uint32_t getResult(){
        top_->eval();
        return top_->result;
    }

    //(Input + Clock)
    // Since we inherited from ClockedTestbench, 'tick()' toggles the clock.
    void writeToMemory(uint32_t addr, uint32_t data){
        top_->addr = addr;
        top_->data_in = data;
        top_->we = 1;
        
        tick(); // Clock edge
        
        top_->we = 0;
    }
};