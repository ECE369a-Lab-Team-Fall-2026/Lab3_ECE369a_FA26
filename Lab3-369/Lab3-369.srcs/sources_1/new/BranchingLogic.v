`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// Aidan Walker 50%
// Sean Maloney 50%
// Decides whether a branch is taken. Lives in the MEM stage.
// Branch codes match Controller.v:
// 000 none, 001 beq, 010 bne, 011 bgez, 100 bgtz, 101 blez, 110 bltz

////////////////////////////////////////////////////////////////////////////////

module BranchingLogic(Branch, Zero, Sign, BranchTaken);

   input [2:0] Branch;
    input Zero;
    input Sign;
    output reg BranchTaken;
    always @(*) begin
        case (Branch)
            3'b001:  BranchTaken = Zero;            // beq
            3'b010:  BranchTaken = ~Zero;           // bne
            3'b011:  BranchTaken = ~Sign;           // bgez
            3'b100:  BranchTaken = ~Sign & ~Zero;   // bgtz
            3'b101:  BranchTaken = Sign | Zero;     // blez
            3'b110:  BranchTaken = Sign;            // bltz
            default: BranchTaken = 1'b0;
        endcase
    end
endmodule
