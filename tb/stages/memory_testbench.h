#pragma once

// Reuse your existing infrastructure
#include "../Units/clocked_testbench.h" 
#include "Vmemory.h" 

class MemoryTestbench : public ClockedTestbench<Vmemory> {
public:
    void reset(){
        top_->rst = 1;
        top_->mem_write = 0;
        top_->mem_read = 0;
        top_->alu_result = 0;
        top_->write_data = 0;
        top_->type_control = 2; //word
        top_->sign_ext_flag = 0;
        runSimulation(10);
        top_->rst = 0;
        top_->eval();
    }

    //cahce miss takes multiple cycles
    void waitForStall(){
        int timeout = 100;
        while (top_->stall && timeout > 0){
            runSimulation(1);
            timeout--;
        }
        if (timeout == 0){
            std::cout << "cache stuck" << std::endl;
        }
    }

    uint32_t cpuRead(uint32_t addr){
        top_->alu_result = addr;
        top_->mem_read = 1;
        top_->mem_write = 0;
        top_->type_control = 2;
        top_->sign_ext_flag = 0;
       
        runSimulation(1);
        waitForStall();

        uint32_t result = top_->read_data;

        top_->mem_read = 0;
        
        return result;
    }


    void cpuWrite(uint32_t addr, uint32_t data){
        top_->alu_result = addr;
        top_->write_data = data;
        top_->mem_write = 1;
        top_->mem_read = 0;
        top_->type_control = 2 ;
        top_->sign_ext_flag = 0;

        runSimulation(1);
        waitForStall();

        top_->mem_write = 0;
    }

    uint32_t cpuReadByte(uint32_t addr, bool sign_extend = false){
        top_->alu_result = addr;
        top_->mem_read = 1;
        top_->mem_write = 0;
        top_->type_control = 0;
        top_->sign_ext_flag = sign_extend ? 1 : 0;
        
        runSimulation(1);
        waitForStall();
        
        uint32_t result = top_->read_data;
        top_->mem_read = 0;
        
        return result;
    }

    uint32_t cpuReadHalf(uint32_t addr, bool sign_extend = false){
        top_->alu_result = addr;
        top_->mem_read = 1;
        top_->mem_write = 0;
        top_->type_control = 1;
        top_->sign_ext_flag = sign_extend ? 1 : 0;
        
        runSimulation(1);
        waitForStall();
        
        uint32_t result = top_->read_data;
        top_->mem_read = 0 ;
        
        return result;
    }
};