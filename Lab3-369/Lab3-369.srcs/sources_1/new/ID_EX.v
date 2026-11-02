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
// Description: ID/EX pipeline register.
//   WB_in / M_in / EX_in are bundles of the Controller's control signals,
//   grouped as in the datapath figure. Concatenate them in the top level and
//   split them back out with the same order. Set the widths with parameters.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ID_EX #(
    parameter WB_W = 3,    // {RegWrite, MemtoReg[1:0]}
    parameter M_W  = 7,    // {Branch[2:0], MemRead, MemWrite, MemSize[1:0]}
    parameter EX_W = 8     // {RegDst[1:0], ALUSrc, Shift, ALUControl[3:0]}
)(
    input  Clk, Reset,
 
    input  [WB_W-1:0] WB_in,
    input  [M_W-1:0]  M_in,
    input  [EX_W-1:0] EX_in,
    input  [31:0]     PCplus4_in,
    input  [31:0]     ReadData1_in,
    input  [31:0]     ReadData2_in,
    input  [31:0]     Imm_in,        // sign/zero-extended immediate
    input  [4:0]      Rt_in,         // Instruction[20:16]
    input  [4:0]      Rd_in,         // Instruction[15:11]
 
    output reg [WB_W-1:0] WB_out,
    output reg [M_W-1:0]  M_out,
    output reg [EX_W-1:0] EX_out,
    output reg [31:0]     PCplus4_out,
    output reg [31:0]     ReadData1_out,
    output reg [31:0]     ReadData2_out,
    output reg [31:0]     Imm_out,
    output reg [4:0]      Rt_out,
    output reg [4:0]      Rd_out
);
 
    // Imm_out[5:0] is the funct field and Imm_out[10:6] is shamt, so the
    // ALU control and the shift instructions can take them from here.
 
    always @(posedge Clk) begin
        if (Reset) begin
            WB_out        <= {WB_W{1'b0}};
            M_out         <= {M_W{1'b0}};
            EX_out        <= {EX_W{1'b0}};
            PCplus4_out   <= 32'b0;
            ReadData1_out <= 32'b0;
            ReadData2_out <= 32'b0;
            Imm_out       <= 32'b0;
            Rt_out        <= 5'b0;
            Rd_out        <= 5'b0;
        end else begin
            WB_out        <= WB_in;
            M_out         <= M_in;
            EX_out        <= EX_in;
            PCplus4_out   <= PCplus4_in;
            ReadData1_out <= ReadData1_in;
            ReadData2_out <= ReadData2_in;
            Imm_out       <= Imm_in;
            Rt_out        <= Rt_in;
            Rd_out        <= Rd_in;
        end
    end
endmodule
