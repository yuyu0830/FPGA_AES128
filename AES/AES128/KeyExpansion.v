module KeyExpansion (
    input [127:0] i_Key,
    input [3:0] i_Round,
    output [127:0] o_Key,
    input i_fDec
);
    wire [31:0] KS_i_Text, KS_o_Text;
    wire [7:0] Rcon;
    wire [3:0] Round;

    wire [31:0] Byte [3:0];

    assign
        Byte[0] = i_Key[3*32+:32],
        Byte[1] = i_Key[2*32+:32],
        Byte[2] = i_Key[1*32+:32], 
        Byte[3] = i_Key[0*32+:32];

    // gFunction
    assign KS_i_Text = i_fDec ? Byte[2] ^ Byte[3] : Byte[3];

    // gFunction - RotWord + SubWord
    KeySBox KS0(KS_i_Text[16+:8], KS_o_Text[24+:8]);
    KeySBox KS1(KS_i_Text[ 8+:8], KS_o_Text[16+:8]);
    KeySBox KS2(KS_i_Text[ 0+:8], KS_o_Text[ 8+:8]);
    KeySBox KS3(KS_i_Text[24+:8], KS_o_Text[ 0+:8]);    

    // gFunction - Rcon XOR
    assign Round = i_Round ^ {4{i_fDec}};

    assign Rcon = 
        Round ==  3 ? 8'h01 : 
        Round ==  4 ? 8'h02 : 
        Round ==  5 ? 8'h04 : 
        Round ==  6 ? 8'h08 : 
        Round ==  7 ? 8'h10 : 
        Round ==  8 ? 8'h20 : 
        Round ==  9 ? 8'h40 : 
        Round == 10 ? 8'h80 : 
        Round == 11 ? 8'h1b : 
                      8'h36;
    assign 
        o_Key[3*32+:32] = KS_o_Text ^ Byte[0] ^ {Rcon, 24'h00},
        o_Key[2*32+:32] = i_fDec ? Byte[0] ^ Byte[1] : o_Key[3*32+:32] ^ Byte[1],
        o_Key[1*32+:32] = i_fDec ? Byte[1] ^ Byte[2] : o_Key[2*32+:32] ^ Byte[2],
        o_Key[0*32+:32] = i_fDec ? Byte[2] ^ Byte[3] : o_Key[1*32+:32] ^ Byte[3];

endmodule