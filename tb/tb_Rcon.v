`timescale 1ns/1ns
module tb_Rcon;
    reg Clk, Rst;
    reg fStart;

    Rcon RC(Clk, Rst, fStart);

    always #10 Clk = ~Clk;

    initial 
    begin
        Clk = 1;    
        Rst = 0;
        fStart = 0;

        @(negedge Clk) Rst = 1;
        #100 fStart = 1; #10 fStart = 0;
        #300 fStart = 1; #10 fStart = 0;

    end

endmodule