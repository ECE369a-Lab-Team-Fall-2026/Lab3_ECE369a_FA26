`timescale 1ns / 1ps
 
////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
//Aidan Walker 50%
//Sean Maloney 50%
//
// Module - data_memory.v
// Description - 32-Bit wide data memory.
//
// INPUTS:-
// Address: 32-Bit address input port.
// WriteData: 32-Bit input port.
// Clk: 1-Bit Input clock signal.
// MemWrite: 1-Bit control signal for memory write.
// MemRead: 1-Bit control signal for memory read.
//
// OUTPUTS:-
// ReadData: 32-Bit registered output port.
//
// FUNCTIONALITY:-
// Design the above memory similar to the 'RegisterFile' model in the previous 
// assignment.  Create a 1K memory, for which we need 10 bits.  In order to 
// implement byte addressing, we will use bits Address[11:2] to index the 
// memory location. The 'WriteData' value is written into the address 
// corresponding to Address[11:2] in the positive clock edge if 'MemWrite' 
// signal is 1. 'ReadData' is the value of memory location Address[11:2] if 
// 'MemRead' is 1, otherwise, it is 0x00000000. The reading of memory is not 
// clocked.
//
// you need to declare a 2d array. in this case we need an array of 1024 (1K)  
// 32-bit elements for the memory.   
// for example,  to declare an array of 256 32-bit elements, declaration is: reg[31:0] memory[0:255]
// if i continue with the same declaration, we need 8 bits to index to one of 256 elements. 
// however , address port for the data memory is 32 bits. from those 32 bits, least significant 2 
// bits help us index to one of the 4 bytes within a single word. therefore we only need bits [9-2] 
// of the "Address" input to index any of the 256 words. 
////////////////////////////////////////////////////////////////////////////////
 
module DataMemory(Address, WriteData, Clk, MemWrite, MemRead, MemSize ,ReadData); 
 
    input [31:0] Address; 	// Input Address 
    input [31:0] WriteData; // Data that needs to be written into the address 
    input Clk;
    input [1:0]  MemSize;       // NEEDED FOR lh sh sb lb  00 = word, 01 = half, 10 = byte
    input MemWrite; 		// Control signal for memory write 
    input MemRead; 			// Control signal for memory read 
    
 
    output reg[31:0] ReadData; // Contents of memory location at Address
 
    /* Please fill in the implementation here */
    
     // ---------- Size codes (match Controller.v) ----------
    localparam [1:0] SIZE_WORD = 2'b00;   // lw / sw
    localparam [1:0] SIZE_HALF = 2'b01;   // lh / sh
    localparam [1:0] SIZE_BYTE = 2'b10;   // lb / sb
    
 
    
        // ---------- Storage ----------
    // TODO: declare a 2D array of 1024 entries, each 32 bits wide
    // (same idea as the register file array, just deeper)
   reg [31:0] memory [0:1023];
 
    // Word index and the old contents of that word
    wire [9:0] old = Address[11:2];
    
    // ---------- Initialization ----------
   integer i;
    initial begin
        // Zero-fill first
        for (i = 0; i < 1024; i = i + 1)
            memory[i] = 32'h00000000;
        // Then load the program's data (overwrites the zeros it covers)
        $readmemh("data_memory.mem", memory);
    end
 
 
    // ---------- Write (rising edge, clocked) ----------
    reg [31:0] merged; // to read existing, and change target
 
    always @(posedge Clk) begin
        if (MemWrite == 1) begin
            merged = memory[old];        
            case (MemSize)
                SIZE_BYTE: begin                        // sb: replace one byte
                    case (Address[1:0])
                        2'b00: merged[7:0]   = WriteData[7:0];
                        2'b01: merged[15:8]  = WriteData[7:0];
                        2'b10: merged[23:16] = WriteData[7:0];
                        2'b11: merged[31:24] = WriteData[7:0];
                    endcase
                end
 
                SIZE_HALF: begin                        // sh: replace one halfword
                    if (Address[1] == 1'b0)
                        merged[15:0]  = WriteData[15:0];
                    else
                        merged[31:16] = WriteData[15:0];
                end
 
                default: merged = WriteData;            // sw: whole word
            endcase
 
            memory[old] <= merged;
        end
    end
    
    
    
    
    
    
    // ---------- Read (NOT clocked) ----------
    // TODO: this block must be combinational, so the sensitivity list
    //       should not include a clock edge (think @(*))
    wire [31:0] word = memory[old];   // word currently addressed (was never assigned)
    always @(*) begin
        // TODO: if MemRead is high,
        //       ReadData = entry indexed by Address[11:2]
 if (MemRead == 1) begin
            case (MemSize)
                SIZE_BYTE: begin                        // lb: pick byte, sign-extend
                    case (Address[1:0])
                        2'b00: ReadData = {{24{word[7]}},  word[7:0]};
                        2'b01: ReadData = {{24{word[15]}}, word[15:8]};
                        2'b10: ReadData = {{24{word[23]}}, word[23:16]};
                        2'b11: ReadData = {{24{word[31]}}, word[31:24]};
                    endcase
                end
        // TODO: otherwise,
        //       ReadData = 32'h00000000
        // (remember: blocking assignment in a combinational block)
                        SIZE_HALF: begin                        // lh: pick half, sign-extend
                    if (Address[1] == 1'b0)
                        ReadData = {{16{word[15]}}, word[15:0]};
                    else
                        ReadData = {{16{word[31]}}, word[31:16]};
                end
 
                default: ReadData = word;               // lw: whole word
            endcase
        end else begin
            ReadData = 32'h00000000;                    // no read: avoid a latch
        end
    end
endmodule