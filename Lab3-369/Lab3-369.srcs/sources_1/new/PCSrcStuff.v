`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// Aidan Walker 50%
// Sean Maloney 50%
// Chooses the next PC. Select codes for Mux32Bit4To1:
// 00 = PC+4, 01 = branch target (from MEM), 10 = jump target (from ID), 11 = jr (rs value from ID)
// A taken branch is older than a jump in ID, so it wins.

////////////////////////////////////////////////////////////////////////////////


module PCSrcStuff(BranchTaken, Jump, JumpReg, PCSrc);
    input BranchTaken, Jump, JumpReg;
    
    output reg [1:0] PCSrc;
    
    always @(*) begin
        if (BranchTaken)  
            PCSrc = 2'b01;
        else if (JumpReg) 
            PCSrc = 2'b11;
        else if (Jump)    
            PCSrc = 2'b10;
        else              
            PCSrc = 2'b00;
    end

endmodule
