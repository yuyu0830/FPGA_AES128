`timescale 1ns/1ns
module tb_ShiftRow;
    reg Clk, Rst;

    reg [127:0] i_Data;
    reg i_fEncrypt;

    wire [127:0] o_Data;

    ShiftRow SR(i_Data, o_Data, i_fEncrypt);

    always #10 Clk = ~Clk;

    initial 
    begin
        Clk = 1;
        Rst = 0;
        i_Data = 128'hA0_A1_A2_A3_B0_B1_B2_B3_C0_C1_C2_C3_D0_D1_D2_D3;
        i_fEncrypt = 0;

        @(negedge Clk) Rst = 1;
        #50 i_fEncrypt = 1;

    end

endmodule