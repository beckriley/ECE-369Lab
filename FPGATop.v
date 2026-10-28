`timescale 1ns / 1ps



module FPGATop(Clk, Reset, out7, en_out);

    parameter DIV_VAL = 50000000;
    
    input Clk;
    input Reset;
    output [6:0] out7;
    output [7:0] en_out;
    
    wire SlowClk;
    wire [31:0] PCResult;
    wire [31:0] WriteData;
    
    ClkDiv #(.DivVal(DIV_VAL)) clkdiv(.Clk(Clk), .Rst(Reset), .ClkOut(SlowClk));
    
    Top cpu(.Clk(SlowClk), .Reset(Reset), .PCResult(PCResult), .WriteData(WriteData));
    
    Two4DigitDisplay disp(.Clk(Clk), .NumberA(WriteData[15:0]), .NumberB(PCResult[15:0]),
    .out7(out7), .en_out(en_out));
    
    
endmodule
