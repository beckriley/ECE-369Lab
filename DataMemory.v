`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// Module - data_memory.v
// Description - 32-Bit wide data memory.
//
// INPUTS:-
// Address: 32-Bit address input port.
// WriteData: 32-Bit input port.
// Clk: 1-Bit Input clock signal.
// MemWrite: 1-Bit control signal for memory write.
// MemRead: 1-Bit control signal for memory read.
//
// OUTPUTS:-
// ReadData: 32-Bit registered output port.
//
// FUNCTIONALITY:-
// Design the above memory similar to the 'RegisterFile' model in the previous 
// assignment.  Create a 1K memory, for which we need 10 bits.  In order to 
// implement byte addressing, we will use bits Address[11:2] to index the 
// memory location. The 'WriteData' value is written into the address 
// corresponding to Address[11:2] in the positive clock edge if 'MemWrite' 
// signal is 1. 'ReadData' is the value of memory location Address[11:2] if 
// 'MemRead' is 1, otherwise, it is 0x00000000. The reading of memory is not 
// clocked.
//
// you need to declare a 2d array. in this case we need an array of 1024 (1K)  
// 32-bit elements for the memory.   
// for example,  to declare an array of 256 32-bit elements, declaration is: reg[31:0] memory[0:255]
// if i continue with the same declaration, we need 8 bits to index to one of 256 elements. 
// however , address port for the data memory is 32 bits. from those 32 bits, least significant 2 
// bits help us index to one of the 4 bytes within a single word. therefore we only need bits [9-2] 
// of the "Address" input to index any of the 256 words. 
////////////////////////////////////////////////////////////////////////////////

module DataMemory(Address, WriteData, Clk, MemWrite, MemRead, MemSize, ReadData);
 
    input  [31:0] Address;
    input  [31:0] WriteData;
    input         Clk;
    input         MemWrite;
    input         MemRead;
    input  [1:0]  MemSize;
 
    output reg [31:0] ReadData;
 
    reg [31:0] memory [0:1023];
    integer i;
 
    initial begin
        for (i = 0; i < 1024; i = i + 1)
            memory[i] = 32'b0;
        $readmemh("data_memory.mem", memory);
    end
 
    wire [9:0]  Index = Address[11:2];
    wire [31:0] Word  = memory[Index];
 
    // ---------------- store: merge the new byte / half into the old word ----------------
    reg [31:0] NewWord;
 
    always @(*) begin
        NewWord = Word;
        case (MemSize)
            2'b00: begin      
                case (Address[1:0])
                    2'b00:   NewWord[7:0]   = WriteData[7:0];
                    2'b01:   NewWord[15:8]  = WriteData[7:0];
                    2'b10:   NewWord[23:16] = WriteData[7:0];
                    default: NewWord[31:24] = WriteData[7:0];
                endcase
            end
            2'b01: begin 
                if (Address[1]) NewWord[31:16] = WriteData[15:0];
                else            NewWord[15:0]  = WriteData[15:0];
            end
            default: NewWord = WriteData;
        endcase
    end
 
    always @(posedge Clk) begin
        if (MemWrite)
            memory[Index] <= NewWord;
    end
 
    // ---------------- load: pick the byte / half and sign-extend ----------------
    reg [7:0]  LoadByte;
    reg [15:0] LoadHalf;
 
    always @(*) begin
        case (Address[1:0])
            2'b00:   LoadByte = Word[7:0];
            2'b01:   LoadByte = Word[15:8];
            2'b10:   LoadByte = Word[23:16];
            default: LoadByte = Word[31:24];
        endcase
        LoadHalf = Address[1] ? Word[31:16] : Word[15:0];
 
        if (MemRead) begin
            case (MemSize)
                2'b00:   ReadData = {{24{LoadByte[7]}}, LoadByte};
                2'b01:   ReadData = {{16{LoadHalf[15]}}, LoadHalf};
                default: ReadData = Word;      
            endcase
        end else begin
            ReadData = 32'b0;
        end
    end
 
endmodule
