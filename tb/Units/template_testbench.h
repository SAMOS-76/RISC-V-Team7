#pragma once

// 1: Select your Base Class
// Option A: For Sequential Logic (CPU, RegFile, Cache, Control)
//           Inherits 'tick()' (clock toggle) and 'runSimulation(n)'.
#include "clocked_testbench.h" 

// Option B: For Combinatorial Logic (ALU, Mux, SignExtend)
// #include "comb_testbench.h" 

// 2: Include Verilated Model
// #include "V[YOUR_MODULE_NAME].h" 

// 3: Define the Class
// Inherit from ClockedTestbench or CombTestbench depending on Step 1.
class [YOUR_MODULE_NAME]Testbench : public ClockedTestbench<V[YOUR_MODULE_NAME]>{
public:
    //4: Add Helper Functions
    // Eg: Set an Input
    void setOpcode(uint32_t op){
        top_->opcode = op; 
    }

    // Eg: Read an Output
    // Always call eval() before reading to ensure logic is updated.
    uint32_t getResult(){
        top_->eval();
        return top_->result;
    }

    // Complex Helper (Input + Clock)
    //we use 'runSimulation(1)' (inherited from ClockedTestbench) for precision.
    void writeToMemory(uint32_t addr, uint32_t data){
        top_->addr = addr;
        top_->data_in = data;
        top_->we = 1;
        
        // Run for 1 cycle to latch data
        runSimulation(1); 
        
        top_->we = 0;
    }
};