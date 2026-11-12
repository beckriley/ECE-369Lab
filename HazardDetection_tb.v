`timescale 1ns / 1ps

/*
 * HazardDetection_tb.v
 * ECE 369A - Lab 6
 *
 * Standalone self-checking testbench for HazardDetection.v.
 * No clock is needed: the hazard detector is purely combinational.
 *
 * Expected outputs:
 *   Hazard found    -> PCWrite=0, IF_ID_Write=0, InsertBubble=1
 *   No hazard found -> PCWrite=1, IF_ID_Write=1, InsertBubble=0
 *
 * Run this file as the SIMULATION TOP along with HazardDetection.v.
 * The final bgezal test is expected to FAIL with the current
 * HazardDetection.v because opcode 000001 / rt 10001 is not decoded.
 * That test is intentional: it identifies a missing instruction case.
 */
module HazardDetection_tb;

    reg  [31:0] Instruction_ID;
    reg  [4:0]  DestReg_EX, DestReg_MEM, DestReg_WB;
    reg         RegWrite_EX, RegWrite_MEM, RegWrite_WB;
    wire        PCWrite, IF_ID_Write, InsertBubble;

    integer tests_run;
    integer tests_failed;

    HazardDetection dut (
        .Instruction_ID(Instruction_ID),
        .DestReg_EX(DestReg_EX),
        .RegWrite_EX(RegWrite_EX),
        .DestReg_MEM(DestReg_MEM),
        .RegWrite_MEM(RegWrite_MEM),
        .DestReg_WB(DestReg_WB),
        .RegWrite_WB(RegWrite_WB),
        .PCWrite(PCWrite),
        .IF_ID_Write(IF_ID_Write),
        .InsertBubble(InsertBubble)
    );

    // MIPS instruction encoders. These keep each test readable.
    function [31:0] RType;
        input [4:0] rs, rt, rd, shamt;
        input [5:0] funct;
        begin
            RType = {6'b000000, rs, rt, rd, shamt, funct};
        end
    endfunction

    function [31:0] IType;
        input [5:0] opcode;
        input [4:0] rs, rt;
        input [15:0] imm;
        begin
            IType = {opcode, rs, rt, imm};
        end
    endfunction

    function [31:0] JType;
        input [5:0] opcode;
        input [25:0] target;
        begin
            JType = {opcode, target};
        end
    endfunction

    // write_flags[2]=EX, [1]=MEM, [0]=WB
    task Check;
        input [8*64-1:0] description;
        input [31:0] instruction;
        input [4:0] ex_dest, mem_dest, wb_dest;
        input [2:0] write_flags;
        input expected_stall;
        begin
            Instruction_ID = instruction;
            DestReg_EX = ex_dest;
            DestReg_MEM = mem_dest;
            DestReg_WB = wb_dest;
            {RegWrite_EX, RegWrite_MEM, RegWrite_WB} = write_flags;
            #2; // Allow combinational outputs to settle.
            tests_run = tests_run + 1;

            if ((PCWrite      !== !expected_stall) ||
                (IF_ID_Write  !== !expected_stall) ||
                (InsertBubble !==  expected_stall)) begin
                tests_failed = tests_failed + 1;
                $display("FAIL %0d: %0s", tests_run, description);
                $display("     instruction=%h EX=%0d/%b MEM=%0d/%b WB=%0d/%b",
                         Instruction_ID, DestReg_EX, RegWrite_EX,
                         DestReg_MEM, RegWrite_MEM, DestReg_WB, RegWrite_WB);
                $display("     expected PCWrite/IF_ID_Write/InsertBubble = %b/%b/%b",
                         !expected_stall, !expected_stall, expected_stall);
                $display("     actual   PCWrite/IF_ID_Write/InsertBubble = %b/%b/%b",
                         PCWrite, IF_ID_Write, InsertBubble);
            end else begin
                $display("PASS %0d: %0s", tests_run, description);
            end
        end
    endtask

    initial begin
        tests_run = 0;
        tests_failed = 0;

        // Initialize all inputs. Vivado can display these signals in its waveform viewer.
        Instruction_ID = 32'b0;
        DestReg_EX = 5'd0;
        DestReg_MEM = 5'd0;
        DestReg_WB = 5'd0;
        RegWrite_EX = 1'b0;
        RegWrite_MEM = 1'b0;
        RegWrite_WB = 1'b0;

        $display("\n=== Basic behavior / R-type ALU dependencies ===");
        // add $8, $9, $10   (reads $9 and $10; writes $8)
        Check("No older register writes: run", RType(5'd9,5'd10,5'd8,5'd0,6'h20),
              5'd9,5'd10,5'd0, 3'b000, 1'b0);
        Check("ADD reads rs from EX: stall", RType(5'd9,5'd10,5'd8,5'd0,6'h20),
              5'd9,5'd0,5'd0, 3'b100, 1'b1);
        Check("ADD reads rt from EX: stall", RType(5'd9,5'd10,5'd8,5'd0,6'h20),
              5'd10,5'd0,5'd0, 3'b100, 1'b1);
        Check("SUB reads rs from MEM: stall", RType(5'd9,5'd10,5'd8,5'd0,6'h22),
              5'd0,5'd9,5'd0, 3'b010, 1'b1);
        Check("SUB reads rt from WB: stall", RType(5'd9,5'd10,5'd8,5'd0,6'h22),
              5'd0,5'd0,5'd10, 3'b001, 1'b1);
        Check("Different destination: run", RType(5'd9,5'd10,5'd8,5'd0,6'h20),
              5'd11,5'd12,5'd13, 3'b111, 1'b0);
        Check("Destination match but RegWrite=0: run", RType(5'd9,5'd10,5'd8,5'd0,6'h20),
              5'd9,5'd10,5'd9, 3'b000, 1'b0);
        Check("Destination $zero must be ignored", RType(5'd0,5'd10,5'd8,5'd0,6'h20),
              5'd0,5'd0,5'd0, 3'b111, 1'b0);
        Check("Two older producers both match: stall", RType(5'd9,5'd10,5'd8,5'd0,6'h20),
              5'd9,5'd10,5'd0, 3'b110, 1'b1);
        Check("Bitwise XOR has rt dependency", RType(5'd9,5'd10,5'd8,5'd0,6'h26),
              5'd10,5'd0,5'd0, 3'b100, 1'b1);
        Check("SLT has rs dependency", RType(5'd9,5'd10,5'd8,5'd0,6'h2a),
              5'd9,5'd0,5'd0, 3'b100, 1'b1);
        // SPECIAL2 mul (opcode 011100; funct 000010).
        Check("MUL has rt dependency", {6'h1c,5'd9,5'd10,5'd8,5'd0,6'h02},
              5'd10,5'd0,5'd0, 3'b100, 1'b1);

        $display("\n=== Immediate ALU / loads ===");
        // addi $10, $9, 3; $10 is DESTINATION, not a source.
        Check("ADDI reads rs: stall", IType(6'h08,5'd9,5'd10,16'd3),
              5'd9,5'd0,5'd0, 3'b100, 1'b1);
        Check("ADDI does not read rt: run", IType(6'h08,5'd9,5'd10,16'd3),
              5'd10,5'd0,5'd0, 3'b100, 1'b0);
        Check("ANDI reads rs: stall", IType(6'h0c,5'd9,5'd10,16'h00ff),
              5'd0,5'd9,5'd0, 3'b010, 1'b1);
        Check("ORI reads rs: stall", IType(6'h0d,5'd9,5'd10,16'h00ff),
              5'd0,5'd0,5'd9, 3'b001, 1'b1);
        Check("XORI reads rs: stall", IType(6'h0e,5'd9,5'd10,16'h00ff),
              5'd9,5'd0,5'd0, 3'b100, 1'b1);
        Check("SLTI reads rs: stall", IType(6'h0a,5'd9,5'd10,16'd3),
              5'd0,5'd9,5'd0, 3'b010, 1'b1);
        Check("LW base rs dependency: stall", IType(6'h23,5'd9,5'd10,16'd4),
              5'd9,5'd0,5'd0, 3'b100, 1'b1);
        Check("LW does not read rt: run", IType(6'h23,5'd9,5'd10,16'd4),
              5'd10,5'd0,5'd0, 3'b100, 1'b0);
        Check("LB base rs dependency", IType(6'h20,5'd9,5'd10,16'd4),
              5'd0,5'd9,5'd0, 3'b010, 1'b1);
        Check("LH base rs dependency", IType(6'h21,5'd9,5'd10,16'd4),
              5'd0,5'd0,5'd9, 3'b001, 1'b1);

        $display("\n=== Store and shift dependencies ===");
        // sw $10, 4($9): rs is address base, rt is value to store.
        Check("SW base rs dependency", IType(6'h2b,5'd9,5'd10,16'd4),
              5'd9,5'd0,5'd0, 3'b100, 1'b1);
        Check("SW store-data rt dependency", IType(6'h2b,5'd9,5'd10,16'd4),
              5'd0,5'd10,5'd0, 3'b010, 1'b1);
        Check("SB store-data rt dependency", IType(6'h28,5'd9,5'd10,16'd4),
              5'd0,5'd0,5'd10, 3'b001, 1'b1);
        Check("SH base rs dependency", IType(6'h29,5'd9,5'd10,16'd4),
              5'd9,5'd0,5'd0, 3'b100, 1'b1);
        // sll $8, $10, 3 reads ONLY $10.
        Check("SLL rt dependency", RType(5'd0,5'd10,5'd8,5'd3,6'h00),
              5'd10,5'd0,5'd0, 3'b100, 1'b1);
        Check("SRL rt dependency", RType(5'd0,5'd10,5'd8,5'd2,6'h02),
              5'd0,5'd10,5'd0, 3'b010, 1'b1);
        Check("SLL does not read rs field", RType(5'd9,5'd10,5'd8,5'd3,6'h00),
              5'd9,5'd0,5'd0, 3'b100, 1'b0);

        $display("\n=== Branches, jumps, and NOP ===");
        Check("BEQ reads rs", IType(6'h04,5'd9,5'd10,16'd2),
              5'd9,5'd0,5'd0, 3'b100, 1'b1);
        Check("BEQ reads rt", IType(6'h04,5'd9,5'd10,16'd2),
              5'd10,5'd0,5'd0, 3'b100, 1'b1);
        Check("BNE reads rt", IType(6'h05,5'd9,5'd10,16'd2),
              5'd0,5'd10,5'd0, 3'b010, 1'b1);
        Check("BGTZ reads rs", IType(6'h07,5'd9,5'd0,16'd2),
              5'd0,5'd0,5'd9, 3'b001, 1'b1);
        Check("BLEZ reads rs", IType(6'h06,5'd9,5'd0,16'd2),
              5'd9,5'd0,5'd0, 3'b100, 1'b1);
        Check("BGEZ reads rs", IType(6'h01,5'd9,5'd1,16'd2),
              5'd0,5'd9,5'd0, 3'b010, 1'b1);
        Check("BLTZ reads rs", IType(6'h01,5'd9,5'd0,16'd2),
              5'd0,5'd0,5'd9, 3'b001, 1'b1);
        Check("JR reads rs", RType(5'd9,5'd0,5'd0,5'd0,6'h08),
              5'd9,5'd0,5'd0, 3'b100, 1'b1);
        Check("J needs no source registers", JType(6'h02,{5'd9,5'd10,16'h1234}),
              5'd9,5'd10,5'd11, 3'b111, 1'b0);
        Check("JAL needs no source registers", JType(6'h03,{5'd9,5'd10,16'h1234}),
              5'd9,5'd10,5'd11, 3'b111, 1'b0);
        Check("NOP never stalls", 32'h00000000,
              5'd9,5'd10,5'd11, 3'b111, 1'b0);
        Check("LUI has no source dependencies", IType(6'h0f,5'd0,5'd10,16'h1234),
              5'd0,5'd10,5'd0, 3'b111, 1'b0);

        $display("\n=== Dependency moves EX -> MEM -> WB -> cleared ===");
        Check("Dependent ADDI: producer in EX", IType(6'h08,5'd9,5'd10,16'd1),
              5'd9,5'd0,5'd0, 3'b100, 1'b1);
        Check("Dependent ADDI: producer in MEM", IType(6'h08,5'd9,5'd10,16'd1),
              5'd0,5'd9,5'd0, 3'b010, 1'b1);
        Check("Dependent ADDI: producer in WB", IType(6'h08,5'd9,5'd10,16'd1),
              5'd0,5'd0,5'd9, 3'b001, 1'b1);
        Check("Dependent ADDI: producer completed", IType(6'h08,5'd9,5'd10,16'd1),
              5'd0,5'd0,5'd0, 3'b000, 1'b0);

        $display("\n=== Additional Lab 4-5 coverage check ===");
        // This test WILL FAIL with the current HazardDetection.v.
        // To support bgezal, recognize REGIMM rt=5'b10001 as using rs.
        // Controller.v and branch/link control must also support bgezal.
        Check("BGEZAL reads rs (missing in current DUT)", IType(6'h01,5'd9,5'b10001,16'd2),
              5'd9,5'd0,5'd0, 3'b100, 1'b1);

        $display("\n=========================================");
        $display("Tests run: %0d   Passed: %0d   Failed: %0d",
                 tests_run, tests_run - tests_failed, tests_failed);
        if (tests_failed == 0)
            $display("RESULT: ALL HAZARD DETECTION TESTS PASSED");
        else
            $display("RESULT: TESTS FAILED - see details above");
        $display("=========================================\n");
        $finish;
    end

endmodule
