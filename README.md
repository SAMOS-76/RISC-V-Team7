# RISC-V CPU Group 7
<img width="2012" height="950" alt="image" src="https://github.com/user-attachments/assets/fe026b38-4e57-4b59-a333-0dfa03161c82" />


| Person   | Task | Progress |
| -------- | ------- | ------- |
| Samuel  | TBC    | ⏳    |
| Archie | TBC     | ⏳     |
| Adil    | TBC    | ⏳    |
| Louis    | TBC    | ⏳    |

## Architecture of RISC-V CPU

To help you progress quickly, here is the top-level block diagram for this CPU. Note the following:

1. This is a single cycle design meaning that on each rising edge of the clock, one instruction is executed.
2. The program memory must be asynchronous - meaning that as soon as the Program Counter (PC) changes, the instruction will appear at the program memory output. You should modify Lab 2 memory block (you may use RAM or ROM here) so that it is asynchronous. You can preload the memory with the machine code program from a file.
3. Only two components here are clocked: the PC Register that maintains the program counter and the Register File. The two READ ports of the register file should also be asychronous and the WRITE port of the Register File must be synchronous.
4. The thick verticle blue bar shows how the 32-bit instructions is split into fields to drive the different modules. It is NOT a component.
5. The entire CPU only has three I/O ports shown in RED: clock signal clk, rst and the contents of the a0 register (directly from the Register File). This allows us to bring this register content to the outside directly.
6. The Sign-extension Unit takes the relevant fields from the instruction and composes the immediate operand depending on the instruction.
7. The Control Unit is not clocked and decodes the instruction to provide control signals to various modules.

## Deliverables
1. A README.md that show evidences of the CPU working properly with the program.
2. A short narrative to state the challenges you encountered as a team.
3. Comments about any design decisions you made that are not obvious.
4. A reflection on what you might do differently if you were to start again.

