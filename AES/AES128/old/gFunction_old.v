module gFunction(
    input [31:0] i_Word,
    input [3:0] i_Round,
    output [31:0] o_Word,
    input i_fDec
);
    wire [31:0] SB_i_Key, SB_o_Key;
    wire [7:0] Rcon;
    wire [3:0] i_ExRound;

    assign i_ExRound = {4{i_fDec}} ^ (i_Round + 3);

    assign Rcon = 
        i_ExRound == 3  ? 8'h01 : 
        i_ExRound == 4  ? 8'h02 : 
        i_ExRound == 5  ? 8'h04 : 
        i_ExRound == 6  ? 8'h08 : 
        i_ExRound == 7  ? 8'h10 : 
        i_ExRound == 8  ? 8'h20 : 
        i_ExRound == 9  ? 8'h40 : 
        i_ExRound == 10 ? 8'h80 : 
        i_ExRound == 11 ? 8'h1b : 
                          8'h36;

    // RotWord
    assign SB_i_Key = {i_Word[23:0], i_Word[31:24]};

    // SubWord
    KeySubByte KSB(SB_i_Key, SB_o_Key);

    assign o_Word = SB_o_Key ^ {Rcon, 24'h00_00_00};
endmodule