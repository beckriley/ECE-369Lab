`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// Module - DataMemory_tb.v
// Description - Test the 'DataMemory.v' module.
////////////////////////////////////////////////////////////////////////////////

module DataMemory_tb(); 

    reg     [31:0]  Address;
    reg     [31:0]  WriteData;
    reg             Clk;
    reg             MemWrite;
    reg             MemRead;

    wire [31:0] ReadData;

    DataMemory u0(
        .Address(Address), 
        .WriteData(WriteData), 
        .Clk(Clk), 
        .MemWrite(MemWrite), 
        .MemRead(MemRead), 
        .ReadData(ReadData)
    ); 

	initial begin
		Clk <= 1'b0;
		forever #10 Clk <= ~Clk;
	end

	initial begin
	
    /* Please fill in the implementation here... */
		//initialize inputs
		Address = 32'd0;
		WriteData = 32'd0;
		MemWrite = 1'd0;
		MemRead = 1'd0;

		 #5;


        ////////////////////////////////////////////////////////////////
        // Test 1: MemRead = 0
        // ReadData should be 0
        ////////////////////////////////////////////////////////////////
        Address  = 32'd0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;

        #1;

        if (ReadData == 32'd0)
            $display("Test 1 PASS: MemRead = 0 gives ReadData = 0");
        else
            $display("Test 1 FAIL: Expected 0, got %h", ReadData);



		
	
	
	end

endmodule

