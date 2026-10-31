`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// Module - ALU32Bit.v
// Description - 32-Bit wide arithmetic logic unit (ALU).
//
// INPUTS:-
// ALUControl: N-Bit input control bits to select an ALU operation.
// A: 32-Bit input port A.
// B: 32-Bit input port B.
//
// OUTPUTS:-
// ALUResult: 32-Bit ALU result output.
// ZERO: 1-Bit output flag. 
//
// FUNCTIONALITY:-
// Design a 32-Bit ALU, so that it supports all arithmetic operations 
// needed by the MIPS instructions given in Labs5-8.docx document. 
//   The 'ALUResult' will output the corresponding result of the operation 
//   based on the 32-Bit inputs, 'A', and 'B'. 
//   The 'Zero' flag is high when 'ALUResult' is '0'. 
//   The 'ALUControl' signal should determine the function of the ALU 
//   You need to determine the bitwidth of the ALUControl signal based on the number of 
//   operations needed to support. 
////////////////////////////////////////////////////////////////////////////////

module ALU32Bit(ALUControl, A, B, ALUResult, Zero);

	input [3:0] ALUControl; // control bits for ALU operation
                                // you need to adjust the bitwidth as needed
	input [31:0] A, B;	    // inputs

	output reg [31:0] ALUResult;	// answer
	output Zero;	    // Zero=1 if ALUResult == 0

    /* Please fill in the implementation here... */
    //ALU Control Encoding
    localparam ALU_AND = 4'b0000; // and , andi
    localparam ALU_OR  = 4'b0001; // or, ori
    localparam ALU_ADD = 4'b0010; // add, addi, lw, lh, lb, sw, sh, sb (address calc)
    localparam ALU_XOR = 4'b0011; //xor, xori
    localparam ALU_SLL = 4'b0100; // sll
    localparam ALU_SRL = 4'b0101; // srl
    localparam ALU_SUB = 4'b0110; // sub, beq, bne
    localparam ALU_SLT = 4'b0111; // slt, slti
    localparam ALU_MUL = 4'b1000; // mul (low 32 bits)
    localparam ALU_PASSA = 4'b1001; //bgez, bgtz, blez, bltz, (Result = A)
    localparam ALU_NOR = 4'b1100; ///nor
    
    always @(*) begin
        case(ALUControl)
            ALU_AND:   ALUResult = A & B;
            ALU_OR:    ALUResult = A | B;
            ALU_ADD:   ALUResult = A + B;
            ALU_XOR:   ALUResult = A ^ B;
            ALU_SLL:   ALUResult = B << A[4:0];
            ALU_SRL:   ALUResult = B >> A[4:0];
            ALU_SUB:   ALUResult = A - B;
            ALU_SLT:   ALUResult = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
            ALU_MUL:   ALUResult = A * B;
            ALU_PASSA: ALUResult = A;
            ALU_NOR:   ALUResult = ~(A | B);
            default:   ALUResult = 32'd0;
        endcase
    end
    
    assign  Zero = ALUResult == 32'd0;


endmodule

