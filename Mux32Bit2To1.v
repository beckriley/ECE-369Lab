`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// Module - Mux32Bit2To1.v
// Description - Performs signal multiplexing between 2 32-Bit words.
////////////////////////////////////////////////////////////////////////////////

module Mux32bit3to1(
    input  [31:0] in0,
    input  [31:0] in1,
    input  [31:0] in2,
    input  [1:0]  sel,
    output reg [31:0] out
);
    always @(*) begin
        case (sel)
            2'b00:   out = in0;
            2'b01:   out = in1;
            2'b10:   out = in2;
            default: out = in0;
        endcase
    end
endmodule

