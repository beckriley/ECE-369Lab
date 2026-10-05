`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// Module - ALU32Bit_tb.v
// Description - Test the 'ALU32Bit.v' module.
////////////////////////////////////////////////////////////////////////////////

module ALU32Bit_tb(); 

	reg [3:0] ALUControl;   // control bits for ALU operation
	reg [31:0] A, B;	        // inputs

	wire [31:0] ALUResult;	// answer
	wire Zero;	        // Zero=1 if ALUResult == 0

    ALU32Bit u0(
        .ALUControl(ALUControl), 
        .A(A), 
        .B(B), 
        .ALUResult(ALUResult), 
        .Zero(Zero)
    );

	initial begin
	
    /* Please fill in the implementation here... */
		A = 32'b0010; B = 32'b0001;

		ALUControl = 4'b0010; // add

		#100;

		A = 32'b1111; B = 32'b0000;

		ALUControl = 4'b0001; // or

		#100;

		ALUControl = 4'b0000; // AND

		#100;

		A = 32'b0101; B = 32'b1111;
		ALUControl = 4'b0011; //XOR

		#100;

		A = 32'b1000; B = 32'b0100;
		ALUControl = 4'b0100; //NOR

		#100;

		A = 32'b1000; B = 32'b0101;
		ALUControl = 4'b0101; //MUL

		#100;
	
	end

endmodule

