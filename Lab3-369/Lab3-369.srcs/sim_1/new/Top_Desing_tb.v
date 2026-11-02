`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// Sean Maloney 50%
// Aidan Walker 50%
// 
// Create Date: 11/01/2026 10:21:40 PM
// Design Name: 
// Module Name: Top_Desing_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Top Design Testbench
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Top_tb();
 
    parameter NUM_CYCLES = 400;     // increase for longer test programs
 
    reg         Clk;
    reg         Reset;
    wire [31:0] PC_out;
    wire [31:0] WriteData_out;
 
    // PC delayed to line up with the WB stage
    reg [31:0] pc_d1, pc_d2, pc_d3, pc_wb;
 
    integer cycle;
 
    Top uut (
        .Clk(Clk),
        .Reset(Reset),
        .PC_out(PC_out),
        .WriteData_out(WriteData_out)
    );
 
    // 10 ns clock
    initial Clk = 1'b0;
    always #5 Clk = ~Clk;
 
    // Delay line for the PC (sampled at the posedge, before DUT registers update)
    always @(posedge Clk) begin
        pc_d1 <= PC_out;
        pc_d2 <= pc_d1;
        pc_d3 <= pc_d2;
        pc_wb <= pc_d3;
    end
 
    // Reset: high through two clock edges, released on a falling edge
    initial begin
        Reset = 1'b1;
        pc_d1 = 0; pc_d2 = 0; pc_d3 = 0; pc_wb = 0;
        cycle = 0;
        @(negedge Clk);
        @(negedge Clk);
        @(negedge Clk);
        Reset = 1'b0;
    end
 
    // Print once per cycle at the falling edge (values are stable mid-cycle)
    always @(negedge Clk) begin
        if (!Reset) begin
            cycle = cycle + 1;
            $display("cycle %0d | fetch PC = %0d | WB: PC = %0d, write data = %0d (hex %h)",
                     cycle, PC_out, pc_wb, $signed(WriteData_out), WriteData_out);
            if (cycle >= NUM_CYCLES) begin
                $display("Reached %0d cycles, stopping.", NUM_CYCLES);
                $finish;
            end
        end
    end
 
endmodule
