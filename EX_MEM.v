`timescale 1ns / 1ps
/*beck
 * EX_MEM.v
 *
 * Purpose:
 *   Pipeline register between the Execute (EX) stage
 *   and Memory Access (MEM) stage.
 *
 * Responsibilities:
 *   - Store results calculated during the Execute stage.
 *   - Pass memory and write-back control signals to later stages.
 *
 * Values that may need to be stored:
 *   - ALU result
 *   - Register Read Data 2 / store data
 *   - Branch target address
 *   - Branch comparison/result information
 *   - Destination register number
 *   - PC information if required
 *
 * Control signals:
 *   - Memory read/write controls
 *   - Memory access size controls
 *   - Branch controls
 *   - Register write control
 *   - MemToReg / write-back controls
 *
 * Inputs:
 *   - Clock
 *   - Reset
 *   - Execute-stage outputs and control signals
 *
 * Outputs:
 *   - Registered values for the Memory stage
 *
 * Reset behavior:
 *   - Clear stored values and control signals when Reset is active.
 */

module EX_MEM(
  input Clock,
  input Reset,
  input MemRead_in,
  input MemWrite_in,
  input [1:0] MemSize_in,
  input [2:0] BranchType_in,
  input JumpReg_in,
  input [1:0] MemToReg_in,
  input RegWrite_in,
  input [31:0] PCPlus4_in,
  input [31:0] BranchTarget_in,
  input [31:0] ALUResult_in,
  input Zero_in,
  input [31:0] WriteData_in,
  input [4:0] DestReg_in,

  output MemRead_out,
  output MemWrite_out,
  output [1:0] MemSize_out,
  output [2:0] BranchType_out,
  output JumpReg_out,
  output [1:0] MemToReg_out,
  output RegWrite_out,
  output [31:0] PCPlus4_out,
  output [31:0] BranchTarget_out,
  output [31:0] ALUResult_out,
  output Zero_out,
  output [31:0] WriteData_out,
  output [4:0] DestReg_out
);

  always @(posedge Clock) begin
    if (Reset)
      MemRead_out <= 0;
      MemWrite_out <= 0;
      MemSize_out <= 2'b0;
      BranchType_out <= 3'b0;
      JumpReg_out <= 0;
      MemToReg_out <= 2'b0;
      RegWrite_out <= 0;
      PCPlus4_out <= 32'b0;
      BranchTarget_out <= 32'b0;
      ALUResult_out <= 32'b0;
      Zero_out <= 0;
      WriteData_out <= 32'b0;
      DestReg_out <= 5'b0;
    else
      MemRead_out <= MemRead_in;
      MemWrite_out <= MemWrite_in;
      MemSize_out <= MemSize_in;
      BranchType_out <= BranchType_in;
      JumpReg_out <= JumpReg_in;
      MemToReg_out <= MemToReg_in;
      RegWrite_out <= RegWrite_in;
      PCPlus4_out <= PCPlus4_in;
      BranchTarget_out <= BranchTarget_in;
      ALUResult_out <= ALUResult_in;
      Zero_out <= Zero_in;
      WriteData_out <= WriteData_in;
      DestReg_out <= DestReg_in;
  end
endmodule
  
