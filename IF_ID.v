/*
 * IF_ID.v
 *
 * Purpose:
 *   Pipeline register between the Instruction Fetch (IF) stage
 *   and Instruction Decode (ID) stage.
 *
 * Responsibilities:
 *   - Store values produced during the IF stage on the active clock edge.
 *   - Hold those values constant for use by the ID stage.
 *
 * Values that should be stored:
 *   - Current instruction
 *   - Current PC and/or PC + 4 as required by the datapath
 *
 * Inputs:
 *   - Clock
 *   - Reset
 *   - Instruction from Instruction Memory
 *   - PC value
 *
 * Outputs:
 *   - Stored instruction
 *   - Stored PC value
 *
 * Reset behavior:
 *   - Clear stored values to zero when Reset is active.
 *
 * Notes:
 *   - This must be a clocked pipeline register, not combinational wiring.
 */