`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// Module - DataMemory_tb.v
// Description - Test the 'DataMemory.v' module.
////////////////////////////////////////////////////////////////////////////////

module DataMemory_tb(); 

    reg     [31:0]  Address;
    reg     [31:0]  WriteData;
    reg             Clk;
    reg             MemWrite;
    reg             MemRead;

    wire [31:0] ReadData;

    DataMemory u0(
        .Address(Address), 
        .WriteData(WriteData), 
        .Clk(Clk), 
        .MemWrite(MemWrite), 
        .MemRead(MemRead), 
        .ReadData(ReadData)
    ); 

	initial begin
		Clk <= 1'b0;
		forever #10 Clk <= ~Clk;
	end

	
	
    /* Please fill in the implementation here... */
        // need a way to count errors
        integer errors;
    
    // create tasks to make easier to code
    //Write/storeword
    task writing;
    input [31:0] a;
    input [31:0] d;
    begin 
        @(negedge Clk);
        Address=a;
        WriteData=d;
        MemWrite=1;
        MemRead=0;
        @(posedge Clk);
        #1 MemWrite=0;
    end 
    endtask
    
    //Load Word ie Read and test Expected
    task ReadCheck;
    input [31:0] a; 
    input [31:0] expected;
        begin
            Address=a;
            MemRead=1;
            MemWrite=0;
            @(negedge Clk); 
                #1;
                if (ReadData != expected) begin
                    errors = errors+1;
                    $display("FAIL: addr=%0d got=%h exp=%h", a, ReadData, expected);
                end else
                   $display("PASS: addr=%0d data=%h", a, ReadData);
                   MemRead = 0;
          end
    endtask
    
	initial begin
	    errors    = 0;
        Address   = 0;
        WriteData = 0;
        MemWrite  = 0;
        MemRead   = 0;
        
        #50; //wait a lil
	
	//store a few things
	   writing(32'd0,  32'h00000001);
        writing(32'd4,  32'h12345678);
        writing(32'd8,  32'hFFFFFFFF);
        writing(32'd12, 32'h00000000);
        writing(32'd64, 32'hABCDABCD);
        
    // Read them back
        ReadCheck(32'd0,  32'h00000001);
        ReadCheck(32'd4,  32'h12345678);
        ReadCheck(32'd8,  32'hFFFFFFFF);
        ReadCheck(32'd12, 32'h00000000);
        ReadCheck(32'd64, 32'hABCDABCD);
	

//an overwrite of one shouldnt affect tothers
        writing(32'd4, 32'hA5A5A5A5);
        
        ReadCheck(32'd0, 32'h00000001);
        ReadCheck(32'd4, 32'hA5A5A5A5);
        ReadCheck(32'd8, 32'hFFFFFFFF);
        
//MemWrite =0 shouldnt change memory
    @(negedge Clk);
       Address = 32'd0;
       WriteData=32'd87654321;
       MemWrite=0;
    @(posedge Clk);
        #1;
        ReadCheck(32'd0, 32'h00000001);
        
    if (errors == 0) $display("ALL TESTS PASSED");
    else             $display("%0d TEST(S) FAILED", errors);
        $finish;
        
        
end
    
endmodule

