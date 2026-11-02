`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// Sean Maloney 50%
// Aidan Walker 50%
// Create Date: 11/01/2026 07:51:56 PM
// Design Name: 
// Module Name: ID_EX
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: EX/MEM pipeline register. EX-stage controls have already been
// used, so only the WB and M bundles continue.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module EX_MEM #(
    parameter WB_W = 3,
    parameter M_W  = 7
)(
    input  Clk, Reset,
 
    input  [WB_W-1:0] WB_in,
    input  [M_W-1:0]  M_in,
    input  [31:0]     BranchTarget_in,   // output of the branch adder
    input             Zero_in,
    input  [31:0]     ALUResult_in,
    input  [31:0]     WriteData_in,      // ReadData2 (store data)
    input  [4:0]      WriteReg_in,       // output of the RegDst mux
    input  [31:0]     Link_in,           // PC+8 for jal
 
    output reg [WB_W-1:0] WB_out,
    output reg [M_W-1:0]  M_out,
    output reg [31:0]     BranchTarget_out,
    output reg            Zero_out,
    output reg [31:0]     ALUResult_out,
    output reg [31:0]     WriteData_out,
    output reg [4:0]      WriteReg_out,
    output reg [31:0]     Link_out
);
 
    always @(posedge Clk) begin
        if (Reset) begin
            WB_out           <= {WB_W{1'b0}};
            M_out            <= {M_W{1'b0}};
            BranchTarget_out <= 32'b0;
            Zero_out         <= 1'b0;
            ALUResult_out    <= 32'b0;
            WriteData_out    <= 32'b0;
            WriteReg_out     <= 5'b0;
            Link_out         <= 32'b0;
        end else begin
            WB_out           <= WB_in;
            M_out            <= M_in;
            BranchTarget_out <= BranchTarget_in;
            Zero_out         <= Zero_in;
            ALUResult_out    <= ALUResult_in;
            WriteData_out    <= WriteData_in;
            WriteReg_out     <= WriteReg_in;
            Link_out         <= Link_in;
        end
    end
endmodule