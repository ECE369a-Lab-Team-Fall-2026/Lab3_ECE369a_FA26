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
// Description: MEM/WB pipeline register.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module MEM_WB #(
    parameter WB_W = 3
)(
    input  Clk, Reset,
 
    input  [WB_W-1:0] WB_in,
    input  [31:0]     ReadData_in,     // data memory output
    input  [31:0]     ALUResult_in,
    input  [4:0]      WriteReg_in,
    input  [31:0]     Link_in,         // PC+8 for jal (MemtoReg = 10)
 
    output reg [WB_W-1:0] WB_out,
    output reg [31:0]     ReadData_out,
    output reg [31:0]     ALUResult_out,
    output reg [4:0]      WriteReg_out,
    output reg [31:0]     Link_out
);
 
    always @(posedge Clk) begin
        if (Reset) begin
            WB_out        <= {WB_W{1'b0}};
            ReadData_out  <= 32'b0;
            ALUResult_out <= 32'b0;
            WriteReg_out  <= 5'b0;
            Link_out      <= 32'b0;
        end else begin
            WB_out        <= WB_in;
            ReadData_out  <= ReadData_in;
            ALUResult_out <= ALUResult_in;
            WriteReg_out  <= WriteReg_in;
            Link_out      <= Link_in;
        end
    end
endmodule