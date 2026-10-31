`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// Module - RegisterFile.v
// Description - Test the register_file
// Suggested test case - First write arbitrary values into 
// the saved and temporary registers (i.e., register 8 through 25). Then, 2-by-2, 
// read values from these registers.
////////////////////////////////////////////////////////////////////////////////


module RegisterFile_tb();

	reg [4:0] ReadRegister1;
	reg [4:0] ReadRegister2;
	reg	[4:0] WriteRegister;
	reg [31:0] WriteData;
	reg RegWrite;
	reg Clk;

	wire [31:0] ReadData1;
	wire [31:0] ReadData2;


	RegisterFile u0(
		.ReadRegister1(ReadRegister1), 
		.ReadRegister2(ReadRegister2), 
		.WriteRegister(WriteRegister), 
		.WriteData(WriteData), 
		.RegWrite(RegWrite), 
		.Clk(Clk), 
		.ReadData1(ReadData1), 
		.ReadData2(ReadData2)
	);

	initial begin
		Clk <= 1'b0;
		forever #10 Clk <= ~Clk;
	end

	
	
    /* Please fill in the implementation here... */
	
	// moved initial begin to be lower.
	
	// need a way to count errors
	integer errors;
	// increment whenever check does not work correctly
	
	// First Write a few things to make it Easier we can call these things whenever we need to (avoids writing long code
	// Write and Reading            needs to be outside initial begin
	
	// Writing
	  task writeToreg(input [4:0] r, input [31:0] d);
    begin
        @(negedge Clk);
        WriteRegister  = r;
        WriteData = d;
        RegWrite  = 1;
        @(posedge Clk);
        #1 RegWrite = 0;
    end
    endtask 
	
	//task 2 Error Check when Reading registers
	 task checkRead;
        input [4:0]  a;
        input [4:0]  b;
        input [31:0] exp_a;
        input [31:0] exp_b;
        begin
            ReadRegister1 = a;
            ReadRegister2 = b;
            @(negedge Clk);
            #1;
            if (ReadData1 !== exp_a || ReadData2 !== exp_b) begin
                errors = errors + 1;
                $display("FAIL: R%0d=%h (exp %h), R%0d=%h (exp %h)",
                         a, ReadData1, exp_a, b, ReadData2, exp_b);
            end else
                $display("PASS: R%0d=%h, R%0d=%h", a, ReadData1, b, ReadData2);
        end
    endtask 
	
	
	initial begin
	    errors        = 0;
        RegWrite      = 0;
        ReadRegister1 = 0;
        ReadRegister2 = 0;
        WriteRegister = 0;
        WriteData     = 0;
	

#50
// wait a bit

//writing
writeToreg(5'd1, 32'h00001111);
writeToreg(5'd2, 32'h11110000);
writeToreg(5'd3, 32'hFFFFFFFF);

//Read Test Inputing d#, and expecting 32'
checkRead(5'd1, 5'd2, 32'h00001111, 32'h11110000);
checkRead(5'd3, 5'd3, 32'hFFFFFFFF, 32'hFFFFFFFF);   

// Check if you can change d1
        writeToreg(5'd1, 32'hABCDEFAB);
        checkRead(5'd1, 5'd2, 32'hABCDEFAB, 32'h11110000);

// RegWrite=0 test
        @(negedge Clk);
        WriteRegister = 5'd2;
        WriteData     = 32'h12345678;
        RegWrite      = 0;
        @(posedge Clk);
        #1;
        checkRead(5'd2, 5'd3, 32'h11110000, 32'hFFFFFFFF);
        
// Register 32 test 
writeToreg(5'd31, 32'hFEDCBAFE);
checkRead(5'd31,5'd1,32'hABCDEFAB,32'hFEDCBAFE);

 if (errors == 0) $display("PASSED");
        else             $display("%0d TEST(S) FAILED", errors);
        $finish;
end
endmodule
