module KeyExpansion (
    input [127:0] i_Key,
    input [3:0] i_RoundNum,
    output [127:0] o_Key,
    input i_fEncrypt
);
    wire [31:0] GF_i_Word;
    wire [31:0] GF_o_Word;

    wire [31:0] Byte [3:0];
    wire [31:0] o_Byte0, o_Byte1, o_Byte2, o_Byte3;
    
    gFunction GF(GF_i_Word, i_RoundNum, GF_o_Word, i_fEncrypt);

    assign GF_i_Word = i_fEncrypt ? Byte[3] : Byte[2] ^ Byte[3];

    assign
        Byte[0] = i_Key[127:96],
        Byte[1] = i_Key[95:64],
        Byte[2] = i_Key[63:32], 
        Byte[3] = i_Key[31:0];

    assign 
        o_Byte0 = GF_o_Word ^ Byte[0],
        o_Byte1 = i_fEncrypt ? o_Byte0 ^ Byte[1] : Byte[0] ^ Byte[1],
        o_Byte2 = i_fEncrypt ? o_Byte1 ^ Byte[2] : Byte[1] ^ Byte[2],
        o_Byte3 = i_fEncrypt ? o_Byte2 ^ Byte[3] : Byte[2] ^ Byte[3];

    assign o_Key = {o_Byte0, o_Byte1, o_Byte2, o_Byte3};

endmodule