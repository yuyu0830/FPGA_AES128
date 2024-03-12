`timescale 1ns/1ns
module tb_KG;
    reg Clk, Rst, fStart;
    reg [127:0] Key;
    reg [3:0] Round;
    wire [63:0] o_Key;

    KeyGenerator KG0(Clk, Rst, fStart, Key, Round, o_Key);

    always #10 Clk = ~Clk;

    initial 
    begin
        Clk = 1;    
        Rst = 0;
        Key    = 128'h00000000_00000000_00000000_00000000;
        fStart = 0;
        Round = 0;

        @(negedge Clk) Rst = 1;
        #10  fStart = 1;
        #20  fStart = 0;
        #20 Round = Round + 1;
        #20 Round = Round + 1;
        #20 Round = Round + 1;
        #20 Round = Round + 1;
        #20 Round = Round + 1;
        #20 Round = Round + 1;
        #20 Round = Round + 1;
        #20 Round = Round + 1;
        #20 Round = Round + 1;
        #20 Round = Round + 1;
        #20 Round = Round + 1;
        #20 Round = Round + 1;
        #20 Round = Round + 1;
        #20 Round = Round + 1;
        #20 Round = Round + 1;
        
        $stop;

    end
endmodule