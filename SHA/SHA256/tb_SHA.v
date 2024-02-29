`timescale 1ns/1ns
module tb_SHA;
    reg Clk;
    reg Rst;
    reg i_fStart;
    reg i_fFirst;
    reg [511:0] i_Data;
    wire [255:0] o_Data;
    wire o_fDone;

    SHA SHA0(Clk, Rst, i_Data, o_Data, i_fStart, i_fFirst, o_fDone);

    always #10 Clk = ~Clk;

    initial 
    begin
        Clk = 1;    
        Rst = 0;
        i_Data 	= 512'h61626380_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000018;
        i_fStart = 0;
        i_fFirst = 0;

        @(negedge Clk) Rst = 1;
        #100  i_fStart = 1; i_fFirst = 1;
        #20   i_fStart = 0; i_fFirst = 0;
        #3000;

        i_Data = 512'h61626364_62636465_63646566_64656667_65666768_66676869_6768696a_68696a6b_696a6b6c_6a6b6c6d_6b6c6d6e_6c6d6e6f_6d6e6f70_6e6f7071_80000000_00000000;
        i_fStart = 1; i_fFirst = 1;
        #20   i_fStart = 0; i_fFirst = 0;
        #3000;

        i_Data = 512'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_000001c0;
        i_fStart = 1; 
        #20   i_fStart = 0;
        #3000;
        $stop;

    end
endmodule