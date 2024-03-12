`timescale 1ns/1ns
module tb_F;
    reg [63:0] i_Data, i_Key;
    wire [63:0] o_Data;

    fFunction f0(i_Data, i_Key, o_Data);

    initial 
    begin
        i_Data = 64'h00000000_00000000;
        i_Key  = 64'h00000000_00000000;

        #10;
        i_Data = 64'hffffffff_ffffffff;

        #10;
        i_Key  = 64'hcccccccc_cccccccc;

        #10;
        i_Data = 64'h00000000_00000001;

        $stop;

    end
endmodule