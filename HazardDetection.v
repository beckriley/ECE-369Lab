/*
 * LAB 6 Percent Effort: 33% each
 *
 *
 *
 * HazardDetection.v
 *
 * Purpose:
 *   Detect data hazards in the pipelined MIPS processor and automatically
 *   stall the pipeline when an instruction depends on a result that is
 *   not yet available.
 *
 * Responsibilities:
 *   - Examine the source registers (rs and rt) of the instruction
 *     currently in the Instruction Decode (ID) stage.
 *
 *   - Compare these registers against the destination registers of
 *     instructions in later pipeline stages (EX, MEM, and WB as needed).
 *
 *   - Determine whether a dependency exists by checking the register
 *     addresses, RegWrite signals, and which source registers are
 *     actually used by the current instruction.
 *
 *   - Generate control signals to stall the pipeline when a hazard
 *     is detected:
 *       - PCWrite = 0: Prevent the Program Counter from advancing.
 *       - IF_ID_Write = 0: Keep the current instruction in ID.
 *       - InsertBubble = 1: Insert a NOP into the EX stage by
 *         disabling control signals that modify processor state.
 *
 *   - Allow normal pipeline execution when no hazard is detected.
 *
 *   - Handle dependencies involving arithmetic, logical, load,
 *     store, shift, branch, and jump instructions as applicable.
 *
 *   - Ignore dependencies involving register $zero, since it
 *     always contains the value zero.
 *
 * Goal:
 *   Allow the processor to execute the Lab 4-5 instruction set
 *   without requiring manually inserted NOP instructions.
 *   The hazard detection unit should prevent incorrect register
 *   values, memory operations, and instruction execution caused
 *   by unresolved dependencies.
 *
 * Notes:
 *   - This module will be connected to TopLevel.v.
 *   - ProgramCounter.v and IF_ID.v must support stalling.
 *   - ID_EX.v must support bubble insertion.
 *   - Branch flushing and control hazards must also be handled
 *     by the overall datapath.
 *   - The exact stall conditions depend on register-file timing
 *     and any forwarding logic implemented in the processor.
 */
