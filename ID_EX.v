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