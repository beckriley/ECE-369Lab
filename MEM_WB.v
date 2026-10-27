`timescale 1ns / 1ps
/*beck
 * MEM_WB.v
 *
 * Purpose:
 *   Pipeline register between the Memory Access (MEM) stage
 *   and Write Back (WB) stage.
 *
 * Responsibilities:
 *   - Store values that may be written back into the Register File.
 *   - Carry final write-back control signals.
 *
 * Values that should be stored:
 *   - ALU result
 *   - Data read from Data Memory
 *   - Destination register number
 *   - Other values needed by JAL or special write-back operations
 *
 * Control signals:
 *   - RegWrite
 *   - MemToReg / write-back source selection
 *   - Any additional write-back selection controls
 *
 * Inputs:
 *   - Clock
 *   - Reset
 *   - Memory-stage outputs
 *
 * Outputs:
 *   - Registered values used by the Write Back stage
 *
 * Reset behavior:
 *   - Clear all stored values and control signals when Reset is active.
 */

module MEM_WB(
  input Clock,
  input Reset,
  input [1:0] MemToReg_in,
  input RegWrite_in,
  input [31:0] PCPlus4_in,
  input [31:0] ALUResult_in,
  input [31:0] MemData_in,
  input [4:0] DestReg_in,
 
  output reg [1:0] MemToReg_out,
  output reg RegWrite_out,
  output reg [31:0] PCPlus4_out,
  output reg [31:0] ALUResult_out,
  output reg [31:0] MemData_out,
  output reg [4:0] DestReg_out
);
 
  always @(posedge Clock) begin
    if (Reset) begin
      MemToReg_out <= 2'b0;
      RegWrite_out <= 1'b0;
      PCPlus4_out <= 32'b0;
      ALUResult_out <= 32'b0;
      MemData_out <= 32'b0;
      DestReg_out <= 5'b0;
    end else begin
      MemToReg_out <= MemToReg_in;
      RegWrite_out <= RegWrite_in;
      PCPlus4_out <= PCPlus4_in;
      ALUResult_out <= ALUResult_in;
      MemData_out <= MemData_in;
      DestReg_out <= DestReg_in;
    end
  end
endmodule
