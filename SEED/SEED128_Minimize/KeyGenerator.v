module KeyGenerator(
    input i_Clk, i_Rst, i_fStart, i_fDec, i_fRunning,
    input [127:0] i_Key,
    input [3:0] i_Round,
    output [63:0] o_Key
);

    //parameter
    parameter
        KC = {
            32'hBCDCCF1B,
            32'hDE6E678D,
            32'hEF3733C6,
            32'h779B99E3,
            32'hBBCDCCF1,
            32'hDDE6E678,
            32'h6EF3733C,
            32'h3779B99E,
            32'h1BBCDCCF,
            32'h8DDE6E67,
            32'hC6EF3733,
            32'hE3779B99,
            32'hF1BBCDCC,
            32'h78DDE6E6,
            32'h3C6EF373,
            32'h9E3779b9};


    //reg
    reg [31:0] c_A, c_B, c_C, c_D,
               n_A, n_B, n_C, n_D;


    //wire
    wire [31:0] g0_Out, g1_Out, roundKey;
    wire [31:0] g0_In, g1_In;
    wire fOdd;


    //assign
    assign
        fOdd        = !i_Round[0],
        roundKey    = i_fDec ? KC[(15 - i_Round)*32+:32] : KC[i_Round*32+:32],
        o_Key       = {g0_Out, g1_Out};

    assign
        g0_In = c_A + c_C - roundKey,
        g1_In = c_B - c_D + roundKey;


    //module
    gFunction g0(g0_In, g0_Out);
    gFunction g1(g1_In, g1_Out);

    always@ (posedge i_Clk, negedge i_Rst)
    if (!i_Rst) begin
        c_A = 0;
        c_B = 0;
        c_C = 0;
        c_D = 0;
    end else begin
        c_A = i_fStart ? i_Key[127:96] : n_A;
        c_B = i_fStart ? i_Key[ 95:64] : n_B;
        c_C = i_fStart ? i_Key[ 63:32] : n_C;
        c_D = i_fStart ? i_Key[ 31: 0] : n_D;
    end

    always@*
    begin
        n_A = i_fRunning ? (i_fDec ? (!fOdd ? c_A : {c_A[23: 0], c_B[31:24]}) : (fOdd ? {c_B[ 7: 0], c_A[31: 8]} : c_A)) : c_A;
        n_B = i_fRunning ? (i_fDec ? (!fOdd ? c_B : {c_B[23: 0], c_A[31:24]}) : (fOdd ? {c_A[ 7: 0], c_B[31: 8]} : c_B)) : c_B;
        n_C = i_fRunning ? (i_fDec ? (!fOdd ? {c_D[ 7: 0], c_C[31: 8]} : c_C) : (fOdd ? c_C : {c_C[23: 0], c_D[31:24]})) : c_C;
        n_D = i_fRunning ? (i_fDec ? (!fOdd ? {c_C[ 7: 0], c_D[31: 8]} : c_D) : (fOdd ? c_D : {c_D[23: 0], c_C[31:24]})) : c_D;
    end
endmodule

