#pragma once

#include "comb_testbench.h"
#include "Vcontrol_unit.h"

class ControlUnitTestbench : public CombTestbench<Vcontrol_unit>{
public:

    void setInstr(uint32_t instr){
        top_->instr = instr;
    }

    uint32_t makeOpF7F3(uint32_t opcode, uint32_t funct7, uint32_t funct3){
        return  (funct7 << 25) |
                (0      << 20) |   // rs2 = x0
                (0      << 15) |   // rs1 = x0
                (funct3 << 12) |
                (0      << 7 ) |   // rd = x0
                 opcode;
    }

    void setOpF7F3(uint32_t opcode, uint32_t funct7, uint32_t funct3){
        setInstr(makeOpF7F3(opcode, funct7, funct3));
    }

    void setFlags(bool zero, bool result_0){
        top_->alu_zero = zero;
        top_->alu_result_0 = result_0;
    }

    void verify(){
        runSimulation(1);
    }
};
