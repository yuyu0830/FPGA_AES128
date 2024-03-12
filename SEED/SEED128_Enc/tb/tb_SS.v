`timescale 1ns/1ns
module tb_SS;
    reg [7:0] i_Data0, i_Data1, i_Data2, i_Data3;
    wire [31:0] o_Data0, o_Data1, o_Data2, o_Data3;

    SS0 S0(i_Data0, o_Data0);
    SS1 S1(i_Data1, o_Data1);
    SS2 S2(i_Data2, o_Data2);
    SS3 S3(i_Data3, o_Data3);

    initial 
    begin
        i_Data0 = 8'h00;
        i_Data1 = 8'h00;
        i_Data2 = 8'h00;
        i_Data3 = 8'h00;

        #10;
        i_Data0 = 8'hff;
        i_Data1 = 8'hff;
        i_Data2 = 8'hff;
        i_Data3 = 8'hff;

        $stop;

    end
endmodule