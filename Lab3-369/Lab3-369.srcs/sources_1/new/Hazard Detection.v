`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// Sean Maloney 50%
// Aidan Walker 50%
///////////////////////////////////////////////


module Hazard_Detection (
    // ---- What the instruction in ID needs ----
    input        UsesRs,        // 1 = instruction in ID reads rs (from Controller)
    input        UsesRt,        // 1 = instruction in ID reads rt (from Controller)
    input  [4:0] rs,            // rs field of the instruction in ID (instr[25:21])
    input  [4:0] rt,            // rt field of the instruction in ID (instr[20:16])

    // ---- What older instructions will write ----
    input        RegWrite_EX,   // 1 = instruction in EX will write a register
    input  [4:0] WriteReg_EX,   // its destination register (after the RegDst mux)

    input        RegWrite_MEM,  // 1 = instruction in MEM will write a register
    input  [4:0] WriteReg_MEM,  // its destination register

    input        RegWrite_WB,   // 1 = instruction in WB will write a register
    input  [4:0] WriteReg_WB,   // its destination register

    // ---- Stall controls ----
    output       PCWrite,       // 1 = PC may update, 0 = PC holds (to ProgramCounter En)
    output       IFID_Write,    // 1 = IF/ID may update, 0 = IF/ID holds (to IF_ID En)
    output      Stalling         // 1 = zero the control signals going into ID/EX (insert a no-op
);

////////////////////////////////////////////////////////////////////////////////////////

//These lines are essentially logic to find out whether or not information from EX MEM or WB


    wire hEX  = RegWrite_EX  && (WriteReg_EX  != 0) &&
                ((UsesRs && WriteReg_EX  == rs) || (UsesRt && WriteReg_EX  == rt));
                
  // hEX= 1 or 0 whether or not EX will write to register && the register it is writing to is not =0
        //&& Instruction in ID reads rs and Reg address written to ==rs or reads rt
                
    wire hMEM = RegWrite_MEM && (WriteReg_MEM != 0) &&
                ((UsesRs && WriteReg_MEM == rs) || (UsesRt && WriteReg_MEM == rt));
                
  // same thing as above
        // hMEM = 1  if MEM writes to register && the address it writes to does not = 0 
                
    wire hWB  = RegWrite_WB  && (WriteReg_WB  != 0) &&
                ((UsesRs && WriteReg_WB  == rs) || (UsesRt && WriteReg_WB  == rt));
                
////////////////////////////////////////////////////////////////////////////////////////

    wire stall = hEX | hMEM | hWB;
    assign PCWrite    = ~stall;
    assign IFID_Write = ~stall;
    assign Stalling     = stall;
    
    // essentially states if hEX or hMEM or hWB =1 
    //then stall=1
    // if stall =1
        //Then 
        //PcWrite=0
        //IFID_Write=0
        //Bubble=1
  //When Bubble =1 then it will stall
////////////////////////////////////////////////////////////////////////////////////////
endmodule