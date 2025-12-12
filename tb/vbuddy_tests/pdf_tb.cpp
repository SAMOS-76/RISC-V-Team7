// The sim  detects "Build" phase ends by checking a0 chnages from its idle state.
// the plotting rate is downsampled to match latency of display loop, so x-axis can scale
// The rotary switch controls a pause/resume state of pipeline, and updates the display header

#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vdut.h"
#include "vbuddy.cpp"     

#define MAX_SIM_CYC 10000000
#define PLOT_SAMPLE_RATE 5 

int main(int argc, char **argv, char **env) {
    int simcyc = 0;
    int tick;

    Verilated::commandArgs(argc, argv);
    Vdut *top = new Vdut;

    Verilated::traceEverOn(true);
    VerilatedVcdC *tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("pdf.vcd");

    if (vbdOpen() != 1) return (-1);

    vbdHeader("PDF: Building");
    vbdSetMode(0);

    top->clk = 0;
    top->rst = 0;
    top->trigger = 1;

    top->rst = 1;
    for (int i = 0; i < 2; i++){
        for (tick = 0; tick < 2; tick++){
            tfp->dump(2 * simcyc + tick);
            top->clk = !top->clk;
            top->eval();
        }
        simcyc++;
    }
    top->rst = 0;

    //let it stabalize more
    for (int i = 0; i < 10; i++){
        top->trigger = 1;  // keep trigger high during initialization
        for (tick = 0; tick < 2; tick++){
            tfp->dump(2 * simcyc + tick);
            top->clk = !top->clk;
            top->eval();
        }
        simcyc++;
    }

    // plot trigger statuses
    int idle_a0 = top->a0;
    bool plot_trigger = false;
    int sample_idx = 0;
    bool prev_paused_state = false;

    for (; simcyc < MAX_SIM_CYC; ){
        if (plot_trigger){
            top->trigger = vbdFlag();
        } else {
            top->trigger = 1;
        }

        bool is_paused = plot_trigger && !top->trigger;

        //only cycle CPU if not paused
        if (!is_paused) {
            for (tick = 0; tick < 2;  tick++){
                tfp->dump(2 * simcyc + tick);
                top->clk  = !top->clk;
                top->eval();
            }
            simcyc++;
        }

        // detect if pdf is ready
        if (!plot_trigger && top->a0 != idle_a0) {
            plot_trigger = true;
            vbdHeader("PDF: Running");
        }

        if (plot_trigger){
            if (is_paused != prev_paused_state){
                if (is_paused) {
                    vbdHeader("CPU & Plot Paused");
                } else {
                    vbdHeader("PDF: Running");
                    sample_idx = 0; //reset sampling when resuming !!!
                }
                prev_paused_state = is_paused;
            }

            if (!is_paused){
                sample_idx++;
                if (sample_idx %  PLOT_SAMPLE_RATE == 0){
                    vbdPlot(top->a0, 0, 255);
                    vbdCycle(simcyc);
                }
            }
        }
        else {
            if (simcyc % 10000 == 0) vbdCycle(simcyc);
        }

        if ((Verilated::gotFinish()) || (vbdGetkey() == 'x')) 
            break;
    }

    vbdClose();
    tfp->close();
    exit(0);
}