`timescale 1ns / 1ps

//////////////////////////////////////////////////
// Module - Controller.v
//
// INPUTS - 
// Opcode: instruction[31:26]
// Function: instruction[5:0]
// RT: instruction[20:16]
//
//  OUTPUTS - 
// RegDst [1:0]
// ALUSrcA
// ALUSrcB
// ExtOp
// ALUControl [3:0]
// MemRead
// MemWrite
// MemSize [1:0]
// MemtoReg [1:0]
// RegWrite
// BranchType [2:0]
// Jump [1:0]

module Controller(
  Opcode, Function, RT, RegDst, ALUSrcA, ALUSrcB, ExtOp, ALUControl, MemRead, MemWrite, MemSize, MemtoReg, RegWrite, BranchType, Jump
);

  input [5:0] Opcode;
  input [5:0] Function;
  input [4:0] RT;

  output reg [1:0] RegDst;
  output reg ALUSrcA;
  output reg ALUSrcB;
  output reg ExtOp;
  output reg [3:0] ALUControl;
  output reg MemRead;
  output reg MemWrite;
  output reg [1:0] MemSize;
  output reg [1:0] MemtoReg;
  output reg RegWrite;
  output reg [2:0] BranchType;
  output reg [1:0] Jump;

  localparam OP_RTYPE = 6'b000000;
  localparam OP_REGIMM = 6'b000001;
  localparam OP_J = 6'b000010;
  localparam OP_JAL = 6'b000011;
  localparam OP_BEQ = 6'b000100;
  localparam OP_BNE = 6'b000101;
  localparam OP_BLEZ = 6'b000110;
  localparam OP_BGTZ = 6'b000111;
  localparam OP_ADDI = 6'b001000;
  localparam OP_SLTI = 6'b001010;
  localparam OP_ANDI = 6'b001100;
  localparam OP_ORI = 6'b001101;
  localparam OP_XORI = 6'b001110;
  localparam OP_SPECIAL2 = 6'b011100;
  localparam OP_LB = 6'b100000;
  localparam OP_LH = 6'b100001;
  localparam OP_LW = 6'b100011;
  localparam OP_SB = 6'b101000;
  localparam OP_SH = 6'b101001;
  localparam OP_SW = 6'b101011;

  localparam F_SLL = 6'b000000;
  localparam F_SRL = 6'b000010;
  localparam F_JR  = 6'b001000;
  localparam F_ADD = 6'b100000;
  localparam F_SUB = 6'b100010;
  localparam F_AND = 6'b100100;
  localparam F_OR  = 6'b100101;
  localparam F_XOR = 6'b100110;
  localparam F_NOR = 6'b100111;
  localparam F_SLT = 6'b101010;
  localparam F_MUL = 6'b000010;

  localparam ALU_AND   = 4'b0000;
  localparam ALU_OR    = 4'b0001;
  localparam ALU_ADD   = 4'b0010;
  localparam ALU_XOR   = 4'b0011;
  localparam ALU_NOR   = 4'b0100;
  localparam ALU_MUL   = 4'b0101;
  localparam ALU_SUB   = 4'b0110;
  localparam ALU_SLT   = 4'b0111;
  localparam ALU_PASSA = 4'b1000;
  localparam ALU_SLL   = 4'b1001;
  localparam ALU_SRL   = 4'b1010;

  localparam BR_NONE = 3'b000;
  localparam BR_BEQ  = 3'b001;
  localparam BR_BNE  = 3'b010;
  localparam BR_BGEZ = 3'b011;
  localparam BR_BGTZ = 3'b100;
  localparam BR_BLEZ = 3'b101;
  localparam BR_BLTZ = 3'b110;

  always @(*) begin
    RegDst = 2'b00;
    ALUSrcA = 1'b0;
    ALUSrcB = 1'b0;
    ExtOp = 1'b0;
    ALUControl = ALU_ADD;
    MemRead = 1'b0;
    MemWrite = 1'b0;
    MemSize = 2'b10;
    MemtoReg = 2'b00;
    RegWrite = 1'b0;
    BranchType = BR_NONE;
    Jump = 2'b00;

    case (Opcode)
      OP_RTYPE: begin
        RegDst = 2'b01;
        RegWrite = 1'b1;
        case (Function)
          F_ADD: ALUControl = ALU_ADD;
          F_SUB: ALUControl = ALU_SUB;
          F_AND: ALUControl = ALU_AND;
          F_OR: ALUControl = ALU_OR;
          F_NOR: ALUControl = ALU_NOR;
          F_XOR: ALUControl = ALU_XOR;
          F_SLT: ALUControl = ALU_SLT;
          F_SLL: begin ALUControl = ALU_SLL; ALUSrcA = 1'b1; end
          F_SRL: begin ALUControl = ALU_SRL; ALUSrcA = 1'b1; end
          F_JR: begin RegWrite = 1'b0; Jump = 2'b10; end
          default: RegWrite = 1'b0;
        endcase
      end

      OP_SPECIAL2: begin
        if (Function == F_MUL) begin
          RegDst = 2'b01;
          RegWrite = 1'b1;
          ALUControl = ALU_MUL;
        end
      end

      OP_ADDI: begin ALUSrcB = 1'b1; RegWrite = 1'b1; ALUControl = ALU_ADD; end
      OP_SLTI: begin ALUSrcB = 1'b1; RegWrite = 1'b1; ALUControl = ALU_SLT; end
      OP_ANDI: begin ALUSrcB = 1'b1; RegWrite = 1'b1; ExtOp = 1'b1; ALUControl = ALU_AND; end
      OP_ORI: begin ALUSrcB = 1'b1; RegWrite = 1'b1; ExtOp = 1'b1; ALUControl = ALU_OR; end
      OP_XORI: begin ALUSrcB = 1'b1; RegWrite = 1'b1; ExtOp = 1'b1; ALUControl = ALU_XOR; end

      OP_LW: begin
        ALUSrcB = 1'b1; MemRead = 1'b1; MemtoReg = 2'b01;
        RegWrite = 1'b1; MemSize = 2'b10; ALUControl = ALU_ADD;
      end
      OP_LH: begin
        ALUSrcB = 1'b1; MemRead = 1'b1; MemtoReg = 2'b01;
        RegWrite = 1'b1; MemSize = 2'b01; ALUControl = ALU_ADD;
      end
      OP_LB: begin
        ALUSrcB = 1'b1; MemRead = 1'b1; MemtoReg = 2'b01;
        RegWrite = 1'b1; MemSize = 2'b00; ALUControl = ALU_ADD;
      end

      OP_SW: begin ALUSrcB = 1'b1; MemWrite = 1'b1; MemSize = 2'b10; ALUControl = ALU_ADD; end
      OP_SH: begin ALUSrcB = 1'b1; MemWrite = 1'b1; MemSize = 2'b01; ALUControl = ALU_ADD; end
      OP_SB: begin ALUSrcB = 1'b1; MemWrite = 1'b1; MemSize = 2'b00; ALUControl = ALU_ADD; end

      OP_BEQ: begin ALUControl = ALU_SUB; BranchType = BR_BEQ; end
      OP_BNE: begin ALUControl = ALU_SUB; BranchType = BR_BNE; end
      OP_BGTZ: begin ALUControl = ALU_PASSA; BranchType = BR_BGTZ; end
      OP_BLEZ: begin ALUControl = ALU_PASSA; BranchType = BR_BLEZ; end
      OP_REGIMM: begin
        case (RT)
          5'b00001: begin ALUControl = ALU_PASSA; BranchType = BR_BGEZ; end
          5'b00000: begin ALUControl = ALU_PASSA; BranchType = BR_BLTZ; end
          default: ;
        endcase
      end

      OP_J: Jump = 2'b01;
      OP_JAL: begin
        Jump = 2'b01;
        RegDst = 2'b10;
        MemtoReg = 2'b10;
        RegWrite = 1'b1;
      end

      default: ;
    endcase
  end

endmodule
