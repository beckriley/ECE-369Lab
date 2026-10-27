`timescale 1ns / 1ps

module Top(Clk, Reset, PCResult, WriteData);

    input         Clk;
    input         Reset;
    output [31:0] PCResult; 
    output [31:0] WriteData;  

    localparam [3:0] ALU_PASSA = 4'b1000;

    // =========================== IF ===========================
    wire [31:0] PC, PCNext, PCAfterJump;
    wire [31:0] PCPlus4_IF = PC + 32'd4;
    wire [31:0] Instruction_IF;
    wire [31:0] JumpTarget_ID, MemTarget;
    wire        MemRedirect;
    wire [1:0]  Jump_ID;
    wire        JumpID = (Jump_ID == 2'b01);

    Mux32Bit2To1 mux_pc_jump(.out(PCAfterJump), .inA(PCPlus4_IF), .inB(JumpTarget_ID), .sel(JumpID));
    Mux32Bit2To1 mux_pc_redirect(.out(PCNext), .inA(PCAfterJump), .inB(MemTarget), .sel(MemRedirect));

    ProgramCounter pc_reg(.Address(PCNext), .PCResult(PC), .Reset(Reset), .Clk(Clk));

    InstructionMemory im(.Address(PC), .Instruction(Instruction_IF));

    // ----------------------- IF/ID -----------------------
    wire [31:0] PCPlus4_ID, Instruction_ID;

    IF_ID ifid(.Clk(Clk), .Reset(Reset),
               .Instruction(Instruction_IF), .PCValue(PCPlus4_IF),
               .StoredInstruction(Instruction_ID), .StoredPCValue(PCPlus4_ID));

    // =========================== ID ===========================
    wire [4:0] Rs_ID    = Instruction_ID[25:21];
    wire [4:0] Rt_ID    = Instruction_ID[20:16];
    wire [4:0] Rd_ID    = Instruction_ID[15:11];
    wire [4:0] Shamt_ID = Instruction_ID[10:6];

    wire [1:0] RegDst_ID, MemSize_ID, MemtoReg_ID;
    wire       ALUSrcA_ID, ALUSrcB_ID, ExtOp_ID, MemRead_ID, MemWrite_ID, RegWrite_ID;
    wire [3:0] ALUControl_ID;
    wire [2:0] BranchType_ID;

    Controller ctrl(.Opcode(Instruction_ID[31:26]), .Function(Instruction_ID[5:0]), .RT(Rt_ID),
                    .RegDst(RegDst_ID), .ALUSrcA(ALUSrcA_ID), .ALUSrcB(ALUSrcB_ID),
                    .ExtOp(ExtOp_ID), .ALUControl(ALUControl_ID),
                    .MemRead(MemRead_ID), .MemWrite(MemWrite_ID), .MemSize(MemSize_ID),
                    .MemtoReg(MemtoReg_ID), .RegWrite(RegWrite_ID),
                    .BranchType(BranchType_ID), .Jump(Jump_ID));

    wire [31:0] SignExt_ID, Imm_ID;
    SignExtension signext(.in(Instruction_ID[15:0]), .out(SignExt_ID));
    Mux32Bit2To1 mux_ext(.out(Imm_ID), .inA(SignExt_ID), .inB({16'b0, Instruction_ID[15:0]}), .sel(ExtOp_ID));

    assign JumpTarget_ID = {PCPlus4_ID[31:28], Instruction_ID[25:0], 2'b00};

    wire [31:0] RegData1_ID, RegData2_ID;
    wire        RegWrite_WB;
    wire [4:0]  DestReg_WB;
    wire [31:0] WB_Data;

    RegisterFile rf(.ReadRegister1(Rs_ID), .ReadRegister2(Rt_ID),
                    .WriteRegister(DestReg_WB), .WriteData(WB_Data), .RegWrite(RegWrite_WB),
                    .Clk(Clk), .ReadData1(RegData1_ID), .ReadData2(RegData2_ID));

    // ----------------------- ID/EX -----------------------
    wire [1:0]  RegDst_EX, MemSize_EX, MemtoReg_EX, Jump_EX;
    wire        ALUSrcA_EX, ALUSrcB_EX, MemRead_EX, MemWrite_EX, RegWrite_EX;
    wire [3:0]  ALUControl_EX;
    wire [2:0]  BranchType_EX;
    wire [31:0] PCPlus4_EX, RegData1_EX, RegData2_EX, Imm_EX;
    wire [4:0]  Rs_EX, Rt_EX, Rd_EX, Shamt_EX;

    ID_EX idex(.Clk(Clk), .Reset(Reset),
        .RegisterData1(RegData1_ID), .RegisterData2(RegData2_ID), .Imm(Imm_ID), .PCValue(PCPlus4_ID),
        .rt(Rt_ID), .rd(Rd_ID), .rs(Rs_ID), .Shamt(Shamt_ID),
        .RegDst(RegDst_ID), .ALUSrcA(ALUSrcA_ID), .ALUSrcB(ALUSrcB_ID), .ALUControl(ALUControl_ID),
        .MemRead(MemRead_ID), .MemWrite(MemWrite_ID), .MemSize(MemSize_ID),
        .MemtoReg(MemtoReg_ID), .RegWrite(RegWrite_ID), .BranchType(BranchType_ID), .Jump(Jump_ID),
        .ReadData1(RegData1_EX), .ReadData2(RegData2_EX), .Imm_out(Imm_EX), .PCValue_out(PCPlus4_EX),
        .rt_out(Rt_EX), .rd_out(Rd_EX), .rs_out(Rs_EX), .Shamt_out(Shamt_EX),
        .RegDst_out(RegDst_EX), .ALUSrcA_out(ALUSrcA_EX), .ALUSrcB_out(ALUSrcB_EX), .ALUControl_out(ALUControl_EX),
        .MemRead_out(MemRead_EX), .MemWrite_out(MemWrite_EX), .MemSize_out(MemSize_EX),
        .MemtoReg_out(MemtoReg_EX), .RegWrite_out(RegWrite_EX), .BranchType_out(BranchType_EX),
        .Jump_out(Jump_EX));

    // =========================== EX ===========================
    wire [31:0] ALU_A, ALU_B, ALUResult_EX;
    wire        Zero_EX;
    wire        JumpReg_EX = Jump_EX[1];               

    Mux32Bit2To1 mux_alua(.out(ALU_A), .inA(RegData1_EX), .inB({27'b0, Shamt_EX}), .sel(ALUSrcA_EX));
    Mux32Bit2To1 mux_alub(.out(ALU_B), .inA(RegData2_EX), .inB(Imm_EX),            .sel(ALUSrcB_EX));

    wire [3:0] ALUControl_final = JumpReg_EX ? ALU_PASSA : ALUControl_EX;

    ALU32Bit alu(.ALUControl(ALUControl_final), .A(ALU_A), .B(ALU_B),
                 .ALUResult(ALUResult_EX), .Zero(Zero_EX));

    wire [31:0] BranchTarget_EX = PCPlus4_EX + (Imm_EX << 2);

    wire [4:0] DestReg_EX = (RegDst_EX == 2'b00) ? Rt_EX :
                            (RegDst_EX == 2'b01) ? Rd_EX : 5'd31;

    // ----------------------- EX/MEM -----------------------
    wire        MemRead_MEM, MemWrite_MEM, JumpReg_MEM, RegWrite_MEM, Zero_MEM;
    wire [1:0]  MemSize_MEM, MemtoReg_MEM;
    wire [2:0]  BranchType_MEM;
    wire [31:0] PCPlus4_MEM, BranchTarget_MEM, ALUResult_MEM, WriteData_MEM;
    wire [4:0]  DestReg_MEM;

    EX_MEM exmem(.Clock(Clk), .Reset(Reset),
        .MemRead_in(MemRead_EX), .MemWrite_in(MemWrite_EX), .MemSize_in(MemSize_EX),
        .BranchType_in(BranchType_EX), .JumpReg_in(JumpReg_EX),
        .MemToReg_in(MemtoReg_EX), .RegWrite_in(RegWrite_EX),
        .PCPlus4_in(PCPlus4_EX), .BranchTarget_in(BranchTarget_EX), .ALUResult_in(ALUResult_EX),
        .Zero_in(Zero_EX), .WriteData_in(RegData2_EX), .DestReg_in(DestReg_EX),
        .MemRead_out(MemRead_MEM), .MemWrite_out(MemWrite_MEM), .MemSize_out(MemSize_MEM),
        .BranchType_out(BranchType_MEM), .JumpReg_out(JumpReg_MEM),
        .MemToReg_out(MemtoReg_MEM), .RegWrite_out(RegWrite_MEM),
        .PCPlus4_out(PCPlus4_MEM), .BranchTarget_out(BranchTarget_MEM), .ALUResult_out(ALUResult_MEM),
        .Zero_out(Zero_MEM), .WriteData_out(WriteData_MEM), .DestReg_out(DestReg_MEM));

    // =========================== MEM ===========================
    wire BranchTaken, TargetSel;

    BranchUnit bu(.BranchType(BranchType_MEM), .JumpReg(JumpReg_MEM),
                  .Zero(Zero_MEM), .Sign(ALUResult_MEM[31]),
                  .BranchTaken(BranchTaken), .MemRedirect(MemRedirect), .TargetSel(TargetSel));

    Mux32Bit2To1 mux_target(.out(MemTarget), .inA(BranchTarget_MEM), .inB(ALUResult_MEM), .sel(TargetSel));

    wire [31:0] MemData_MEM;

    DataMemory dm(.Address(ALUResult_MEM), .WriteData(WriteData_MEM), .Clk(Clk),
                  .MemWrite(MemWrite_MEM), .MemRead(MemRead_MEM), .MemSize(MemSize_MEM),
                  .ReadData(MemData_MEM));

    // ----------------------- MEM/WB -----------------------
    wire [1:0]  MemtoReg_WB;
    wire [31:0] PCPlus4_WB, ALUResult_WB, MemData_WB;

    MEM_WB memwb(.Clock(Clk), .Reset(Reset),
        .MemToReg_in(MemtoReg_MEM), .RegWrite_in(RegWrite_MEM), .PCPlus4_in(PCPlus4_MEM),
        .ALUResult_in(ALUResult_MEM), .MemData_in(MemData_MEM), .DestReg_in(DestReg_MEM),
        .MemToReg_out(MemtoReg_WB), .RegWrite_out(RegWrite_WB), .PCPlus4_out(PCPlus4_WB),
        .ALUResult_out(ALUResult_WB), .MemData_out(MemData_WB), .DestReg_out(DestReg_WB));

    // =========================== WB ===========================
    wire [31:0] WB_ALUorMem;
    Mux32Bit2To1 mux_wb0(.out(WB_ALUorMem), .inA(ALUResult_WB), .inB(MemData_WB), .sel(MemtoReg_WB[0]));
    Mux32Bit2To1 mux_wb1(.out(WB_Data),     .inA(WB_ALUorMem),  .inB(PCPlus4_WB + 32'd4), .sel(MemtoReg_WB[1]));
  
    assign PCResult  = (PCPlus4_WB == 32'd0) ? 32'd0 : (PCPlus4_WB - 32'd4);
    assign WriteData = RegWrite_WB ? WB_Data : 32'd0;

endmodule
