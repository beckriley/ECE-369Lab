`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369A - Computer Architecture
// Laboratory 
// Module - TopLevel.v
// Description - Runs the whole operation :)
////////////////////////////////////////////////////////////////////////////////

module TopLevel(Reset, Clk, out7, en_out);

    input Reset, Clk;
    output [6:0] out7;
    output [7:0] en_out;
    
    wire ClkDivOut;
    wire [31:0] Instruction;
    wire [31:0] PCResult;
    
    ClkDiv CD(
        .Clk(Clk),
        .Rst(1'b0),
        .ClkOut(ClkOut)
    );
    
    InstructionFetchUnit IFU (
        .Instruction(Instruction),
        .PCResult(PCResult),
        .Reset(Reset),
        .Clk(ClkOut)
    );
    
    Two4DigitDisplay TDD (
        .Clk(Clk),
        .NumberA(Instruction[15:0]),
        .NumberB(PCResult[15:0]),
        .out7(out7),
        .en_out(en_out)
    );
    
endmodule
