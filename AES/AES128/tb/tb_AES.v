
`timescale 1ns/1ns
module tb_AES;
reg Clk;
    reg Rst;
    reg [127:0] i_Data;
    reg [127:0] i_Key;
    reg i_fDec, i_fStart;

    wire [127:0] o_Data;
    wire o_fDone;

    AES AE(Clk, Rst, i_fStart, i_fDec, i_Data, i_Key, o_Data, o_fDone);

    always #10 Clk = ~Clk;

    initial 
    begin
        Clk = 1;    
        Rst = 0;
        i_Data 	= 128'h54776F204F6E65204E696E652054776F;
        i_Key 	= 128'h5468617473206D79204B756E67204675;
        i_fDec = 0;
        i_fStart = 0;

        @(negedge Clk) Rst = 1;
        #100 i_fStart = 1; #20 i_fStart = 0;
        #1500;

		Rst = 0;
		@(negedge Clk) Rst = 1;
		#100;

        i_Data = 128'h29C3505F571420F6402299B31A02D73A;
        i_fDec = 1;
        #100 i_fStart = 1; #20 i_fStart = 0;
        #1500;

        Rst = 0;
        @(negedge Clk) Rst = 1;
        i_Data = 128'h00112233445566778899aabbccddeeff;
        i_Key  = 128'h000102030405060708090a0b0c0d0e0f;
        i_fDec = 0;
        #100 i_fStart = 1; #20 i_fStart = 0;
        #1500;

        Rst = 0;
		@(negedge Clk) Rst = 1;
        i_Data = 128'h69c4e0d86a7b0430d8cdb78070b4c55a;
        i_fDec = 1;
        #100 i_fStart = 1; #20 i_fStart = 0;
        #1500;


    end
endmodule