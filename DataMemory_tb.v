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

		 ////////////////////////////////////////////////////////////////
        // Test 2: Write 0x12345678 to address 0
        ////////////////////////////////////////////////////////////////
        Address   = 32'd0;
        WriteData = 32'h12345678;
        MemWrite  = 1'b1;
        MemRead   = 1'b0;

        @(posedge Clk);
        #1;

        MemWrite = 1'b0;


        ////////////////////////////////////////////////////////////////
        // Test 3: Read address 0
        ////////////////////////////////////////////////////////////////
        Address = 32'd0;
        MemRead = 1'b1;

        #1;

        if (ReadData == 32'h12345678)
            $display("Test 3 PASS: Address 0 = 12345678");
        else
            $display("Test 3 FAIL: Expected 12345678, got %h", ReadData);


        ////////////////////////////////////////////////////////////////
        // Test 4: Write 0xABCDEF01 to address 4
        //
        // Address 4 should access memory word 1
        ////////////////////////////////////////////////////////////////
        MemRead   = 1'b0;
        Address   = 32'd4;
        WriteData = 32'hABCDEF01;
        MemWrite  = 1'b1;

        @(posedge Clk);
        #1;

        MemWrite = 1'b0;


        ////////////////////////////////////////////////////////////////
        // Test 5: Read address 4
        ////////////////////////////////////////////////////////////////
        MemRead = 1'b1;
        Address = 32'd4;

        #1;

        if (ReadData == 32'hABCDEF01)
            $display("Test 5 PASS: Address 4 = ABCDEF01");
        else
            $display("Test 5 FAIL: Expected ABCDEF01, got %h", ReadData);


        ////////////////////////////////////////////////////////////////
        // Test 6: Make sure address 0 was not overwritten
        ////////////////////////////////////////////////////////////////
        Address = 32'd0;

        #1;

        if (ReadData == 32'h12345678)
            $display("Test 6 PASS: Address 0 still = 12345678");
        else
            $display("Test 6 FAIL: Address 0 changed, got %h", ReadData);


        ////////////////////////////////////////////////////////////////
        // Test 7: Write and read address 8
        //
        // Address 8 should access memory word 2
        ////////////////////////////////////////////////////////////////
        MemRead   = 1'b0;
        Address   = 32'd8;
        WriteData = 32'hDEADBEEF;
        MemWrite  = 1'b1;

        @(posedge Clk);
        #1;

        MemWrite = 1'b0;
        MemRead  = 1'b1;

        #1;

        if (ReadData == 32'hDEADBEEF)
            $display("Test 7 PASS: Address 8 = DEADBEEF");
        else
            $display("Test 7 FAIL: Expected DEADBEEF, got %h", ReadData);


        ////////////////////////////////////////////////////////////////
        // Test 8: Verify MemWrite = 0 prevents a write
        //
        // Try to overwrite address 8 without MemWrite enabled.
        ////////////////////////////////////////////////////////////////
        MemRead   = 1'b0;
        Address   = 32'd8;
        WriteData = 32'hFFFFFFFF;
        MemWrite  = 1'b0;

        @(posedge Clk);
        #1;

        MemRead = 1'b1;

        #1;

        if (ReadData == 32'hDEADBEEF)
            $display("Test 8 PASS: MemWrite = 0 prevented write");
        else
            $display("Test 8 FAIL: Memory changed to %h", ReadData);


        ////////////////////////////////////////////////////////////////
        // Test 9: Test highest word location in 1K-word memory
        //
        // Address[11:2] = 1023 for address 4092
        ////////////////////////////////////////////////////////////////
        MemRead   = 1'b0;
        Address   = 32'd4092;
        WriteData = 32'hCAFEBABE;
        MemWrite  = 1'b1;

        @(posedge Clk);
        #1;

        MemWrite = 1'b0;
        MemRead  = 1'b1;

        #1;

        if (ReadData == 32'hCAFEBABE)
            $display("Test 9 PASS: Address 4092 = CAFEBABE");
        else
            $display("Test 9 FAIL: Expected CAFEBABE, got %h", ReadData);


        ////////////////////////////////////////////////////////////////
        // Test 10: Disable MemRead again
        ////////////////////////////////////////////////////////////////
        MemRead = 1'b0;

        #1;

        if (ReadData == 32'd0)
            $display("Test 10 PASS: ReadData returned to 0");
        else
            $display("Test 10 FAIL: Expected 0, got %h", ReadData);


        $display("----------------------------------------");
        $display("DataMemory testbench complete.");
        $display("----------------------------------------");

        #10;
        $finish;

		
	
	
	end

endmodule

