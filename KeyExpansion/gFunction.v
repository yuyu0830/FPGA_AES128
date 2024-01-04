module gFunction(
    input [31:0] i_Word,
    input [3:0] i_Round,
    output [31:0] o_Word,
    input i_fEncrypt
);
    wire [31:0] SB_i_Key, SB_o_Key;
    wire [7:0] Rcon;

    assign Rcon = 
        i_Round == 0 ? (i_fEncrypt ? 8'h01 : 8'h36) : 
        i_Round == 1 ? (i_fEncrypt ? 8'h02 : 8'h1b) : 
        i_Round == 2 ? (i_fEncrypt ? 8'h04 : 8'h80) : 
        i_Round == 3 ? (i_fEncrypt ? 8'h08 : 8'h40) : 
        i_Round == 4 ? (i_fEncrypt ? 8'h10 : 8'h20) : 
        i_Round == 5 ? (i_fEncrypt ? 8'h20 : 8'h10) : 
        i_Round == 6 ? (i_fEncrypt ? 8'h40 : 8'h08) : 
        i_Round == 7 ? (i_fEncrypt ? 8'h80 : 8'h04) : 
        i_Round == 8 ? (i_fEncrypt ? 8'h1b : 8'h02) : 
                       (i_fEncrypt ? 8'h36 : 8'h01);

    // RotWord
    assign SB_i_Key = {i_Word[23:0], i_Word[31:24]};

    // SubWord
    KeySubByte KSB(SB_i_Key, SB_o_Key);

    assign o_Word = SB_o_Key ^ {Rcon, 24'h00_00_00};
endmodule