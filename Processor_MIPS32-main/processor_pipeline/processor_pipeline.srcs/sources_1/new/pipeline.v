`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Design Name: 
// Module Name: pipeline
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
// 5-Stage Pipelined Processor in Verilog
// Stages: IF, ID, EX, MEM, WB
//===========================================================

module pipeline(clk1, clk2);
    input clk1, clk2;

    // ---------------- Pipeline Registers ----------------
    reg [31:0] PC, IF_ID_IR, IF_ID_NPC;
    reg [31:0] ID_EX_IR, ID_EX_NPC, ID_EX_A, ID_EX_B, ID_EX_Imm;
    reg [31:0] EX_MEM_IR, EX_MEM_ALUOut, EX_MEM_B;
    reg [31:0] MEM_WB_IR, MEM_WB_ALUOut, MEM_WB_LMD;

    // ---------------- Supporting Registers ----------------
    reg [31:0] Reg [0:31];   // Register File
    reg [31:0] Mem [0:1023]; // Memory
    reg [2:0]  ID_EX_type, EX_MEM_type, MEM_WB_type;

    reg HALTED, TAKEN_BRANCH;

    // ---------------- Instruction Opcodes ----------------
    parameter ADD   = 6'b000000, SUB   = 6'b000001, AND  = 6'b000010,
              OR    = 6'b000011, SLT   = 6'b000100, MUL  = 6'b000101,
              ADDI  = 6'b000110, SUBI  = 6'b000111, SLTI = 6'b001000,
              LW    = 6'b001001, SW    = 6'b001010,
              BNEQZ = 6'b001011, BEQZ = 6'b001100,
              HLT   = 6'b111111;

    // ---------------- Instruction Types ----------------
    parameter RR_ALU = 3'b000, RM_ALU = 3'b001, LOAD = 3'b010,
              STORE  = 3'b011, BRANCH = 3'b100, HALT = 3'b101;

    //===========================================================
    // IF Stage
    //===========================================================
    always @(posedge clk1)
        if (HALTED == 0) begin
            if ((EX_MEM_type == BRANCH) && (TAKEN_BRANCH == 1)) begin
                IF_ID_IR  <= #2 Mem[EX_MEM_ALUOut]; 
                IF_ID_NPC <= #2 EX_MEM_ALUOut + 1;
                PC        <= #2 EX_MEM_ALUOut + 1;
                TAKEN_BRANCH <= 0;
            end
            else begin
                IF_ID_IR  <= #2 Mem[PC];
                IF_ID_NPC <= #2 PC + 1;
                PC        <= #2 PC + 1;
            end
        end

    //===========================================================
    // ID Stage
    //===========================================================
    always @(posedge clk2)
        if (HALTED == 0) begin
            // Read "rs"
            if (IF_ID_IR[25:21] == 5'b00000) 
                ID_EX_A <= 0;
            else 
                ID_EX_A <= #2 Reg[IF_ID_IR[25:21]];   // rs

            // Read "rt"
            if (IF_ID_IR[20:16] == 5'b00000) 
                ID_EX_B <= 0;
            else 
                ID_EX_B <= #2 Reg[IF_ID_IR[20:16]];   // rt

            ID_EX_NPC  <= #2 IF_ID_NPC;
            ID_EX_IR   <= #2 IF_ID_IR;
            ID_EX_Imm  <= #2 {{16{IF_ID_IR[15]}}, IF_ID_IR[15:0]}; // sign-extension

            // Decode instruction type
            case (IF_ID_IR[31:26])
                ADD, SUB, AND, OR, SLT, MUL:  ID_EX_type <= #2 RR_ALU;
                ADDI, SUBI, SLTI:             ID_EX_type <= #2 RM_ALU;
                LW:                            ID_EX_type <= #2 LOAD;
                SW:                            ID_EX_type <= #2 STORE;
                BNEQZ, BEQZ:                   ID_EX_type <= #2 BRANCH;
                HLT:                           ID_EX_type <= #2 HALT;
                default:                       ID_EX_type <= #2 HALT; // invalid
            endcase
        end

    //===========================================================
    // EX Stage
    //===========================================================
    always @(posedge clk1)
        if (HALTED == 0) begin
            EX_MEM_type <= ID_EX_type;
            EX_MEM_IR   <= ID_EX_IR;

            case (ID_EX_type)
                RR_ALU: begin
                    case (ID_EX_IR[31:26])
                        ADD:  EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_B;
                        SUB:  EX_MEM_ALUOut <= #2 ID_EX_A - ID_EX_B;
                        AND:  EX_MEM_ALUOut <= #2 ID_EX_A & ID_EX_B;
                        OR:   EX_MEM_ALUOut <= #2 ID_EX_A | ID_EX_B;
                        SLT:  EX_MEM_ALUOut <= #2 (ID_EX_A < ID_EX_B);
                        MUL:  EX_MEM_ALUOut <= #2 ID_EX_A * ID_EX_B;
                        default: EX_MEM_ALUOut <= 0;
                    endcase
                end

                RM_ALU: begin
                    case (ID_EX_IR[31:26])
                        ADDI: EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_Imm;
                        SUBI: EX_MEM_ALUOut <= #2 ID_EX_A - ID_EX_Imm;
                        SLTI: EX_MEM_ALUOut <= #2 (ID_EX_A < ID_EX_Imm);
                        default: EX_MEM_ALUOut <= 0;
                    endcase
                end

                LOAD, STORE: begin
                    EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_Imm;
                    EX_MEM_B      <= #2 ID_EX_B;
                end

                BRANCH: begin
                    if ((ID_EX_IR[31:26] == BEQZ) && (ID_EX_A == 0))
                        TAKEN_BRANCH <= 1;
                    else if ((ID_EX_IR[31:26] == BNEQZ) && (ID_EX_A != 0))
                        TAKEN_BRANCH <= 1;
                    else
                        TAKEN_BRANCH <= 0;

                    if (TAKEN_BRANCH)
                        EX_MEM_ALUOut <= #2 ID_EX_NPC + ID_EX_Imm;
                end
            endcase
        end

    //===========================================================
    // MEM Stage
    //===========================================================
   
// Initialization at start (processor module ke andar)
initial begin
    MEM_WB_LMD = 32'b0;
    MEM_WB_ALUOut = 32'b0;
    MEM_WB_IR = 32'b0;
end

// MEM stage
always @(posedge clk2)
    if (HALTED == 0) begin
        MEM_WB_type <= EX_MEM_type;
        MEM_WB_IR   <= #2 EX_MEM_IR;

        case (EX_MEM_type)
            RR_ALU, RM_ALU:
                MEM_WB_ALUOut <= #2 EX_MEM_ALUOut;

            LOAD:
                MEM_WB_LMD <= #2 Mem[EX_MEM_ALUOut];

            STORE:
                if (TAKEN_BRANCH == 0)
                    Mem[EX_MEM_ALUOut] <= #2 EX_MEM_B;

            default: begin
                MEM_WB_LMD    <= MEM_WB_LMD;     // hold previous value
                MEM_WB_ALUOut <= MEM_WB_ALUOut; // hold previous value
            end
        endcase
    end

    //===========================================================
    // WB Stage
    //===========================================================
    always @(posedge clk1) begin
        if (TAKEN_BRANCH == 0) begin // disable write if branch taken
            case (MEM_WB_type)
                RR_ALU:
                    Reg[MEM_WB_IR[15:11]] <= #2 MEM_WB_ALUOut; // "rd"

                RM_ALU:
                    Reg[MEM_WB_IR[20:16]] <= #2 MEM_WB_ALUOut; // "rt"

                LOAD:
                    Reg[MEM_WB_IR[20:16]] <= #2 MEM_WB_LMD;    // "rt"

                HALT:
                    HALTED <= #2 1'b1;
            endcase
        end
    end
endmodule

