/*
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