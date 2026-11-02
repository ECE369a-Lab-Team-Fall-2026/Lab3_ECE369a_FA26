`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// Sean Maloney 50%
// Aidan Walker 50%
// 
// Create Date: 11/01/2026 07:51:56 PM
// Design Name: 
// Module Name: ID_EX
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: IF/ID pipeline register. Captures on posedge Clk and always
// drives its outputs from the stored value.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module IF_ID(Clk, Reset, PCplus4_in, Instruction_in, PCplus4_out, Instruction_out);
 
    input         Clk, Reset;
    input  [31:0] PCplus4_in, Instruction_in;
    output reg [31:0] PCplus4_out, Instruction_out;
 
    always @(posedge Clk) begin
        if (Reset) begin
            PCplus4_out     <= 32'b0;
            Instruction_out <= 32'b0;   // all zeros = sll $0,$0,0 = nop
        end else begin
            PCplus4_out     <= PCplus4_in;
            Instruction_out <= Instruction_in;
        end
    end
endmodule