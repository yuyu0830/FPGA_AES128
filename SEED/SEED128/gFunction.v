module gFunction(
    input [31:0] i_Data,
    output [31:0] o_Data
);

    //parameter
    parameter m = 32'hFCF3CF3F;

    //wire
    wire [7:0] S1_Out1, S1_Out2, S2_Out1, S2_Out2;
    wire [7:0] X3, X2, X1, X0;


    //assign
    assign
        X3 = S1_Out1 & m,
        X2 = S1_Out2 & m,
        X1 = S2_Out1 & m,
        X0 = S2_Out2 & m;


    assign
        o_Data = {
            X3[5:4], X2[3:2], X1[1:0], X0[7:6],
            X3[3:2], X2[1:0], X1[7:6], X0[5:4],
            X3[1:0], X2[7:6], X1[5:4], X0[3:2],
            X3[7:6], X2[5:4], X1[3:2], X0[1:0],
        };


    //module
    SBox1 S1_1(i_Data[23:16], S1_Out1);
    SBox1 S1_2(i_Data[ 7: 0], S1_Out2);
    SBox2 S2_1(i_Data[31:24], S2_Out1);
    SBox2 S2_2(i_Data[15: 8], S2_Out2);




endmodule