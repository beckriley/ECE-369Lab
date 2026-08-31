`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369A - Computer Architecture
// Laboratory 
// Module - InstructionMemory_tb.v
// Description - Test the 'InstructionMemory_tb.v' module.
////////////////////////////////////////////////////////////////////////////////

module InstructionMemory_tb(); 

    wire [31:0] Instruction;

    reg [31:0] Address;

	InstructionMemory u0(
		.Address(Address),
        .Instruction(Instruction)
	);

	initial begin
	
    /* Please fill in the implementation here... */
	/* WORK IN PROGRESS */
	Address <= 0;
    #10;
    
    Address <= 1;
    #10;
    
    Address <= 2;
    #10;
    
    Address <= 3;
    #10;
    
    Address <= 4;
    #10;
    
    Address <= 5;
    #10;
    
    Address <= 6;
    #10;
    
    Address <= 7;
    #10;
    
    Address <= 8;
    #10;
    
    Address <= 9;
    #10;
    
    Address <= 10;
    #100;
    
    Address <= 100;
    #100;
    
    Address <= 1000;
    #100;
	
	end

endmodule

