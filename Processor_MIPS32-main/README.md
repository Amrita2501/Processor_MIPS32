# Processor_MIPS32
This project implements a subset of the MIPS32 Instruction Set Architecture (ISA) using Verilog HDL with a classic 5-stage pipeline (IF → ID → EX → MEM → WB).

This architecture only covers the key instructions and datapath components needed to show pipelined execution, rather than covering the whole MIPS32 specification. 
The objective is to teach students by demonstrating the fundamentals of computer programming, such as the execution pipeline, data processing, and the interplay between memory and registers.

# VeriMIPS 
**A Verilog HDL 5-stage pipelined MIPS processor**

A MIPS-like processor with a fully functional instruction pipeline is implemented in this project. By overlapping several
instructions throughout the five traditional pipeline stages, it mimics instruction-level parallelism. A factorial program that computes n!
and saves the result to memory is used to validate the design. 

This project demonstrates instruction-level parallelism using the classical pipeline stages:
- **IF** – Instruction Fetch  
- **ID** – Instruction Decode & Register Fetch  
- **EX** – Execute / ALU operations  
- **MEM** – Memory Access  
- **WB** – Write Back

## Pipeline Architecture:-

| Stage | Name | Description |
|-------|------|-------------|
|  IF  | Instruction Fetch | Fetch the next instruction from memory |
|  ID  | Instruction Decode | Decode the instruction & read registers |
|  EX  | Execute | Perform ALU operations |
|  MEM | Memory Access | Load/Store from memory |
|  WB  | Write Back | Write result into register file |


## Main Points:-

- 5-stage pipelined architecture (IF → ID → EX → MEM → WB)
- Supports arithmetic, logical, memory & branch instructions
- Factorial computation demo (n!)
- Testbench included with waveform generation (.vcd)
- Clean modular design → easy to extend (e.g. hazards, jumps, forwarding)

##  Features
- 32-bit instruction and data memory.  
- 32 general purpose registers.  
- Implements instructions:  
  - **Arithmetic**: ADD, SUB, MUL, SLT  
  - **Immediate**: ADDI, SUBI, SLTI  
  - **Logical**: AND, OR  
  - **Memory**: LW, SW  
  - **Branch**: BEQZ, BNEQZ  
  - **HALT** instruction for program termination.  
- Factorial program as test case (computes `n!` stored back into memory).

##  Why This Subset?

 The goal is to make things clear instead of complicated.  This project assists students  by breaking MIPS32 down into its most basic parts:

- Get to know the basic ideas of pipelining.

- Use waveforms to see instruction overlap in real time

- Add hazard detection, forwarding, and more ISA support to the design later.

## Future Work

-Implement hazard detection & forwarding.

-Add support for jump instructions.

-Extend instruction set for more complex programs.
