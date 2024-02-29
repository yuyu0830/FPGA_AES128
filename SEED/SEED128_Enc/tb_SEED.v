`timescale 1ns/1ns
module tb_SEED;
    reg Clk;
    reg Rst;
    reg i_fStart;
    reg i_Dec;
    reg [127:0] i_Data, i_Key;
    wire [127:0] o_Data;
    wire o_fDone;

    SEED S0(Clk, Rst, i_Data, i_Key, i_fStart, o_Data, o_fDone);

    always #10 Clk = ~Clk;

    initial 
    begin
        Clk = 1;    
        Rst = 0;
        i_Data  = 128'h00000000_00000000_00000000_00000000;
        i_Key   = 128'h00010203_04050607_08090A0B_0C0D0E0F;
        i_Dec   = 0;
        i_fStart = 0;

        @(negedge Clk) Rst = 1;
        #10  i_fStart = 1;
        #20   i_fStart = 0;
        #1000;


    
        Rst = 0;
        i_Data  = 128'h00010203_04050607_08090A0B_0C0D0E0F;
        i_Key   = 128'h00000000_00000000_00000000_00000000;
        i_Dec   = 0;
        i_fStart = 0;

        @(negedge Clk) Rst = 1;
        #10  i_fStart = 1;
        #20   i_fStart = 0;
        #1000;



        Rst = 0;
        i_Data  = 128'h83A2F8A2_88641FB9_A4E9A5CC_2F131C7D;
        i_Key   = 128'h47064808_51E61BE8_5D74BFB3_FD956185;
        i_Dec   = 0;
        i_fStart = 0;

        @(negedge Clk) Rst = 1;
        #10  i_fStart = 1;
        #20   i_fStart = 0;
        #1000;



        Rst = 0;
        i_Data  = 128'hB41E6BE2_EBA84A14_8E2EED84_593C5EC7;
        i_Key   = 128'h28DBC3BC_49FFD87D_CFA509B1_1D422BE7;
        i_Dec   = 0;
        i_fStart = 0;

        @(negedge Clk) Rst = 1;
        #10  i_fStart = 1;
        #20   i_fStart = 0;
        #1000;

        $stop;
        
    end
endmodule