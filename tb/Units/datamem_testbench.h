#pragma once

#include "clocked_testbench.h"
#include "Vdatamem.h"

// b = 2'b00, half = 2'b01, word = 2'b10
#define BYTE 0
#define HALF 1
#define WORD 2

class DataMemTestbench : public ClockedTestbench<Vdatamem>{
public:
    void writeMem(uint32_t addr, uint32_t data, int size){
        top_->addr = addr;
        top_->din = data;
        top_->type_control = size;
        top_->write_en = 1;
        
        runSimulation(1);

        top_->write_en = 0;
    }

    uint32_t readMem(uint32_t addr, int size, bool sign_ext) {
        top_->addr = addr;
        top_->type_control = size;
        top_->sign_ext = sign_ext;
        
        top_->eval();
        return top_->dout;
    }
};