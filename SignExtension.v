`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// Aidan Walker 50%
// Sean Maloney 50%
// Module - SignExtension.v
// Description - Sign/zero extension module.
//               SignExt = 1: sign-extend (addi, slti, lw, sw, branches, ...)
//               SignExt = 0: zero-extend (andi, ori, xori)
////////////////////////////////////////////////////////////////////////////////
module SignExtension(in, SignExt, out);

    /* A 16-Bit input word */
    input [15:0] in;

    /* 1 = sign-extend, 0 = zero-extend (driven by Controller) */
    input SignExt;

    /* A 32-Bit output word */
    output [31:0] out;

    assign out = SignExt ? { {16{in[15]}}, in } : { 16'b0, in };
endmodule