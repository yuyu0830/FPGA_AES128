`timescale 1ns/1ns
module tb_Crypto();
    reg Clk;
    reg Rst;
    reg [127:0] i_Data;
    reg [1407:0] i_Key;
    reg i_fEncrypt, i_fStart;

    wire [127:0] o_Data;
    wire o_fDone;

    Crypto CP(Clk, Rst, i_Data, i_Key, i_fEncrypt, i_fStart, o_Data, o_fDone);

    always #10 Clk = ~Clk;

    initial 
    begin
        Clk = 1;    
        Rst = 0;
        i_Data = 128'h54776F204F6E65204E696E652054776F;
        i_Key = 1408'h5468617473206D79204B756E67204675E232FCF191129188B159E4E6D679A29356082007C71AB18F76435569A03AF7FAD2600DE7157ABC686339E901C3031EFBA11202C9B468BEA1D75157A01452495BB1293B3305418592D210D232C6429B69BD3DC287B87C47156A6C9527AC2E0E4ECC96ED1674EAAA031E863F24B2A8316A8E51EF21FABB4522E43D7A0656954B6CBFE2BF904559FAB2A16480B4F7F1CBD828FDDEF86DA4244ACCC0A4FE3B316F26;
        i_fEncrypt = 1;
        i_fStart = 0;

        @(negedge Clk) Rst = 1;
        #100 i_fStart = 1; #20 i_fStart = 0;
        #2000;
        i_Data = 128'h29C3505F571420F6402299B31A02D73A;
        i_fEncrypt = 0;
        #100 i_fStart = 1; #20 i_fStart = 0;
        #2000;


    end
endmodule