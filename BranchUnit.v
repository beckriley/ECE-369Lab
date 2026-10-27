`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// Branch unit (MEM stage)
//   The ALU already produced the compare result in EX:
//     beq/bne                   : ALU did rs - rt, so Zero means "equal"
//     bgez/bgtz/blez/bltz       : ALU passed rs through, so Zero means rs == 0
//                                 and Sign (ALUResult[31]) means rs < 0
//   jr: ALU passed rs through, so the jump target is the ALU result.
//   TargetSel: 0 = branch target from EX/MEM, 1 = ALU result (jr)
// -----------------------------------------------------------------------------
module BranchUnit(
    input  [2:0] BranchType,
    input        JumpReg,
    input        Zero,
    input        Sign,
    output reg   BranchTaken,
    output       MemRedirect,
    output       TargetSel
);
    always @(*) begin
        case (BranchType)
            3'b001:  BranchTaken = Zero;            // beq
            3'b010:  BranchTaken = ~Zero;           // bne
            3'b011:  BranchTaken = ~Sign;           // bgez
            3'b100:  BranchTaken = ~Sign & ~Zero;   // bgtz
            3'b101:  BranchTaken = Sign | Zero;     // blez
            3'b110:  BranchTaken = Sign;            // bltz
            default: BranchTaken = 1'b0;
        endcase
    end

    assign MemRedirect = BranchTaken | JumpReg;
    assign TargetSel   = JumpReg;
endmodule
