`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2026 07:02:58 PM
// Design Name: 
// Module Name: Controller
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


module Controller(


    input  [5:0] opcode,      // Idents the Instruction
    input  [5:0] funct,       // R type instructions opcode 00 0000
    input  [4:0] rt,          // bltz vs bgez opcode 00 0001
    
    ////////WB//////////////////////////////////////////////////////////////////////////
    output reg       RegWrite,   // writes to register
    ////////EX//////////////////////////////////////////////////////////////////////////
    output reg [1:0] RegDst,     // destination 00=rt 01 =rd 10=$31 (jal)
    output reg       ALUSrc,    // Alu input 0 = register   1 = immediate
    output reg       Shift,     //1= Alu A does sll or srl
    output reg [3:0] ALUControl,  //Alu Operations (choices of what it does Add sub etc) i think
    ////////ID//////////////////////////////////////////////////////////////////////////
    output reg       SignExt,    // 1= sign extend immediate   0= no extend
    ////////MEM//////////////////////////////////////////////////////////////////////////
    output reg       MemRead,     //Read Data   when 1
    output reg       MemWrite,    // Write Data when 1
    output reg [1:0] MemSize,     // size of memory 00= word   01= half word   10=byte
    ////////WB//////////////////////////////////////////////////////////////////////////
    output reg [1:0] MemtoReg,    // Write back =00    01= memory        10= PC+8 (jal)
    ////////I dont know//////////////////////////////////////////////////////////////////////////
    output reg [2:0] Branch,      // 000=none  001=beq  010= bne 011=bgez 100=bgtz  101=blez 110=bltz
    output reg       Jump,        // jump    j or jal
    output reg       JumpReg      // jr  
);
    

endmodule
