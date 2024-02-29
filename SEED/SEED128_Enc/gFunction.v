module gFunction(
    input [31:0] i_Data,
    output [31:0] o_Data
);

    wire [31:0] S0_Out, S1_Out, S2_Out, S3_Out;

    assign
        o_Data = S0_Out ^ S1_Out ^ S2_Out ^ S3_Out;

    SS0 SU0(i_Data[ 7: 0], S0_Out);
    SS1 SU1(i_Data[15: 8], S1_Out);
    SS2 SU2(i_Data[23:16], S2_Out);
    SS3 SU3(i_Data[31:24], S3_Out);
    
endmodule