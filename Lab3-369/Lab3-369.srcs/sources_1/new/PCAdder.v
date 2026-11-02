`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// Aidan Walker 50%
// Sean Maloney 50%

////////////////////////////////////////////////////////////////////////////////



module PCAdder(PCResult, PCAddResult);
    input [31:0] PCResult;
    output [31:0] PCAddResult;
    /* Please fill in the implementation here... */
    //Hardwire addition of 4
    assign PCAddResult = PCResult + 4;
endmodule
