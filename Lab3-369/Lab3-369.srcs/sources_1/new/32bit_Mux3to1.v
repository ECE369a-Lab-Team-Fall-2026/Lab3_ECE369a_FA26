`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// Aidan Walker 50%
// Sean Maloney 50%

////////////////////////////////////////////////////////////////////////////////


module bit32_Mux3to1(out, in0, in1, in2, sel);
    output reg [31:0] out;
    input [31:0] in0, in1, in2;
    input [1:0] sel;
    always @(*) begin
        case (sel)
            2'b00:   out = in0;
            2'b01:   out = in1;
            2'b10:   out = in2;
            default: out = in0;
        endcase
    end

endmodule
