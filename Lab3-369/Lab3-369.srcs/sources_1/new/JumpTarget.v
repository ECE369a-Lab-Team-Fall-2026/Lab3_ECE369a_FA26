`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// Aidan Walker 50%
// Sean Maloney 50%

////////////////////////////////////////////////////////////////////////////////


module JumpTarget(PCPlus4, Instr26, Target);
    input  [31:0] PCPlus4;
    input  [25:0] Instr26;
    
    output [31:0] Target;
    
    assign Target = {PCPlus4[31:28], Instr26, 2'b00};
endmodule
