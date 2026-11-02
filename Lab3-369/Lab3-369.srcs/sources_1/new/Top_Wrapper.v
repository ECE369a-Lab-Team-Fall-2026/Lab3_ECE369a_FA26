`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// Module - Top_Wrapper.v
// Description - Board wrapper for the pipelined datapath (Nexys A7 / Nexys 4 DDR).
//   - Divides the 100 MHz clock down to ~1 Hz for the CPU (ClkDiv).
//   - Resets the CPU from BTND. The reset is stretched so the pipeline registers
//     (synchronous reset) see at least 2 CPU clock edges with Reset high.
//   - Shows, in hex on the 8 seven-segment digits:
//         left  4 digits (AN7..AN4) = PC[15:0]
//         right 4 digits (AN3..AN0) = register-file write data[15:0]
//
//   Port names match the pin assignments in Nexyx7DDR_MASTER.xdc:
//   CLK100MHZ, BTND, CA..CG, DP, AN[7:0].
//
//   Use this as the top module for the board only. For post-implementation
//   SIMULATION of the datapath, set Top as the top module so the full 32-bit PC
//   and write data are kept (here the upper 16 bits are unused and get trimmed).
////////////////////////////////////////////////////////////////////////////////
module Top_Wrapper(CLK100MHZ, BTND, CA, CB, CC, CD, CE, CF, CG, DP, AN);

    parameter DIV_VAL  = 50000000;  // ~1 Hz CPU clock; use 5000000 for ~10 Hz
    parameter ALIGN_PC = 1;         // 1 = show PC of the instruction in WB

    input        CLK100MHZ;
    input        BTND;              // reset (active high)
    output       CA, CB, CC, CD, CE, CF, CG, DP;
    output [7:0] AN;

    //--------------------------------------------------------------------------
    // Slow CPU clock
    //--------------------------------------------------------------------------
    wire ClkSlow;
    ClkDiv #(.DivVal(DIV_VAL)) clkdiv (
        .Clk(CLK100MHZ), .Rst(BTND), .ClkOut(ClkSlow)
    );

    //--------------------------------------------------------------------------
    // Reset stretcher: set instantly by the button (also at power-up), released
    // two slow-clock edges after the button is let go.
    //--------------------------------------------------------------------------
    reg [1:0] rst_sr = 2'b11;
    always @(posedge ClkSlow or posedge BTND) begin
        if (BTND) rst_sr <= 2'b11;
        else      rst_sr <= {rst_sr[0], 1'b0};
    end
    wire Reset = |rst_sr;

    //--------------------------------------------------------------------------
    // Datapath
    //--------------------------------------------------------------------------
    wire [31:0] PC, WD;
    Top cpu (
        .Clk(ClkSlow), .Reset(Reset),
        .PC_out(PC), .WriteData_out(WD)
    );

    // PC of the instruction currently in WB = PC delayed by 4 CPU cycles
    reg [31:0] pc_d1 = 32'b0, pc_d2 = 32'b0, pc_d3 = 32'b0, pc_wb = 32'b0;
    always @(posedge ClkSlow) begin
        pc_d1 <= PC;
        pc_d2 <= pc_d1;
        pc_d3 <= pc_d2;
        pc_wb <= pc_d3;
    end
    wire [31:0] pc_show = ALIGN_PC ? pc_wb : PC;

    //--------------------------------------------------------------------------
    // Display (runs on the 100 MHz clock; has its own refresh counter)
    //--------------------------------------------------------------------------
    wire [6:0] seg;   // seg[6]=a ... seg[0]=g, active low
    Two4DigitDisplay disp (
        .Clk(CLK100MHZ),
        .NumberA(WD[15:0]),        // right four digits
        .NumberB(pc_show[15:0]),   // left four digits
        .out7(seg),
        .en_out(AN)
    );

    assign {CA, CB, CC, CD, CE, CF, CG} = seg;
    assign DP = 1'b1;              // decimal point off (active low)

endmodule
