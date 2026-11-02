`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2026 05:12:13 PM
// Design Name: 
// Module Name: PCAdder
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



module PCAdder(PCResult, PCAddResult);
    input [31:0] PCResult;
    output [31:0] PCAddResult;
    /* Please fill in the implementation here... */
    //Hardwire addition of 4
    assign PCAddResult = PCResult + 4;
endmodule
