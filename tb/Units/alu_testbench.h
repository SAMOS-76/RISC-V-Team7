#pragma once
#include "comb_testbench.h"
#include "Valu.h" 

class AluTestbench : public CombTestbench<Valu>{
public:
    // Helper to run one ALU operation
    void evalALU(uint32_t op, uint32_t a, uint32_t b){
        top_->alu_op = op;
        top_->inA = a;
        top_->inB = b;
        
        //so now we can easily
        //evaluate, dump, and moves time forward by 1 unit.
        runSimulation(1); 
    }
};