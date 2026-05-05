`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Design Name: 
// Module Name: test_processor
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


//===========================================================
// Testbench for Pipelined Processor
//===========================================================

module test_processor;
    reg clk1, clk2;
    integer k;

    // DUT (Device Under Test)
    pipeline mips (clk1, clk2);

    // ---------------- CLOCK GENERATION ----------------
    initial begin
        clk1 = 0; clk2 = 0;                 // two-phase clock
        repeat (50) begin
            #5 clk1 = 1; #5 clk1 = 0;
            #5 clk2 = 1; #5 clk2 = 0;
        end
    end

    // ---------------- PROGRAM & INITIALIZATION ----------------
    initial begin
    for (k = 0; k < 1024; k = k + 1)
        mips.Mem[k] = 32'b0;
    for (k = 0; k < 32; k = k + 1)
        mips.Reg[k] = 32'b0;
end

    initial begin
        // initialize registers
        for (k = 0; k < 31; k = k + 1) begin
            mips.Reg[k] = k;
        end

        // load program in memory
        mips.Mem[0]  = 32'h280a00c8;  // ADDI R10,R0,200
        mips.Mem[1]  = 32'h28020001;  // ADDI R2,R0,1
        mips.Mem[2]  = 32'h0e94a000;  // OR R20,R20,R20 -- dummy
        mips.Mem[3]  = 32'h21430000;  // LW R3,0(R10)
        mips.Mem[4]  = 32'h0e94a000;  // OR R20,R20,R20 -- dummy
        mips.Mem[5]  = 32'h14431000;  // Loop: MUL R2,R2,R3
        mips.Mem[6]  = 32'h2c630001;  // SUBI R3,R3,1
        mips.Mem[7]  = 32'h0e94a000;  // OR R20,R20,R20 -- dummy
        mips.Mem[8]  = 32'h3460fffc;  // BNEQZ R3,Loop (offset -4)
        mips.Mem[9]  = 32'h2542fffe;  // SW R2,-2(R10)
        mips.Mem[10] = 32'hfc000000;  // HLT

        // data memory initialization
        mips.Mem[200] = 7;            // factorial of 7

        // init control signals
        mips.PC = 0;
        mips.HALTED = 0;
        mips.TAKEN_BRANCH = 0;

        // run for some time then show result
        #2000 $display ("Mem[200] = %2d, Mem[198] = %6d", 
                        mips.Mem[200], mips.Mem[198]);
    end

    // ---------------- WAVEFORM DUMP ----------------
    initial begin
        $dumpfile ("mips_pipeline.vcd");
        $dumpvars (0, test_processor);

        // dump pipeline registers for waveform
        $dumpvars (1, mips.IF_ID_IR, mips.IF_ID_NPC);
        $dumpvars (1, mips.ID_EX_IR, mips.ID_EX_NPC, mips.ID_EX_A, mips.ID_EX_B, mips.ID_EX_Imm);
        $dumpvars (1, mips.EX_MEM_IR, mips.EX_MEM_ALUOut, mips.EX_MEM_B);
        $dumpvars (1, mips.MEM_WB_IR, mips.MEM_WB_ALUOut, mips.MEM_WB_LMD);
    end
    
    initial begin
    $dumpfile("mips.vcd");
    $dumpvars(0, test_processor);   // sab signals dump

    // Specific pipeline signals dump
    $dumpvars(1, mips.IF_ID_IR, mips.ID_EX_IR, mips.EX_MEM_IR, mips.MEM_WB_IR);
    $dumpvars(1, mips.ID_EX_A, mips.ID_EX_B, mips.EX_MEM_ALUOut, mips.MEM_WB_ALUOut);
    $dumpvars(1, mips.Reg[2], mips.Reg[3], mips.Mem[200], mips.Mem[198]);
end


    // ---------------- MONITOR PIPELINE FLOW ----------------
    initial begin
        $monitor ($time,
                  " | PC=%d | IF/ID_IR=%h | ID/EX_IR=%h | EX/MEM_IR=%h | MEM/WB_IR=%h | R2=%d",
                  mips.PC,
                  mips.IF_ID_IR,
                  mips.ID_EX_IR,
                  mips.EX_MEM_IR,
                  mips.MEM_WB_IR,
                  mips.Reg[2]);
        #3000 $finish;
    end
endmodule

