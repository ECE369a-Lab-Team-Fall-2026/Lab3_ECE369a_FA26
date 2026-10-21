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

	output [31:0] ALUResult;	// answer
	output Zero;	    // Zero=1 if ALUResult == 0

    /* Please fill in the implementation here... */
    //
    //We need to do all of these cases
    //
    //   ____   | ADD       | add, addi, lw, lh, lb, sw, sh, sb (address calc)
    //   ____   | SUB       | sub, beq, bne (Zero flag does the compare)
    //   ____   | MUL       | mul
    //   ____   | AND       | and, andi
    //   ____   | OR        | or, ori
    //   ____   | NOR       | nor   
    //   ____   | XOR       | xor, xori
    //   ____   | SLL       | sll
    //   ____   | SRL       | srl
    //   ____   | SLT       | slt, slti
    //   ____   | ???       | bgez, bgtz, blez, bltz (see branch notes below)
    //   ____   | PASS A    | jr (optional, if the ALU passes the register)
    
    // Arithmatic
/*
    ADD 
    ADDI
    SUB
    Mul
    
*/
    // Data
/*
    lw
    sw
    sb
    lh
    lb
    sh

*/
    // Branch
/*
    BGEZ
    BEQ
    BNE
    BGTZ
    BLEZ
    BLTZ
    
    J
    JR
    JAL

*/
    // Logical 
/*
    And
    Andi
    Or
    Nor
    xor
    ori
    xori
    sll
    srl
    slt
    slti

*/
    
endmodule

