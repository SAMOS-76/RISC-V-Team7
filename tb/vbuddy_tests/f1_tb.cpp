#include <utility>
#include <iostream>
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vdut.h"
#include "../tests/cpu_testbench.h"
#include "vbuddy.cpp"

#define MAX_SIM_CYC 10000000

int main(int argc, char **argv, char **env)
{
  int simcyc;
  int tick;

  std::ignore = system("touch data.hex");
  std::ignore = system("mkdir -p test_out/f1");

  Verilated::commandArgs(argc, argv);
  Vdut *top = new Vdut;
  Verilated::traceEverOn(true);
  VerilatedVcdC *tfp = new VerilatedVcdC;
  top->trace(tfp, 99);
  tfp->open("test_out/f1/waveform.vcd");

  if (vbdOpen() != 1)
    return (-1);
  vbdHeader("RISC-V F1");

  top->clk = 1;
  top->rst = 1;
  top->trigger = 1;

  // Reset for 10 cycles - let rst propgate - full flush
  for (int i = 0; i < 10; i++) {
    for (tick = 0; tick < 2; tick++) {
      top->eval();
      tfp->dump(2 * i + tick);
      top->clk = !top->clk;
    }
  }

  top->rst = 0;
  top->trigger = 0;  // Start with trigger low (CPU paused, waiting for button press)

  //Main sim
  for (simcyc = 10; simcyc < MAX_SIM_CYC; )
  {
    top->trigger = vbdFlag();

    // Only cycle CPU if trigger is high (pressed)
    if (top->trigger) {
      for (tick = 0; tick < 2; tick++){
        top->eval();
        tfp->dump(2 * simcyc + tick);
        top->clk = !top->clk;
      }
      simcyc++;
    }

    vbdBar(top->a0 & 0xFF);
    vbdCycle(simcyc);

    // debugging
    static int last_a0 = -1;
    if (top->a0 != last_a0) {
        std::cout << "Cycle " << simcyc << ": a0 = " << (int)top->a0 << std::endl;
        last_a0 = top->a0;
    }

    if ((Verilated::gotFinish()) || (vbdGetkey() == 'q'))
      break;
  }

  vbdClose();
  tfp->close();

  std::ignore = system("rm -f program.hex data.hex");
  exit(0);
}