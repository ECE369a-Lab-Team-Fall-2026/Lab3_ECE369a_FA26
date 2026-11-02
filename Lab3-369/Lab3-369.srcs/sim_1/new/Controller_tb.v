`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2026 07:08:08 PM
// Design Name: 
// Module Name: Controller_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Controller_tb();

    // ---------------- Inputs ----------------
    reg [5:0] opcode;
    reg [5:0] funct;
    reg [4:0] rt;
 
    // ---------------- Outputs ----------------
    wire       RegWrite;
    wire [1:0] RegDst;
    wire       ALUSrc;
    wire       Shift;
    wire [3:0] ALUControl;
    wire       SignExt;
    wire       MemRead;
    wire       MemWrite;
    wire [1:0] MemSize;
    wire [1:0] MemtoReg;
    wire [2:0] Branch;
    wire       Jump;
    wire       JumpReg;
 
    integer errors;
 
    Controller u0(
        .opcode(opcode), .funct(funct), .rt(rt),
        .RegWrite(RegWrite), .RegDst(RegDst), .ALUSrc(ALUSrc), .Shift(Shift),
        .ALUControl(ALUControl), .SignExt(SignExt),
        .MemRead(MemRead), .MemWrite(MemWrite), .MemSize(MemSize),
        .MemtoReg(MemtoReg), .Branch(Branch), .Jump(Jump), .JumpReg(JumpReg)
    );
    
/////////////////////ALU CONTROL CODES     match with ALU.v and Controller.v
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
 
 //////Branch Codes
    localparam BR_NONE = 3'b000;
    localparam BR_BEQ  = 3'b001;
    localparam BR_BNE  = 3'b010;
    localparam BR_BGEZ = 3'b011;
    localparam BR_BGTZ = 3'b100;
    localparam BR_BLEZ = 3'b101;
    localparam BR_BLTZ = 3'b110;
    
    // Un-neccesary Values  ie unused in checks 
    localparam [5:0] X6 = 6'b111111;
    localparam [4:0] X5 = 5'b11111;
    
    
    ///////////////////////////////////// Way to check whether or not something is correct
    reg [20:0] got; // retrieved from the Controller.v 
    reg [20:0] expected;
    
    
        task Test;
        input [8*8:1] name;
        input [5:0]  op;
        input [5:0]  fn;
        input [4:0]  r;
        input        e_RegWrite;
        input [1:0]  e_RegDst;
        input        e_ALUSrc;
        input        e_Shift;
        input [3:0]  e_ALUControl;
        input        e_SignExt;
        input        e_MemRead;
        input        e_MemWrite;
        input [1:0]  e_MemSize;
        input [1:0]  e_MemtoReg;
        input [2:0]  e_Branch;
        input        e_Jump;
        input        e_JumpReg;
        begin
            opcode = op;
            funct  = fn;
            rt     = r;
            #10;
            // takes recieved from Controller.v and compares it to expected given values.
            got = {RegWrite, RegDst, ALUSrc, Shift, ALUControl, SignExt,
                   MemRead, MemWrite, MemSize, MemtoReg, Branch, Jump, JumpReg};
            expected = {e_RegWrite, e_RegDst, e_ALUSrc, e_Shift, e_ALUControl, e_SignExt,
                   e_MemRead, e_MemWrite, e_MemSize, e_MemtoReg, e_Branch, e_Jump, e_JumpReg};
            if (got !== expected) begin
                errors = errors + 1;
                $display("FAIL %0s: got=%b expected=%b", name, got, expected);
            end else
                $display("PASS %0s", name);
        end
    endtask
    
    
    
 initial begin
 errors=0;
   // ---- R-type (opcode 000000, decoded by funct) ----
        Test("add ",  6'b000000, 6'b100000, X5,    1, 2'b01, 0, 0, ALU_ADD,  0, 0, 0, 2'b00, 2'b00, BR_NONE, 0, 0);
        Test("sub ",  6'b000000, 6'b100010, X5,    1, 2'b01, 0, 0, ALU_SUB,  0, 0, 0, 2'b00, 2'b00, BR_NONE, 0, 0);
        Test("and ",  6'b000000, 6'b100100, X5,    1, 2'b01, 0, 0, ALU_AND,  0, 0, 0, 2'b00, 2'b00, BR_NONE, 0, 0);
        Test("or  ",  6'b000000, 6'b100101, X5,    1, 2'b01, 0, 0, ALU_OR,   0, 0, 0, 2'b00, 2'b00, BR_NONE, 0, 0);
        Test("xor ",  6'b000000, 6'b100110, X5,    1, 2'b01, 0, 0, ALU_XOR,  0, 0, 0, 2'b00, 2'b00, BR_NONE, 0, 0);
        Test("nor ",  6'b000000, 6'b100111, X5,    1, 2'b01, 0, 0, ALU_NOR,  0, 0, 0, 2'b00, 2'b00, BR_NONE, 0, 0);
        Test("slt ",  6'b000000, 6'b101010, X5,    1, 2'b01, 0, 0, ALU_SLT,  0, 0, 0, 2'b00, 2'b00, BR_NONE, 0, 0);
        Test("sll ",  6'b000000, 6'b000000, X5,    1, 2'b01, 0, 1, ALU_SLL,  0, 0, 0, 2'b00, 2'b00, BR_NONE, 0, 0);
        Test("srl ",  6'b000000, 6'b000010, X5,    1, 2'b01, 0, 1, ALU_SRL,  0, 0, 0, 2'b00, 2'b00, BR_NONE, 0, 0);
        Test("jr  ",  6'b000000, 6'b001000, X5,    0, 2'b00, 0, 0, ALU_ADD,  0, 0, 0, 2'b00, 2'b00, BR_NONE, 0, 1);
        Test("nop ",  6'b000000, 6'b000000, 5'b0,  1, 2'b01, 0, 1, ALU_SLL,  0, 0, 0, 2'b00, 2'b00, BR_NONE, 0, 0); // = sll $0,$0,0
    
// ---- mul (opcode 011100, funct 000010) ----
        Test("mul ",  6'b011100, 6'b000010, X5,    1, 2'b01, 0, 0, ALU_MUL,  0, 0, 0, 2'b00, 2'b00, BR_NONE, 0, 0);
// ---- I-type ALU ----
        Test("addi",  6'b001000, X6,        X5,    1, 2'b00, 1, 0, ALU_ADD,  1, 0, 0, 2'b00, 2'b00, BR_NONE, 0, 0);
        Test("slti",  6'b001010, X6,        X5,    1, 2'b00, 1, 0, ALU_SLT,  1, 0, 0, 2'b00, 2'b00, BR_NONE, 0, 0);
        Test("andi",  6'b001100, X6,        X5,    1, 2'b00, 1, 0, ALU_AND,  0, 0, 0, 2'b00, 2'b00, BR_NONE, 0, 0);
        Test("ori ",  6'b001101, X6,        X5,    1, 2'b00, 1, 0, ALU_OR,   0, 0, 0, 2'b00, 2'b00, BR_NONE, 0, 0);
        Test("xori",  6'b001110, X6,        X5,    1, 2'b00, 1, 0, ALU_XOR,  0, 0, 0, 2'b00, 2'b00, BR_NONE, 0, 0);
 
// ---- Loads ----
        Test("lw  ",  6'b100011, X6,        X5,    1, 2'b00, 1, 0, ALU_ADD,  1, 1, 0, 2'b00, 2'b01, BR_NONE, 0, 0);
        Test("lh  ",  6'b100001, X6,        X5,    1, 2'b00, 1, 0, ALU_ADD,  1, 1, 0, 2'b01, 2'b01, BR_NONE, 0, 0);
        Test("lb  ",  6'b100000, X6,        X5,    1, 2'b00, 1, 0, ALU_ADD,  1, 1, 0, 2'b10, 2'b01, BR_NONE, 0, 0);
 
// ---- Stores ----
        Test("sw  ",  6'b101011, X6,        X5,    0, 2'b00, 1, 0, ALU_ADD,  1, 0, 1, 2'b00, 2'b00, BR_NONE, 0, 0);
        Test("sh  ",  6'b101001, X6,        X5,    0, 2'b00, 1, 0, ALU_ADD,  1, 0, 1, 2'b01, 2'b00, BR_NONE, 0, 0);
        Test("sb  ",  6'b101000, X6,        X5,    0, 2'b00, 1, 0, ALU_ADD,  1, 0, 1, 2'b10, 2'b00, BR_NONE, 0, 0);
 
// ---- Branches ----
        Test("beq ",  6'b000100, X6,        X5,    0, 2'b00, 0, 0, ALU_SUB,  0, 0, 0, 2'b00, 2'b00, BR_BEQ,  0, 0);
        Test("bne ",  6'b000101, X6,        X5,    0, 2'b00, 0, 0, ALU_SUB,  0, 0, 0, 2'b00, 2'b00, BR_BNE,  0, 0);
        Test("blez",  6'b000110, X6,        X5,    0, 2'b00, 0, 0, ALU_PASSA,0, 0, 0, 2'b00, 2'b00, BR_BLEZ, 0, 0);
        Test("bgtz",  6'b000111, X6,        X5,    0, 2'b00, 0, 0, ALU_PASSA,0, 0, 0, 2'b00, 2'b00, BR_BGTZ, 0, 0);
        Test("bltz",  6'b000001, X6,        5'b00000, 0, 2'b00, 0, 0, ALU_PASSA,0, 0, 0, 2'b00, 2'b00, BR_BLTZ, 0, 0);
        Test("bgez",  6'b000001, X6,        5'b00001, 0, 2'b00, 0, 0, ALU_PASSA,0, 0, 0, 2'b00, 2'b00, BR_BGEZ, 0, 0);
 
// ---- Jumps ----
        Test("j   ",  6'b000010, X6,        X5,    0, 2'b00, 0, 0, ALU_ADD,  0, 0, 0, 2'b00, 2'b00, BR_NONE, 1, 0);
        Test("jal ",  6'b000011, X6,        X5,    1, 2'b10, 0, 0, ALU_ADD,  0, 0, 0, 2'b00, 2'b10, BR_NONE, 1, 0);
 
// ---- Unknown opcode must do nothing (defaults) ----
        Test("No_OPTest", 6'b111111, X6,        X5,    0, 2'b00, 0, 0, ALU_ADD,  0, 0, 0, 2'b00, 2'b00, BR_NONE, 0, 0);
    
    $display("====================================");
    if (errors == 0) $display("ALL TESTS PASSED");
    else             $display("%0d TEST(S) FAILED", errors);
    $display("====================================");
    $finish;
    
   end 
endmodule
