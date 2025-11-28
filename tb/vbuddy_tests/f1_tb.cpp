#include <utility>
#include <csignal>
#include <iostream>
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vdut.h"
#include "../tests/cpu_testbench.h"
#include "vbuddy.cpp"

#define MAX_SIM_CYC 10000

int main(int argc, char **argv, char **env)
{
  int simcyc; 
  int tick; 

  // From cpu_testbench
  std::ignore = system("touch data.hex");

  // Top level and wavefor generation
  Verilated::commandArgs(argc, argv);
  Vdut *top = new Vdut;
  Verilated::traceEverOn(true);
  VerilatedVcdC *tfp = new VerilatedVcdC;
  top->trace(tfp, 99);
  tfp->open("test_out/f1/waveform.vcd");

  // initialise board
  if (vbdOpen() != 1)
    return (-1);
  vbdHeader("RISC-V F1");

  top->clk = 0;
  top->rst = 0;
  /// Can we involve trigger ??? 

  // Runs the simulation for a clock cycle, evaluates the DUT, dumps waveform.
  for (simcyc = 0; simcyc < MAX_SIM_CYC; simcyc++)
  {
    for (tick = 0; tick < 2; tick++)
    {
      tfp->dump(2 * simcyc + tick);
      top->clk = !top->clk;
      top->eval();
    }

    vbdBar(top->a0 & 0xFF);
    vbdCycle(simcyc);

    if ((Verilated::gotFinish()) || (vbdGetkey() == 'q'))
      break; 
  }

  vbdClose(); 
  tfp->close();

  std::ignore = system("rm -f program.hex data.hex");
  exit(0);
}