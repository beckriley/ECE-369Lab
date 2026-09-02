`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369A - Computer Architecture
// Laboratory 
// Module - InstructionFetchUnit_tb.v
// Description - Test the 'InstructionFetchUnit_tb.v' module.
////////////////////////////////////////////////////////////////////////////////

module InstructionFetchUnit_tb(); 

    wire [31:0] Instruction;
    wire [31:0] PCResult;

    reg Reset, Clk;

	InstructionFetchUnit u1(
        .Instruction(Instruction),
        .PCResult(PCResult),
        .Reset(Reset),
        .Clk(Clk)
	);

    initial begin
        Clk = 0;
        forever #5 Clk = ~Clk;
    end
        
	initial begin
        Reset = 1;
        #100;
        Reset = 0;
        #300;
	end

endmodule
