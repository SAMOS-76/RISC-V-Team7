# RISC-V 32IM CPU

## Introduction
We developed two CPUs: A single-cycle processor with a multiplication unit and a pipelined RV32IM cpu with cache. Additional implementations include branch prediction and the inclusion of multiplication in the ALU and a multicycle divison unit.

- `main` contains our fully tested Pipelined RV32IM cpu with cache.
- `SingleCycle` contains the verified single-cycle CPU with multiplication.


## Table of Contents
 - The Team and Commands
   - Links to [personal statements](./personal%20statements/)
   - Starting commands
   
- Single Cycle
  - The instruction set and CPU design
  - Basic explanation of our logic and implementation
  

- Pipelined
  - CPU design
  - Basic explanation of logic and implementation 



## The Team and Commands

| Name   | Personal Statements |
|------------|-----------------|
| Samuel Amos-Osebeyo | |
| Louis Canning ||
| Archie Kendall     ||
| Adil Shah   | | 

| Commands                      | What does it do                                                                                           |
| :---------------------------: | :------------------------------------------------------------------------------------------------------:  |                                
|   ./tb/doit                            |          |                      
|   ./tb/vbuddy_tests/pdf.sh             |          |       
|   ./tb/vbuddy_tests/f1.sh              |          |    

## Single Cycle

### Overview
Single-cycle CPU that can carry out most CPU operations (Say specific instructions)

### Schematic

### Contributions
| Section               | Samuel Amos-Osebeyo | Louis Canning | Archie Kendall | Adil Shah |
|-------------------------|-----------------|---------------|-------------------|-------------|
| **PC**                  |                |              |                   |            |
| **ALU**                 |                 |              |                  |            |
| **Register File**       |                |               |                  |             |
| **Instruction Memory**  |                 |              |                   |             |
| **Control Unit**        |                 |              |                   |            |
| **Sign Extend**         |                |              |                   |            |
| **Data Path**           |                 |              |                  |            |
| **Data Memory**         |                 |               |                  |             |
| **Top Level Assembly**  |                |              |                 |            |
| **Unit Tests**          |                 |               |                   |            |
| **Testbench & debugging**|                |               |                   |            |              
| **F1.s**                |                |               |                   |            |
| **Repo Setup and WriteUp**                  |                |              |                   |            |
---

### Testing

#### Standard Test Cases
<img width="414" height="308" alt="image" src="https://github.com/user-attachments/assets/ae19b3ca-cd87-465d-a798-5379ba36bf8f" />

#### F1


https://github.com/user-attachments/assets/702fc385-e185-4802-9f70-d9fd016ca3c9


https://github.com/user-attachments/assets/0647b38b-375b-400a-8f1c-8b7e6f01f379




https://github.com/user-attachments/assets/7b674cfa-fa40-462f-b8c4-2e32a44cbaa1




https://github.com/user-attachments/assets/c15ab2b2-3b43-46bb-8ceb-d946e681eeeb




https://github.com/user-attachments/assets/b1ecc930-c15e-4e76-9a75-f5d051aa57e9







