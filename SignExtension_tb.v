`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Module - SignExtension_tb.v
// Description - Tests sign-extend and zero-extend modes.
////////////////////////////////////////////////////////////////////////////////
module SignExtension_tb();

    reg  [15:0] in;
    reg         SignExt;
    wire [31:0] out;

    integer errors;

    SignExtension uut (
        .in(in),
        .SignExt(SignExt),
        .out(out)
    );

    task check;
        input [15:0] t_in;
        input        t_sign;
        input [31:0] expected;
        begin
            in = t_in;
            SignExt = t_sign;
            #10;
            if (out !== expected) begin
                errors = errors + 1;
                $display("FAIL: in=%h SignExt=%b out=%h expected=%h",
                         t_in, t_sign, out, expected);
            end else
                $display("PASS: in=%h SignExt=%b out=%h", t_in, t_sign, out);
        end
    endtask

    initial begin
        errors = 0;

        // Sign-extend mode (SignExt = 1)
        check(16'h0000, 1, 32'h00000000);
        check(16'h0001, 1, 32'h00000001);
        check(16'h7FFF, 1, 32'h00007FFF);  // largest positive
        check(16'h8000, 1, 32'hFFFF8000);  // smallest negative
        check(16'hFFFF, 1, 32'hFFFFFFFF);  // -1

        // Zero-extend mode (SignExt = 0)
        check(16'h0000, 0, 32'h00000000);
        check(16'h0001, 0, 32'h00000001);
        check(16'h7FFF, 0, 32'h00007FFF);
        check(16'h8000, 0, 32'h00008000);  // upper bits must stay 0
        check(16'hFFFF, 0, 32'h0000FFFF);  // andi $t0,$t0,65535 case

        // Toggle mode with the same input to confirm output follows control
        check(16'h8000, 1, 32'hFFFF8000);
        check(16'h8000, 0, 32'h00008000);

        if (errors == 0) $display("All tests passed.");
        else             $display("%0d test(s) failed.", errors);
        $finish;
    end

endmodule