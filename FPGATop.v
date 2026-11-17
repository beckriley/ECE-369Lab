module FPGATop(Clk, Reset, out7, en_out);

    parameter DIV_VAL = 50000000;
    
    input Clk;
    input Reset; // Raw board push button
    output [6:0] out7;
    output [7:0] en_out;
    
    // --- Debouncer and Synchronizer ---
    reg [19:0] debounce_cnt = 0;
    reg debounced_reset = 1;
    reg [1:0] reset_sync = 2'b11;
    
    always @(posedge Clk) begin
        if (Reset == 1'b1) begin
            debounce_cnt <= 0;
            debounced_reset <= 1'b1;
        end else if (debounce_cnt < 20'hFFFFF) begin
            debounce_cnt <= debounce_cnt + 1;
        end else begin
            debounced_reset <= 1'b0;
        end
        
        reset_sync <= {reset_sync[0], debounced_reset};
    end
    
    wire CleanReset = reset_sync[1];
    // ----------------------------------

    wire SlowClk;
    wire [31:0] PCResult;
    wire [31:0] WriteData;
    
    ClkDiv #(.DivVal(DIV_VAL)) clkdiv(.Clk(Clk), .Rst(CleanReset), .ClkOut(SlowClk));
    
    Top cpu(.Clk(SlowClk), .Reset(CleanReset), .PCResult(PCResult), .WriteData(WriteData));
    
    Two4DigitDisplay disp(.Clk(Clk), .NumberA(WriteData[15:0]), .NumberB(PCResult[15:0]),
                          .out7(out7), .en_out(en_out));

endmodule
