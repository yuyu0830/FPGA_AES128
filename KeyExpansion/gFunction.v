module gFunction(
    input [31:0] i_Word,
    input [3:0] i_Round,
    output [31:0] o_Word
);
    wire [31:0] SB_i_Key, SB_o_Key;
    wire [7:0] Rcon;

    assign Rcon = 
        i_Round == 1 ? 8'h01 : 
        i_Round == 2 ? 8'h02 : 
        i_Round == 3 ? 8'h04 : 
        i_Round == 4 ? 8'h08 : 
        i_Round == 5 ? 8'h10 : 
        i_Round == 6 ? 8'h20 : 
        i_Round == 7 ? 8'h40 : 
        i_Round == 8 ? 8'h80 : 
        i_Round == 9 ? 8'h1b : 
        i_Round == 10 ? 8'h36 : 0;

    // RotWord
    assign SB_i_Key = {i_Word[23:0], i_Word[31:24]};

    // SubWord
    KeySubByte KSB(SB_i_Key, SB_o_Key);

    assign o_Word = SB_o_Key ^ {Rcon, 24'h00_00_00};
endmodule