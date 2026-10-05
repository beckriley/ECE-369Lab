/*
 * TopLevel.v
 *
 * Purpose:
 *   Implement and connect the complete 5-stage pipelined MIPS datapath
 *   required for ECE369A Lab 4.
 *
 * Pipeline stages:
 *   1. IF  - Instruction Fetch
 *   2. ID  - Instruction Decode
 *   3. EX  - Execute
 *   4. MEM - Memory Access
 *   5. WB  - Write Back
 *
 * Main components instantiated in this module:
 *   - Program Counter
 *   - Instruction Memory
 *   - IF/ID pipeline register
 *   - Controller
 *   - Register File
 *   - Immediate extension logic
 *   - ID/EX pipeline register
 *   - ALU
 *   - ALU input/output selection logic
 *   - Branch target/condition logic
 *   - Jump/JR/JAL logic
 *   - EX/MEM pipeline register
 *   - Data Memory
 *   - MEM/WB pipeline register
 *   - Write-back selection logic
 *
 * Responsibilities:
 *   - Connect all datapath components.
 *   - Calculate PC + 4.
 *   - Select the next PC for:
 *       - Normal sequential execution
 *       - Branches
 *       - Jump
 *       - Jump Register
 *       - Jump and Link
 *   - Select ALU operands.
 *   - Select destination registers.
 *   - Handle sign and zero extension.
 *   - Handle shift amount for sll and srl.
 *   - Pass control signals through pipeline registers.
 *   - Route memory results or ALU results back to the Register File.
 *   - Support all instructions required by the Lab 4 ISA.
 *
 * Required demonstration outputs:
 *   - 32-bit current/instruction PC
 *   - 32-bit value being written to the Register File
 *
 * Important:
 *   These top-level outputs must remain connected so that Vivado does
 *   not optimize away the processor during implementation.
 */
