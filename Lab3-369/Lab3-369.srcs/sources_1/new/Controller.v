`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// Aidan Walker 50%
// Sean Maloney 50%

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// Aidan Walker 50%
// Sean Maloney 50%
// 
// Create Date: 10/31/2026 07:02:58 PM
// Design Name: 
// Module Name: Controller
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

////////////////////////////////////////////////////////////////////////////////

module Controller(


    input  [5:0] opcode,      // Idents the Instruction
    input  [5:0] funct,       // R type instructions opcode 00 0000
    input  [4:0] rt,          // bltz vs bgez opcode 00 0001
    
    ////////WB//////////////////////////////////////////////////////////////////////////
    output reg       RegWrite,   // writes to register
    ////////EX//////////////////////////////////////////////////////////////////////////
    output reg [1:0] RegDst,     // destination 00=rt 01 =rd 10=$31 (jal)
    output reg       ALUSrc,    // Alu input 0 = register   1 = immediate
    output reg       Shift,     //1= Alu A does sll or srl
    output reg [3:0] ALUControl,  //Alu Operations (choices of what it does Add sub etc) i think
    ////////ID//////////////////////////////////////////////////////////////////////////
    output reg       SignExt,    // 1= sign extend immediate   0= no extend
    ////////MEM//////////////////////////////////////////////////////////////////////////
    output reg       MemRead,     //Read Data   when 1
    output reg       MemWrite,    // Write Data when 1
    output reg [1:0] MemSize,     // size of memory 00= word   01= half word   10=byte
    ////////WB//////////////////////////////////////////////////////////////////////////
    output reg [1:0] MemtoReg,    // Write back =00    01= memory        10= PC+8 (jal)
    ////////I dont know//////////////////////////////////////////////////////////////////////////
    output reg [2:0] Branch,      // 000=none  001=beq  010= bne 011=bgez 100=bgtz  101=blez 110=bltz
    output reg       Jump,        // jump    j or jal
    output reg       JumpReg      // jr  
);
    
    
    // All Codes and what they mean 
                                                    // NOTE: localParam means we can just call ALU_And and it will just be returing 4'bXXXX in our code
    ////////////THE ALU CONTROL CODES        
    localparam ALU_AND   = 4'b0000;   // Bitwise AND
    localparam ALU_OR    = 4'b0001;   // Bitwise OR
    localparam ALU_ADD   = 4'b0010;   // Add (also address calc)
    localparam ALU_XOR   = 4'b0011;   // Bitwise XOR
    localparam ALU_SLL   = 4'b0100;   // Shift left logical
    localparam ALU_SRL   = 4'b0101;   // Shift right logical
    localparam ALU_SUB   = 4'b0110;   // Subtract
    localparam ALU_SLT   = 4'b0111;   // Set on less than
    localparam ALU_MUL   = 4'b1000;   // Multiply, low 32 bits
    localparam ALU_PASSA = 4'b1001;   // Pass A (branch vs zero)
    localparam ALU_NOR   = 4'b1100;   // Bitwise NOR
    
    ///////////// OPCODE////////////////////////
    localparam OP_RTYPE    = 6'b000000;   // R-type, decode by funct
    localparam OP_BZEROS   = 6'b000001;   // bltz / bgez (told apart by rt)
    localparam OP_J        = 6'b000010;   // Jump
    localparam OP_JAL      = 6'b000011;   // Jump and link
    
    localparam OP_BEQ      = 6'b000100;   // Branch equal
    localparam OP_BNE      = 6'b000101;   // Branch not equal
    localparam OP_BLEZ     = 6'b000110;   // Branch less/equal zero
    localparam OP_BGTZ     = 6'b000111;   // Branch greater than zero
    
    localparam OP_ADDI     = 6'b001000;   // Add immediate
    localparam OP_SLTI     = 6'b001010;   // Set less than immediate
    localparam OP_ANDI     = 6'b001100;   // AND immediate
    localparam OP_ORI      = 6'b001101;   // OR immediate
    localparam OP_XORI     = 6'b001110;   // XOR immediate
    localparam OP_SPECIAL  = 6'b011100;   // mul (funct 000010)
    
    localparam OP_LB       = 6'b100000;   // Load byte
    localparam OP_LH       = 6'b100001;   // Load halfword
    localparam OP_LW       = 6'b100011;   // Load word
    
    localparam OP_SB       = 6'b101000;   // Store byte
    localparam OP_SH       = 6'b101001;   // Store halfword
    localparam OP_SW       = 6'b101011;   // Store word
    
     ///////////// Function Code////////////////////////
    localparam F_SLL = 6'b000000;   // Shift left logical
    localparam F_SRL = 6'b000010;   // Shift right logical
    localparam F_JR  = 6'b001000;   // Jump register
    localparam F_ADD = 6'b100000;   // Add
    localparam F_SUB = 6'b100010;   // Subtract
    localparam F_AND = 6'b100100;   // AND
    localparam F_OR  = 6'b100101;   // OR
    localparam F_XOR = 6'b100110;   // XOR
    localparam F_NOR = 6'b100111;   // NOR
    localparam F_SLT = 6'b101010;   // Set on less than
    localparam F_MUL = 6'b000010;   // Multiply (Opcode Special)
    
    ////////////////////////Branch Codes////////////////
    localparam BR_NONE = 3'b000;   // Not a branch
    localparam BR_BEQ  = 3'b001;   // Branch equal
    localparam BR_BNE  = 3'b010;   // Branch not equal
    localparam BR_BGEZ = 3'b011;   // Branch >= zero
    localparam BR_BGTZ = 3'b100;   // Branch > zero
    localparam BR_BLEZ = 3'b101;   // Branch <= zero
    localparam BR_BLTZ = 3'b110;   // Branch < zero
    
    
    
 always @(*) begin
        // 1. Defaults for EVERY output (prevents latches)
        RegWrite   = 1'b0;
        RegDst     = 2'b00;
        ALUSrc     = 1'b0;
        Shift      = 1'b0;
        ALUControl = ALU_ADD;
        SignExt    = 1'b0;
        MemRead    = 1'b0;
        MemWrite   = 1'b0;
        MemSize    = 2'b00;
        MemtoReg   = 2'b00;
        Branch     = 3'b000;
        Jump       = 1'b0;
        JumpReg    = 1'b0;
        

//now run through each opcode case
        case (opcode) 
        // Reserts what differs
        OP_RTYPE:begin      //read the opcode      R type is for R type instructions like Add sub etc
            case(funct)     //then read function code within opcode ie one opcode has multiple function codes
                F_ADD: begin
                    RegWrite=1;
                    RegDst=2'b01;
                    ALUControl= ALU_ADD;
                        end
                F_SUB: begin 
                    RegWrite = 1;
                    RegDst = 2'b01; 
                    ALUControl = ALU_SUB;
                         end
                F_AND: begin
                    RegWrite = 1;
                    RegDst = 2'b01;
                    ALUControl = ALU_AND;
                        end
                F_OR:  begin
                    RegWrite = 1;
                    RegDst = 2'b01;
                    ALUControl = ALU_OR;
                        end
                F_XOR: begin
                    RegWrite = 1;
                    RegDst = 2'b01;
                    ALUControl = ALU_XOR;
                        end
                F_NOR: begin
                    RegWrite = 1;
                    RegDst = 2'b01;
                    ALUControl = ALU_NOR;
                        end
                F_SLT: begin
                    RegWrite = 1;
                    RegDst = 2'b01;
                    ALUControl = ALU_SLT;
                        end
                F_SLL: begin
                    RegWrite = 1;
                    RegDst = 2'b01;
                    ALUControl = ALU_SLL;
                    Shift = 1;
                        end
                F_SRL: begin
                    RegWrite = 1;
                    RegDst = 2'b01;
                    ALUControl = ALU_SRL;
                    Shift = 1;
                        end
                F_JR:  begin
                    JumpReg = 1;
                        end        
            endcase
            end
            
            // OPCODE CASE 2 OP_SPECIAL:
            OP_SPECIAL: begin
                if (funct==F_MUL) begin
                    RegWrite=1;
                    RegDst=2'b01;
                    ALUControl=ALU_MUL;
                    end
            end
           // I TYPE OP CODE///////////immediates  ADDI SLTI ANDI ORI XORI
           OP_ADDI:begin
                RegWrite=1;
                ALUSrc=1;
                SignExt=1;
                ALUControl= ALU_ADD ;
           end       
           OP_SLTI:begin
                RegWrite=1;
                ALUSrc=1;
                SignExt=1;
                ALUControl= ALU_SLT ;
           end
           OP_ANDI:begin
                RegWrite=1;
                ALUSrc=1;
                SignExt=0;
                ALUControl= ALU_AND ;
           end
           OP_ORI:begin
                RegWrite=1;
                ALUSrc=1;
                SignExt=0;
                ALUControl= ALU_OR ;
           end
           OP_XORI:begin
                RegWrite=1;
                ALUSrc=1;
                SignExt=0;
                ALUControl= ALU_XOR ;
           end
           /////////////////////////LOAD WORDS/////////////////////
           
           OP_LW: begin
               RegWrite = 1;
               ALUSrc = 1;
               SignExt = 1;
               ALUControl = ALU_ADD;
               MemRead = 1;
               MemSize = 2'b00;
               MemtoReg = 2'b01;
                    end
               OP_LH: begin
               RegWrite = 1;
               ALUSrc = 1;
               SignExt = 1;
               ALUControl = ALU_ADD;
               MemRead = 1;
               MemSize = 2'b01;
               MemtoReg = 2'b01;
                    end
           OP_LB: begin
                RegWrite = 1;
                ALUSrc = 1;
                SignExt = 1;
                ALUControl = ALU_ADD;
                MemRead = 1;
                MemSize = 2'b10;
                MemtoReg = 2'b01;
           end
        ////////////////////////////STORE WORDS//////////////
            OP_SW: begin
                ALUSrc = 1;
                SignExt = 1;
                ALUControl = ALU_ADD;
                MemWrite = 1;
                MemSize = 2'b00;
                    end
            OP_SH: begin 
                ALUSrc = 1;
                SignExt = 1;
                ALUControl = ALU_ADD;
                MemWrite = 1;
                MemSize = 2'b01;
                    end
            OP_SB: begin 
                ALUSrc = 1;
                SignExt = 1;
                ALUControl = ALU_ADD;
                MemWrite = 1;
                MemSize = 2'b10;
                    end
        /////////////////////////////BRANCHES///////////
            OP_BEQ: begin 
                SignExt = 1;
                 ALUControl = ALU_SUB;
                 Branch = BR_BEQ;
                    end
                    
            OP_BNE: begin 
                SignExt = 1;
                 ALUControl = ALU_SUB;
                 Branch = BR_BNE;
                    end
                    
            OP_BLEZ: begin
                SignExt = 1; 
                ALUControl = ALU_PASSA; 
                Branch = BR_BLEZ; 
                      end
            
            OP_BGTZ: begin
                SignExt = 1; 
                ALUControl = ALU_PASSA; 
                Branch = BR_BGTZ; 
                      end        
                      
          ///// DET BLTZ AND BGEZ is done with
          OP_BZEROS: begin
                SignExt = 1;
                ALUControl = ALU_PASSA;
                case (rt)
                    5'b00000: Branch = BR_BLTZ;
                    5'b00001: Branch = BR_BGEZ;
                        endcase
            end
        ////////////////////////////////////JUMPS   
        OP_J:begin
            Jump=1;
        end
        OP_JAL:begin
            Jump=1;
            RegWrite=1;
            RegDst=2'b10;
            MemtoReg=2'b10;
        end
        
        
        
        ///end OPCODE CASES
        endcase 
        
end
        
        
endmodule