/* Names: Erick Figueroa, Beck Riley, Earl Sangalang
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
module HazardDetection (
    input  wire [31:0] Instruction_ID,

    input  wire [4:0]  DestReg_EX,
    input  wire        RegWrite_EX,

    input  wire [4:0]  DestReg_MEM,
    input  wire        RegWrite_MEM,

    input  wire [4:0]  DestReg_WB,
    input  wire        RegWrite_WB,

    output wire        PCWrite,
    output wire        IF_ID_Write,
    output wire        InsertBubble
);

    // Instruction currently in the ID stage.
    wire [5:0] Opcode_ID = Instruction_ID[31:26];
    wire [5:0] Function_ID = Instruction_ID[5:0];
    wire [4:0] Rs_ID = Instruction_ID[25:21];
    wire [4:0] Rt_ID = Instruction_ID[20:16];

    // Not every instruction reads both source register fields.
    // For example, addi reads rs; sll reads rt; j reads neither.
    reg UsesRs;
    reg UsesRt;

    always @(*) begin
        // Defaults avoid inferred latches and false dependencies.
        UsesRs = 1'b0;
        UsesRt = 1'b0;

        case (Opcode_ID)
            6'b000000: begin // R-type
                case (Function_ID)
                    6'b000000, // sll (reads rt, not rs)
                    6'b000010: // srl (reads rt, not rs)
                        UsesRt = 1'b1;

                    6'b001000: // jr (reads rs, not rt)
                        UsesRs = 1'b1;

                    6'b100000, // add
                    6'b100010, // sub
                    6'b100100, // and
                    6'b100101, // or
                    6'b100110, // xor
                    6'b100111, // nor
                    6'b101010: begin // slt
                        UsesRs = 1'b1;
                        UsesRt = 1'b1;
                    end

                    default: begin
                        UsesRs = 1'b0;
                        UsesRt = 1'b0;
                    end
                endcase
            end

            6'b011100: begin // SPECIAL2: mul
                if (Function_ID == 6'b000010) begin
                    UsesRs = 1'b1;
                    UsesRt = 1'b1;
                end
            end

            6'b001000, // addi
            6'b001010, // slti
            6'b001100, // andi
            6'b001101, // ori
            6'b001110, // xori
            6'b100000, // lb
            6'b100001, // lh
            6'b100011: // lw
                UsesRs = 1'b1;

            6'b101000, // sb
            6'b101001, // sh
            6'b101011, // sw
            6'b000100, // beq
            6'b000101: begin // bne
                UsesRs = 1'b1;
                UsesRt = 1'b1;
            end

            6'b000110, // blez
            6'b000111: // bgtz
                UsesRs = 1'b1;

            6'b000001: begin // REGIMM: bgez and bltz
                if ((Rt_ID == 5'b00001) || (Rt_ID == 5'b00000))
                    UsesRs = 1'b1;
            end

            // j and jal need no register source operands.
            6'b000010, // j
            6'b000011: begin // jal
                UsesRs = 1'b0;
                UsesRt = 1'b0;
            end

            default: begin
                UsesRs = 1'b0;
                UsesRt = 1'b0;
            end
        endcase
    end

    // Ignore destination register 0: architectural $zero has no dependency.
    wire Hazard_EX = RegWrite_EX && (DestReg_EX != 5'd0) &&
                     ((UsesRs && (Rs_ID == DestReg_EX)) ||
                      (UsesRt && (Rt_ID == DestReg_EX)));

    wire Hazard_MEM = RegWrite_MEM && (DestReg_MEM != 5'd0) &&
                      ((UsesRs && (Rs_ID == DestReg_MEM)) ||
                       (UsesRt && (Rt_ID == DestReg_MEM)));

    wire Hazard_WB = RegWrite_WB && (DestReg_WB != 5'd0) &&
                     ((UsesRs && (Rs_ID == DestReg_WB)) ||
                      (UsesRt && (Rt_ID == DestReg_WB)));

    // Stall until none of the older stages is producing a needed operand.
    wire Stall = Hazard_EX || Hazard_MEM || Hazard_WB;

    assign PCWrite      = ~Stall;
    assign IF_ID_Write  = ~Stall;
    assign InsertBubble =  Stall;

endmodule
