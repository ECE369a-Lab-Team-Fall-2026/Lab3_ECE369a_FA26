`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// Sean Maloney 50%
// Aidan Walker 50%
// 
// Create Date: 11/01/2026 09:37:04 PM
// Design Name: 
// Module Name: Top_Design
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 5-stage pipelined MIPS datapath.
// IF : PC, +4, InstructionMemory, next-PC mux
// ID : Controller, RegisterFile, SignExtension, jump resolution (j/jal/jr)
// EX : shift/ALUSrc muxes, ALU, RegDst mux, branch target
// MEM: DataMemory, branch decision (PCSrc)
// WB : write-back mux -> RegisterFile
// Demo outputs: PC_out (32-bit PC) and WriteData_out (32-bit RegFile write data)
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Top(Clk, Reset, PC_out, WriteData_out);
 
    input         Clk, Reset;
    output [31:0] PC_out;
    output [31:0] WriteData_out;
 
    //==========================================================================
    // Wires
    //==========================================================================
    // IF
    wire [31:0] PC, PCplus4_IF, NextPC, Instr_IF;
 
    // ID
    wire [31:0] PCplus4_ID, Instr_ID;
    wire [31:0] ReadData1_ID, ReadData2_ID, Imm_ID;
    wire [31:0] JumpTarget_ID;
    wire [5:0]  opcode = Instr_ID[31:26];
    wire [4:0]  rs     = Instr_ID[25:21];
    wire [4:0]  rt     = Instr_ID[20:16];
    wire [4:0]  rd     = Instr_ID[15:11];
    wire [5:0]  funct  = Instr_ID[5:0];
 
    // Controller outputs (ID)
    wire        RegWrite_ID, ALUSrc_ID, Shift_ID, SignExt_ID;
    wire        MemRead_ID, MemWrite_ID, Jump_ID, JumpReg_ID;
    wire [1:0]  RegDst_ID, MemSize_ID, MemtoReg_ID;
    wire [3:0]  ALUControl_ID;
    wire [2:0]  Branch_ID;
 
    // ID/EX outputs (EX)
    wire [2:0]  WB_EX;
    wire [6:0]  M_EX;
    wire [7:0]  EX_EX;
    wire [31:0] PCplus4_EX, ReadData1_EX, ReadData2_EX, Imm_EX;
    wire [4:0]  Rt_EX, Rd_EX;
    wire [1:0]  RegDst_EX   = EX_EX[7:6];
    wire        ALUSrc_EX   = EX_EX[5];
    wire        Shift_EX    = EX_EX[4];
    wire [3:0]  ALUControl_EX = EX_EX[3:0];
    wire [31:0] ALU_A, ALU_B, ALUResult_EX, BranchTarget_EX, Link_EX;
    wire        Zero_EX;
    wire [4:0]  WriteReg_EX;
 
    // EX/MEM outputs (MEM)
    wire [2:0]  WB_MEM;
    wire [6:0]  M_MEM;
    wire [31:0] BranchTarget_MEM, ALUResult_MEM, StoreData_MEM, Link_MEM;
    wire        Zero_MEM;
    wire [4:0]  WriteReg_MEM;
    wire [2:0]  Branch_MEM   = M_MEM[6:4];
    wire        MemRead_MEM  = M_MEM[3];
    wire        MemWrite_MEM = M_MEM[2];
    wire [1:0]  MemSize_MEM  = M_MEM[1:0];
    wire [31:0] ReadData_MEM;
    wire        BranchTaken;
    wire [1:0]  PCSrc;
 
    // MEM/WB outputs (WB)
    wire [2:0]  WB_WB;
    wire [31:0] ReadData_WB, ALUResult_WB, Link_WB, WriteData_WB;
    wire [4:0]  WriteReg_WB;
    wire        RegWrite_WB  = WB_WB[2];
    wire [1:0]  MemtoReg_WB  = WB_WB[1:0];
 
    //==========================================================================
    // IF stage
    //==========================================================================
    // PCSrc: 00 = PC+4, 01 = branch target (MEM), 10 = jump, 11 = jr
    Bit32_Mux4to1 nextpc_mux (
        .out(NextPC),
        .in0(PCplus4_IF),
        .in1(BranchTarget_MEM),
        .in2(JumpTarget_ID),
        .in3(ReadData1_ID),
        .sel(PCSrc)
    );
 
    ProgramCounter pc_reg (
        .Address(NextPC), .PCResult(PC), .Reset(Reset), .Clk(Clk)
    );
 
    PCAdder pc_adder (.PCResult(PC), .PCAddResult(PCplus4_IF));
 
    InstructionMemory imem (.Address(PC), .Instruction(Instr_IF));
 
    IF_ID if_id (
        .Clk(Clk), .Reset(Reset),
        .PCplus4_in(PCplus4_IF),   .Instruction_in(Instr_IF),
        .PCplus4_out(PCplus4_ID),  .Instruction_out(Instr_ID)
    );
 
    //==========================================================================
    // ID stage
    //==========================================================================
    Controller ctrl (
        .opcode(opcode), .funct(funct), .rt(rt),
        .RegWrite(RegWrite_ID), .RegDst(RegDst_ID), .ALUSrc(ALUSrc_ID),
        .Shift(Shift_ID), .ALUControl(ALUControl_ID), .SignExt(SignExt_ID),
        .MemRead(MemRead_ID), .MemWrite(MemWrite_ID), .MemSize(MemSize_ID),
        .MemtoReg(MemtoReg_ID), .Branch(Branch_ID),
        .Jump(Jump_ID), .JumpReg(JumpReg_ID)
    );
 
    RegisterFile regfile (
        .ReadRegister1(rs), .ReadRegister2(rt),
        .WriteRegister(WriteReg_WB), .WriteData(WriteData_WB),
        .RegWrite(RegWrite_WB), .Clk(Clk),
        .ReadData1(ReadData1_ID), .ReadData2(ReadData2_ID)
    );
 
    SignExtension signext (
        .in(Instr_ID[15:0]), .SignExt(SignExt_ID), .out(Imm_ID)
    );
 
    JumpTarget jump_target (
        .PCPlus4(PCplus4_ID), .Instr26(Instr_ID[25:0]), .Target(JumpTarget_ID)
    );
 
    // BranchTaken comes from MEM (older instruction), Jump/JumpReg from ID
    PCSrcStuff pcsrc_logic (
        .BranchTaken(BranchTaken), .Jump(Jump_ID), .JumpReg(JumpReg_ID),
        .PCSrc(PCSrc)
    );
 
    ID_EX #(.WB_W(3), .M_W(7), .EX_W(8)) id_ex (
        .Clk(Clk), .Reset(Reset),
        .WB_in({RegWrite_ID, MemtoReg_ID}),
        .M_in({Branch_ID, MemRead_ID, MemWrite_ID, MemSize_ID}),
        .EX_in({RegDst_ID, ALUSrc_ID, Shift_ID, ALUControl_ID}),
        .PCplus4_in(PCplus4_ID),
        .ReadData1_in(ReadData1_ID), .ReadData2_in(ReadData2_ID),
        .Imm_in(Imm_ID), .Rt_in(rt), .Rd_in(rd),
        .WB_out(WB_EX), .M_out(M_EX), .EX_out(EX_EX),
        .PCplus4_out(PCplus4_EX),
        .ReadData1_out(ReadData1_EX), .ReadData2_out(ReadData2_EX),
        .Imm_out(Imm_EX), .Rt_out(Rt_EX), .Rd_out(Rd_EX)
    );
 
    //==========================================================================
    // EX stage
    //==========================================================================
    // sll/srl: ALU shifts B by A[4:0], so A = shamt (Imm[10:6]), B = rt value
    Mux32Bit2To1 shift_mux (
        .out(ALU_A), .inA(ReadData1_EX), .inB({27'b0, Imm_EX[10:6]}), .sel(Shift_EX)
    );
 
    Mux32Bit2To1 alusrc_mux (
        .out(ALU_B), .inA(ReadData2_EX), .inB(Imm_EX), .sel(ALUSrc_EX)
    );
 
    ALU32Bit alu (
        .ALUControl(ALUControl_EX), .A(ALU_A), .B(ALU_B),
        .ALUResult(ALUResult_EX), .Zero(Zero_EX)
    );
 
    // RegDst: 00 = rt, 01 = rd, 10 = $31 (jal)
    bit5Mux3in regdst_mux (
        .out(WriteReg_EX), .in0(Rt_EX), .in1(Rd_EX), .in2(5'd31), .sel(RegDst_EX)
    );
 
    BranchingTarget branch_target (
        .PCPlus4(PCplus4_EX), .SignExtImm(Imm_EX), .Target(BranchTarget_EX)
    );
 
    // jal writes PC+8 (one delay-slot instruction follows the jump)
    assign Link_EX = PCplus4_EX + 32'd4;
 
    EX_MEM #(.WB_W(3), .M_W(7)) ex_mem (
        .Clk(Clk), .Reset(Reset),
        .WB_in(WB_EX), .M_in(M_EX),
        .BranchTarget_in(BranchTarget_EX), .Zero_in(Zero_EX),
        .ALUResult_in(ALUResult_EX), .WriteData_in(ReadData2_EX),
        .WriteReg_in(WriteReg_EX), .Link_in(Link_EX),
        .WB_out(WB_MEM), .M_out(M_MEM),
        .BranchTarget_out(BranchTarget_MEM), .Zero_out(Zero_MEM),
        .ALUResult_out(ALUResult_MEM), .WriteData_out(StoreData_MEM),
        .WriteReg_out(WriteReg_MEM), .Link_out(Link_MEM)
    );
 
    //==========================================================================
    // MEM stage
    //==========================================================================
    DataMemory dmem (
        .Address(ALUResult_MEM), .WriteData(StoreData_MEM), .Clk(Clk),
        .MemWrite(MemWrite_MEM), .MemRead(MemRead_MEM), .MemSize(MemSize_MEM),
        .ReadData(ReadData_MEM)
    );
 
    // Sign = ALUResult[31]; branches use PASSA so ALUResult is the rs value
    BranchingLogic branch_logic (
        .Branch(Branch_MEM), .Zero(Zero_MEM), .Sign(ALUResult_MEM[31]),
        .BranchTaken(BranchTaken)
    );
 
    MEM_WB #(.WB_W(3)) mem_wb (
        .Clk(Clk), .Reset(Reset),
        .WB_in(WB_MEM), .ReadData_in(ReadData_MEM),
        .ALUResult_in(ALUResult_MEM), .WriteReg_in(WriteReg_MEM),
        .Link_in(Link_MEM),
        .WB_out(WB_WB), .ReadData_out(ReadData_WB),
        .ALUResult_out(ALUResult_WB), .WriteReg_out(WriteReg_WB),
        .Link_out(Link_WB)
    );
 
    //==========================================================================
    // WB stage: MemtoReg 00 = ALU, 01 = memory, 10 = PC+8 (jal)
    //==========================================================================
    bit32_Mux3to1 wb_mux (
        .out(WriteData_WB),
        .in0(ALUResult_WB), .in1(ReadData_WB), .in2(Link_WB),
        .sel(MemtoReg_WB)
    );
 
    //==========================================================================
    // Demo outputs
    //==========================================================================
    assign PC_out        = PC;
    assign WriteData_out = WriteData_WB;
 
endmodule
