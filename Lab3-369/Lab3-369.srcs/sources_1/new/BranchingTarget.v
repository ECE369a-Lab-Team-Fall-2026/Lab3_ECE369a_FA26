`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// Aidan Walker 50%
// Sean Maloney 50%
// Branch target = (PC+4) + (sign-extended immediate << 2). Lives in the EX stage.
// Controller must set SignExt = 1 for branches so the offset is sign-extended.
////////////////////////////////////////////////////////////////////////////////


module BranchingTarget(PCPlus4, SignExtImm, Target);

    input [31:0] PCPlus4;
    input [31:0] SignExtImm;
    output [31:0] Target;
    
    
    assign Target = PCPlus4 + (SignExtImm << 2);

endmodule
