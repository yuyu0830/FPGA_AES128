`timescale 1ns/1ns
module tb_G;
    reg [31:0] i_Data;
    wire [31:0] o_Data;

    
    gFunction g0(i_Data, o_Data);

    initial 
    begin
        i_Data = 32'h9E9779b9;

        #10;
        i_Data = 32'h61688647;

        #10;
        i_Data = 32'hcccccccc;

        #10;
        i_Data = 32'h00000001;

        $stop;

    end
endmodule