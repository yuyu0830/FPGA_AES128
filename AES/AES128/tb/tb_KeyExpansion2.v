`timescale 1ns/1ns
module tb_KeyExpansion2;
    reg Clk;
    reg Rst;
    reg [127:0] KE_i_Key;
    reg i_fDec;
    reg [3:0] i_Round;

    wire [127:0] KE_o_Key;

    KeyExpansion KE(KE_i_Key, i_Round, KE_o_Key, i_fDec);

    always #10 Clk = ~Clk;

    initial 
    begin
        Clk = 1;    
        Rst = 0;
        i_Round = 3;
        KE_i_Key = {128'h54_68_61_74_73_20_6D_79_20_4B_75_6E_67_20_46_75};
        i_fDec = 0;
    
        @(negedge Clk) Rst = 1;

        #30;

        KE_i_Key = {128'hE232FCF191129188B159E4E6D679A293};
        i_Round = 4;
        
        #30;

        i_fDec = 1;
        i_Round = 3;


    end

endmodule