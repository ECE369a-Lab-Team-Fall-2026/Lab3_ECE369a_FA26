`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// Sean Maloney 50%
// Aidan Walker 50%
// Module - ALU32Bit_tb.v
// Description - Test the 'ALU32Bit.v' module.
////////////////////////////////////////////////////////////////////////////////

module ALU32Bit_tb(); 

	reg [3:0] ALUControl;   // control bits for ALU operation
	reg [31:0] A, B;	        // inputs

	wire [31:0] ALUResult;	// answer
	wire Zero;	        // Zero=1 if ALUResult == 0

    ALU32Bit u0(
        .ALUControl(ALUControl), 
        .A(A), 
        .B(B), 
        .ALUResult(ALUResult), 
        .Zero(Zero)
    );

    // ALUControl encoding (must match ALU32Bit.v)
    localparam ALU_AND   = 4'b0000;
    localparam ALU_OR    = 4'b0001;
    localparam ALU_ADD   = 4'b0010;
    localparam ALU_XOR   = 4'b0011;
    localparam ALU_SLL   = 4'b0100;
    localparam ALU_SRL   = 4'b0101;
    localparam ALU_SUB   = 4'b0110;
    localparam ALU_SLT   = 4'b0111;
    localparam ALU_MUL   = 4'b1000;
    localparam ALU_PASSA = 4'b1001;
    localparam ALU_NOR   = 4'b1100;

    integer pass_count = 0;
    integer fail_count = 0;

    // Apply one test and compare both outputs
    task check;
        input [3:0]  ctrl;
        input [31:0] a_in, b_in;
        input [31:0] expected_result;
        input        expected_zero;
        input [127:0] name;   // up to 16 characters
        begin
            ALUControl = ctrl;
            A = a_in;
            B = b_in;
            #10;
            if (ALUResult === expected_result && Zero === expected_zero) begin
                pass_count = pass_count + 1;
                $display("PASS  %-8s A=%h B=%h -> %h  Zero=%b", name, a_in, b_in, ALUResult, Zero);
            end else begin
                fail_count = fail_count + 1;
                $display("FAIL  %-8s A=%h B=%h -> %h (expected %h)  Zero=%b (expected %b)",
                         name, a_in, b_in, ALUResult, expected_result, Zero, expected_zero);
            end
        end
    endtask

	initial begin
	
        // ---------------- ADD (add, addi, lw/sw address calc) ----------------
        check(ALU_ADD, 32'd5,        32'd7,        32'd12,       1'b0, "ADD");
        check(ALU_ADD, 32'hFFFFFFFF, 32'd1,        32'd0,        1'b1, "ADD wrap");

        // ---------------- SUB (sub, beq, bne) ----------------
        check(ALU_SUB, 32'd7,        32'd7,        32'd0,        1'b1, "SUB eq");
        check(ALU_SUB, 32'd5,        32'd7,        32'hFFFFFFFE, 1'b0, "SUB neg");

        // ---------------- AND / OR / XOR / NOR ----------------
        check(ALU_AND, 32'hF0F0F0F0, 32'hFF00FF00, 32'hF000F000, 1'b0, "AND");
        check(ALU_AND, 32'hF0F0F0F0, 32'h0F0F0F0F, 32'h00000000, 1'b1, "AND zero");
        check(ALU_OR,  32'hF0F0F0F0, 32'h0F0F0F0F, 32'hFFFFFFFF, 1'b0, "OR");
        check(ALU_XOR, 32'hFFFF0000, 32'h0000FFFF, 32'hFFFFFFFF, 1'b0, "XOR");
        check(ALU_XOR, 32'hABCD1234, 32'hABCD1234, 32'h00000000, 1'b1, "XOR same");
        check(ALU_NOR, 32'h00000000, 32'h00000000, 32'hFFFFFFFF, 1'b0, "NOR");
        check(ALU_NOR, 32'hF0F0F0F0, 32'h0F0F0F0F, 32'h00000000, 1'b1, "NOR zero");

        // ---------------- SLT (slt, slti) - signed ----------------
        check(ALU_SLT, 32'hFFFFFFFF, 32'd1,        32'd1,        1'b0, "SLT -1<1");
        check(ALU_SLT, 32'd1,        32'hFFFFFFFF, 32'd0,        1'b1, "SLT 1<-1");
        check(ALU_SLT, 32'd5,        32'd5,        32'd0,        1'b1, "SLT equal");
        check(ALU_SLT, 32'd3,        32'd9,        32'd1,        1'b0, "SLT 3<9");

        // ---------------- Shifts (shamt arrives on A[4:0], value on B) ----------------
        check(ALU_SLL, 32'd4,  32'd1,        32'd16,       1'b0, "SLL 4");
        check(ALU_SLL, 32'd31, 32'd1,        32'h80000000, 1'b0, "SLL 31");
        check(ALU_SLL, 32'd0,  32'hDEADBEEF, 32'hDEADBEEF, 1'b0, "SLL 0");
        check(ALU_SRL, 32'd4,  32'h00000080, 32'h00000008, 1'b0, "SRL 4");
        check(ALU_SRL, 32'd31, 32'h80000000, 32'd1,        1'b0, "SRL 31");
        check(ALU_SRL, 32'd4,  32'hF0000000, 32'h0F000000, 1'b0, "SRL logic");

        // ---------------- MUL (low 32 bits) ----------------
        check(ALU_MUL, 32'd6,        32'd7,        32'd42,       1'b0, "MUL");
        check(ALU_MUL, 32'hFFFFFFFF, 32'hFFFFFFFF, 32'd1,        1'b0, "MUL -1*-1");
        check(ALU_MUL, 32'h00010000, 32'h00010000, 32'd0,        1'b1, "MUL ovflow");

        // ---------------- PASSA (bgez, bgtz, blez, bltz) ----------------
        check(ALU_PASSA, 32'hFFFFFFF0, 32'hDEADBEEF, 32'hFFFFFFF0, 1'b0, "PASSA neg");
        check(ALU_PASSA, 32'h00000000, 32'hDEADBEEF, 32'h00000000, 1'b1, "PASSA 0");
        check(ALU_PASSA, 32'h00000005, 32'hDEADBEEF, 32'h00000005, 1'b0, "PASSA pos");

        // ---------------- Unused control code -> 0 ----------------
        check(4'b1111, 32'h12345678, 32'h9ABCDEF0, 32'h00000000, 1'b1, "default");

        // ---------------- Summary ----------------
        $display("----------------------------------------");
        $display("Done: %0d passed, %0d failed", pass_count, fail_count);
        $finish;
	
	end

endmodule

