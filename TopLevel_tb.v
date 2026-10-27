`timescale 1ns / 1ps

// Instruction: addi $8,$0,5   (machine code 0x20080005)

module TopLevel_tb;

    reg Clk, Reset;
    wire [31:0] PCResult, WriteData;
    integer i, cycle, fails;

    Top dut(.Clk(Clk), .Reset(Reset), .PCResult(PCResult), .WriteData(WriteData));

    initial Clk = 0;
    always #5 Clk = ~Clk;

    initial begin
        fails = 0;
        cycle = -1;
        Reset = 1;

        #1;
        for (i = 0; i < 128; i = i + 1)
            dut.im.memory[i] = 32'h00000000;
        dut.im.memory[0] = 32'h20080005;        

        repeat (4) @(posedge Clk);     
        #1 Reset = 0;
        cycle = 1;      

        repeat (10) @(posedge Clk);
        #2;

        if (dut.rf.registers[8] !== 32'd5) begin
            fails = fails + 1;
            $display("FAIL  $8 = %0d, want 5", dut.rf.registers[8]);
        end
        for (i = 0; i < 32; i = i + 1)
            if (i != 8 && dut.rf.registers[i] !== 32'd0) begin
                fails = fails + 1;
                $display("FAIL  $%0d changed to %0d (should still be 0)", i, dut.rf.registers[i]);
            end
        if (dut.dm.memory[0] !== 32'd0) begin
            fails = fails + 1;
            $display("FAIL  data memory was written");
        end

        if (fails == 0) $display("SINGLE INSTRUCTION: PASSED ($8 = 5, nothing else changed)");
        else            $display("SINGLE INSTRUCTION: %0d CHECKS FAILED", fails);
        $finish;
    end

    always @(posedge Clk) begin
        if (!Reset && cycle >= 1 && cycle <= 8) begin
            #1;
            $display("cycle %0d | PC=%h | ID instr=%h | EX: RegWrite=%b dest=%0d | MEM: ALU=%0d | WB: RegWrite=%b dest=%0d data=%0d",
                     cycle, PCResult, dut.Instruction_ID, dut.RegWrite_EX, dut.DestReg_EX,
                     dut.ALUResult_MEM, dut.RegWrite_WB, dut.DestReg_WB, WriteData);
            cycle = cycle + 1;
        end
    end

endmodule
