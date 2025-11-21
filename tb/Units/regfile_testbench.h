#pragma once

#include "clocked_testbench.h" 
#include "Vregfile.h"

class RegFileTestbench : public ClockedTestbench<Vregfile>{
public:
    
    void runSimulation(int cycles = 1){
        for (int i = 0; i < cycles; i++){
            tick(); 
        }
    }

    void reset(){
        top_->rst = 1;
        runSimulation(5); // Hold reset for 5 cycles
        top_->rst = 0;
        top_->eval();
    }

    void writeReg(uint8_t addr, uint32_t data){
        top_->a3 = addr;
        top_->din = data;
        top_->write_en = 1;
        
        //single tick here for precision
        tick(); 
        
        top_->write_en = 0;
    }

    uint32_t readReg1(uint8_t addr){
        top_->a1 = addr;
        top_->eval();
        return top_->rout1;
    }

    uint32_t readReg2(uint8_t addr){
        top_->a2 = addr;
        top_->eval();
        return top_->rout2;
    }
};