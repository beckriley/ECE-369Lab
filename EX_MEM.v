/*
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