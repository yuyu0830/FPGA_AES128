
`timescale 1ns/1ns
module tb_SHA;
    reg Clk;
    reg Rst;
    reg i_fStart;
    reg [511:0] i_Data;
    wire [255:0] o_Data;
    wire o_fDone;

    SHA SHA0(Clk, Rst, i_Data, o_Data, i_fStart, o_fDone);

    always #10 Clk = ~Clk;

    initial 
    begin
        Clk = 1;    
        Rst = 0;
        i_Data 	= 512'h61626380_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000018;
        i_fStart = 0;

        @(negedge Clk) Rst = 1;
        #100 i_fStart = 1; #20 i_fStart = 0;
        #3000;

    end
endmodule