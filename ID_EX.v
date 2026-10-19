`timescale 1ns / 1ps

/*
 * ID_EX.v
 *
 * Purpose:
 *   Pipeline register between the Instruction Decode (ID) stage
 *   and Execute (EX) stage.
 *
 * Responsibilities:
 *   - Store decoded data and control signals needed by later stages.
 *   - Keep the instruction's data and control signals synchronized
 *     as they move through the pipeline.
 *
 * Values that may need to be stored:
 *   - Register Read Data 1
 *   - Register Read Data 2
 *   - Sign-extended or zero-extended immediate
 *   - PC / PC + 4
 *   - Rt register number
 *   - Rd register number
 *   - Rs register number if needed
 *   - Shift amount (shamt) for sll/srl
 *   - Function code or other instruction fields if needed
 *
 * Control signals:
 *   - EX-stage control signals
 *   - MEM-stage control signals
 *   - WB-stage control signals
 *
 * Inputs:
 *   - Clock
 *   - Reset
 *   - Data/control values generated during Decode
 *
 * Outputs:
 *   - Registered data/control values for Execute
 *
 * Reset behavior:
 *   - Clear all stored data and control signals when Reset is active.
 */

module ID_EX(Clk, Reset, RegisterData1, RegisterData2, Imm, PCValue, rt, rd, rs, Shamt,
             RegDst, ALUSrcA, ALUSrcB, ALUControl, MemRead, MemWrite, MemSize,
             MemtoReg, RegWrite, BranchType, Jump,
             ReadData1, ReadData2, Imm_out, PCValue_out, rt_out, rd_out, rs_out, Shamt_out,
             RegDst_out, ALUSrcA_out, ALUSrcB_out, ALUControl_out, MemRead_out, MemWrite_out,
             MemSize_out, MemtoReg_out, RegWrite_out, BranchType_out, Jump_out);

    input Clk;
    input Reset;
    input [31:0] RegisterData1;
    input [31:0] RegisterData2;
    input [31:0] Imm;
    input [31:0] PCValue;
    input [4:0] rt;
    input [4:0] rd;
    input [4:0] rs;
    input [4:0] Shamt;
    
    input [1:0] RegDst;
    input ALUSrcA;
    input ALUSrcB;
    input [3:0] ALUControl;
    input MemRead;
    input MemWrite;
    input [1:0] MemSize;
    input [1:0] MemtoReg;
    input RegWrite;
    input [2:0] BranchType;
    input [1:0] Jump;

    output reg [31:0] ReadData1;
    output reg [31:0] ReadData2;
    output reg [31:0] Imm_out;
    output reg [31:0] PCValue_out;
    output reg [4:0] rt_out;
    output reg [4:0] rd_out;
    output reg [4:0] rs_out;
    output reg [4:0] Shamt_out;
    
    output reg [1:0] RegDst_out;
    output reg ALUSrcA_out;
    output reg ALUSrcB_out;
    output reg [3:0] ALUControl_out;
    output reg MemRead_out;
    output reg MemWrite_out;
    output reg [1:0] MemSize_out;
    output reg [1:0] MemtoReg_out;
    output reg RegWrite_out;
    output reg [2:0] BranchType_out;
    output reg [1:0] Jump_out;

    always @(posedge Clk) begin
        if (Reset) begin
            PCValue_out <= 32'b0;
            ReadData1 <= 32'b0;
            ReadData2 <= 32'b0;
            Imm_out <= 32'b0;
            rs_out <= 5'b0;
            rt_out <= 5'b0;
            rd_out <= 5'b0;
            Shamt_out <= 5'b0;
            ALUControl_out <= 4'b0;
            ALUSrcA_out <= 1'b0;
            ALUSrcB_out <= 1'b0;
            RegDst_out <= 2'b0;
            BranchType_out <= 3'b0;
            Jump_out <= 2'b0;
            MemRead_out <= 1'b0;
            MemWrite_out <= 1'b0;
            MemSize_out <= 2'b0;
            RegWrite_out <= 1'b0;
            MemtoReg_out <= 2'b0;
        end

        else begin
            PCValue_out <= PCValue;
            ReadData1 <= RegisterData1;
            ReadData2 <= RegisterData2;
            Imm_out <= Imm;
            rs_out <= rs;
            rt_out <= rt;
            rd_out <= rd;
            Shamt_out <= Shamt;
            ALUControl_out <= ALUControl;
            ALUSrcA_out <= ALUSrcA;
            ALUSrcB_out <= ALUSrcB;
            RegDst_out <= RegDst;
            BranchType_out <= BranchType;
            Jump_out <= Jump;
            MemRead_out <= MemRead;
            MemWrite_out <= MemWrite;
            MemSize_out <= MemSize;
            RegWrite_out <= RegWrite;
            MemtoReg_out <= MemtoReg;
        end
    end

endmodule
