/*
 * Controller.v
 *
 * Purpose:
 *   Decode the current MIPS instruction and generate all control signals
 *   needed by the pipelined datapath.
 *
 * Responsibilities:
 *   - Examine the instruction opcode and, when necessary, function code.
 *   - Determine which type of instruction is being executed.
 *   - Generate control signals for:
 *       - Register write enable
 *       - Register destination selection
 *       - ALU input selection
 *       - ALU operation
 *       - Memory read/write
 *       - Memory-to-register selection
 *       - Branch instructions
 *       - Jump instructions
 *       - Immediate sign/zero extension
 *       - Byte, halfword, and word memory operations
 *       - JAL/JR and other special instructions as needed
 *
 *   - Support all required Lab 4 instructions:
 *       add, addi, sub, mul
 *       and, andi, or, ori, nor, xor, xori
 *       sll, srl, slt, slti
 *       lw, sw, lb, lh, sb, sh
 *       beq, bne, bgez, bgtz, blez, bltz
 *       j, jr, jal
 *
 * Notes:
 *   - The controller itself should generally be combinational.
 *   - Give control signals default values to avoid inferred latches.
 *   - Control signals generated here will be passed through the
 *     appropriate pipeline registers.
 */