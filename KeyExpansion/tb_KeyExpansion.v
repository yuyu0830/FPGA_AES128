`timescale 1ns/1ns
module tb_KeyExpansion();
    reg Clk;
    reg Rst;
    reg [127:0] KE_i_Key;
    reg fIsFirst, fStart;

    wire [1407:0] KE_o_Key;
    wire KE_o_fDone;

    KeyExpansion KE(Clk, Rst, KE_i_Key, fIsFirst, fStart, KE_o_Key, KE_o_fDone);

    always #10 Clk = ~Clk;

    initial 
    begin
        Clk = 1;    
        Rst = 0;
        KE_i_Key = {128'h54_68_61_74_73_20_6D_79_20_4B_75_6E_67_20_46_75};
        fIsFirst = 0;
        fStart = 0;

        @(negedge Clk) Rst = 1;

        #100 fIsFirst = 1; fStart = 1; #10 fIsFirst = 0; fStart = 0;
    end

endmodule