module KeyExpansion (
    input [127:0] i_Key,
    input [3:0] i_Round,
    output [127:0] o_Key,
    input i_fDec
);
    wire [31:0] GF_Target, GF_Word;
    wire [31:0] SB_Word;
    wire [7:0] Rcon;
    wire [3:0] ExRound;

    wire [31:0] Byte [3:0];
    wire [31:0] o_Byte0, o_Byte1, o_Byte2, o_Byte3;

    // gFunction
    assign GF_Target = !i_fDec ? Byte[3] : Byte[2] ^ Byte[3];

    // gFunction - RotWord + SubWord
    SBox SB0(GF_Target[16+:8], SB_Word[24+:8], 1'b0);
    SBox SB1(GF_Target[ 8+:8], SB_Word[16+:8], 1'b0);
    SBox SB2(GF_Target[ 0+:8], SB_Word[ 8+:8], 1'b0);
    SBox SB3(GF_Target[24+:8], SB_Word[ 0+:8], 1'b0);    

    // gFunction - Rcon XOR
    assign ExRound = {4{i_fDec}} ^ (i_Round + 3);

    assign Rcon = 
        ExRound == 3  ? 8'h01 : 
        ExRound == 4  ? 8'h02 : 
        ExRound == 5  ? 8'h04 : 
        ExRound == 6  ? 8'h08 : 
        ExRound == 7  ? 8'h10 : 
        ExRound == 8  ? 8'h20 : 
        ExRound == 9  ? 8'h40 : 
        ExRound == 10 ? 8'h80 : 
        ExRound == 11 ? 8'h1b : 
                        8'h36;

    assign GF_Word = SB_Word ^ {Rcon, 24'h00_00_00};

    // KeyExpansion
    assign
        Byte[0] = i_Key[127:96],
        Byte[1] = i_Key[95:64],
        Byte[2] = i_Key[63:32], 
        Byte[3] = i_Key[31:0];

    assign 
        o_Byte0 = GF_Word ^ Byte[0],
        o_Byte1 = !i_fDec ? o_Byte0 ^ Byte[1] : Byte[0] ^ Byte[1],
        o_Byte2 = !i_fDec ? o_Byte1 ^ Byte[2] : Byte[1] ^ Byte[2],
        o_Byte3 = !i_fDec ? o_Byte2 ^ Byte[3] : Byte[2] ^ Byte[3];

    assign o_Key = {o_Byte0, o_Byte1, o_Byte2, o_Byte3};

endmodule