`timescale 1ns / 1ps
/*
 * TopLevel.v
 *
 * Purpose:
 *   Implement and connect the complete 5-stage pipelined MIPS datapath
 *   required for ECE369A Lab 4.
 *
 * Pipeline stages:
 *   1. IF  - Instruction Fetch
 *   2. ID  - Instruction Decode
 *   3. EX  - Execute
 *   4. MEM - Memory Access
 *   5. WB  - Write Back
 *
 * Main components instantiated in this module:
 *   - Program Counter
 *   - Instruction Memory
 *   - IF/ID pipeline register
 *   - Controller
 *   - Register File
 *   - Immediate extension logic
 *   - ID/EX pipeline register
 *   - ALU
 *   - ALU input/output selection logic
 *   - Branch target/condition logic
 *   - Jump/JR/JAL logic
 *   - EX/MEM pipeline register
 *   - Data Memory
 *   - MEM/WB pipeline register
 *   - Write-back selection logic
 *
 * Responsibilities:
 *   - Connect all datapath components.
 *   - Calculate PC + 4.
 *   - Select the next PC for:
 *       - Normal sequential execution
 *       - Branches
 *       - Jump
 *       - Jump Register
 *       - Jump and Link
 *   - Select ALU operands.
 *   - Select destination registers.
 *   - Handle sign and zero extension.
 *   - Handle shift amount for sll and srl.
 *   - Pass control signals through pipeline registers.
 *   - Route memory results or ALU results back to the Register File.
 *   - Support all instructions required by the Lab 4 ISA.
 *
 * Required demonstration outputs:
 *   - 32-bit current/instruction PC
 *   - 32-bit value being written to the Register File
 *
 * Important:
 *   These top-level outputs must remain connected so that Vivado does
 *   not optimize away the processor during implementation.
 */

module Top(Clk, Reset, PCResult, WriteData);

  input Clk;
  input Reset;
  output [31:0] PCResult;
  output [31:0] WriteData;

  localparam ALU_PASSA = 4'b1000;

  // IF
  wire [31:0] PC, PCNext, PCAfterJump;
  wire [31:0] PCPlus4_IF = PC + 32'd4;
  wire [31:0] Instruction_IF;
  wire [31:0] JumpTarget_ID, MemTarget;
  wire MemRedirect;
  wire [1:0] Jump_ID;
  wire JumpID = (Jump_ID == 2'b01);

  Mux32Bit2To1 mux_pc_jump(.out(PCAfterJump), .inA(PCPlus4_IF), .inB(JumpTarget_ID), .sel(JumpID));
  Mux32Bit2To1 mux_pc_redirect(.out(PCNext), .inA(PCAfterJump), .inB(MemTarget), .sel(MemRedirect));

  ProgramCounter pc_reg(.Address(PCNext), .PCResult(PC), .Reset(Reset), .Clk(Clk));

  InstructionMemory im(.Address(PC), .Instruction(Instruction_IF));

  //IF_ID
  wire [31:0] PCPlus4_ID, Instruction_ID;

  IF_ID ifid(.Clk(Clk), .Reset(Reset), .Instruction(Instruction_IF), .PCValue(PCPlus4_IF), .StoredInstruction(Instruction_ID), .StoredPCValue(PCPlus4_ID));

  //ID
  wire [4:0] Rs_ID = Instruction[25:21];
  wire [4:0] Rt_ID = Instruction[20:16];
  wire [4:0] Rd_ID = Instruction[15:11];
  wire [4:0] Shamt_ID = Instruction[10:6];

  wire [1:0] RegDst_ID, MemSize_ID, MemtoReg_ID;
  wire ALUSrcA_ID, ALUSrcB_ID, ExtOp_ID, MemRead_ID, MemWrite_ID, RegWrite_ID;
  wire [3:0] ALUControl_ID;
  wire [2:0] BranchType_ID;

  Controller ctrl(.Opcode(Instruction_ID[31:26]), .Function(Instruction_ID[5:0]), .RT(Rt_ID), .RegDst(RegDst_ID), .ALUSrcA(ALUSrcA_ID), .ALUSrcB(ALUSrcB_ID), .ExtOp(ExtOp_ID), .ALUControl(ALUControl_ID), .MemRead(MemRead_ID), .MemWrite(MemWrite_ID), .MemSize(MemSize_ID), .MemtoReg(MemtoReg_ID), .RegWrite(RegWrite_ID), .BranchType(BranchType_ID), .Jump(Jump_ID));

  wire [31:0] SignExt_ID, Imm_ID;
  SignExtension signext(.in(Instruction_ID[15:0]), .out(SignExt_ID));
  Mux32Bit2To1 mux_ext(.out(Imm_ID), .inA(SignExt_ID), .inB({16'b0, Instruction_ID[15:0]}), .sel(ExtOp_ID));

  assign JumpTarget_ID = {PCPlus4_ID[31:28], Instruction_ID[25:0], 2'b00};

  wire [31:0] RegData1_ID, RegData2_ID;
  wire RegWrite_WB;
  wire [4:0] DestReg_WB;
  wire [31:0] WB_Data;

  RegisterFile rf(.ReadRegister(Rs_ID), .ReadRegister2(Rt_ID), .WriteRegister(DestReg_WB), .WriteData(WB_Data), .RegWrite(RegWrite_WB), .Clk(Clk), .ReadData1(RegData1_ID), .ReadData2(RegData2_ID));

  //ID_EX
  wire [1:0] RegDst_EX, MemSize_EX, MemtoReg_EX, Jump_EX;
  wire ALUSrcA_EX, ALUSrcB_EX, MemRead_EX, MemWrite_EX, RegWrite_EX;
  wire [3:0] ALUControl_EX;
  wire [2:0] BranchType_EX;
  wire [31:0] PCPlus4_EX, RegData1_EX, RegData2_EX, Imm_EX;
  wire [4:0] Rs_EX, Rt_EX, Rd_EX, Shamt_EX;

  ID_EX idex(.Clk(Clk), .Reset(Reset), .RegisterData1(RegData1_ID), .RegisterData2(RegData2_ID), .Imm(Imm_ID), .PCValue(PCPlus4_ID), .rt(Rt_ID), .rd(Rd_ID), .rs(Rs_ID), .Shamt(Shamt_ID), .RegDst(RegDst_ID), .ALUSrcA(ALUSrcA_ID), .ALUSrcB(ALUSrcB_ID), .ALUControl(ALUControl_ID),
             .MemRead(MemRead_ID), .MemWrite(MemWrite_ID), .MemSize(MemSize_ID), .MemtoReg(MemtoReg_ID), .RegWrite(RegWrite_ID), .BranchType(BranchType_ID), .Jump(Jump_ID), .ReadData1(RegData1_EX), .ReadData2(RegData2_EX), .Imm_out(Imm_EX), .PCValue_out(PCPlus4_EX),
             .rt_out(Rt_EX), .rd_out(Rd_EX), .rs_out(Rs_EX), .Shamt_out(Shamt_EX), .RegDst_out(RegDst_EX), .ALUSrcA_out(ALUSrcA_EX), .ALUSrcB_out(ALUSrcB_EX), .ALUControl_out(ALUControl_EX), .MemRead_out(MemRead_EX), .MemWrite_out(MemWrite_EX), .MemSize_out(MemSize_EX),
             .MemtoReg_out(MemtoReg_EX), .RegWrite_out(RegWrite_EX), .BranchType_out(BranchType_EX), .Jump_out(Jump_EX));

  //EX
  wire [31:0] ALU_A, ALU_B, ALUResult_EX;
  wire Zero_EX;
  wire JumpReg_EX = Jump_EX[1];

  Mux32Bit2To1 mux_alua(.out(ALU_A), .inA(RegData1_EX), .inB({27'b0, Shamt_EX}), .sel(ALUSrcA_EX));
  Mux32Bit2To1 mux_alub(.out(ALU_B), .inA(RegData2_EX), .inB(Imm_EX), .sel(ALUSrcB_EX));

  wire [3:0] ALUControl_final = JumpReg_EX ? ALU_PASSA : ALUControl_EX;

  ALU32Bit alu(.ALUControl(ALUControl_final), .A(ALU_A), .B(ALU_B), .ALUResult(ALUResult_EX), .Zero(Zero_EX));

  wire [31:0] BranchTarget_EX = PCPlus4_Ex + (Imm_EX << 2);

  wire [4:0] DestReg_EX = (RegDst_EX == 2'b00) ? Rt_EX : (RegDst_EX == 2'b01) ? Rd_EX : 5'd31;

  //EX_MEM (WIP)
  //MEM    (WIP)
  //MEM_WB  (WIP)
  //WB      (WIP)
  
