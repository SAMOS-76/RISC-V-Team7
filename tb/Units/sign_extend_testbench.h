#pragma once

#include "comb_testbench.h"
#include "Vsign_extend.h"

class SignExtendTestbench : public CombTestbench<Vsign_extend>{
public:

    void setInputs(uint32_t immSrc, uint32_t instr){
        top_->immSrc = immSrc;
        top_->instr = instr;
    }

    uint32_t getOutput(){
        top_->eval();
        return top_->imm_ext;
    }
};