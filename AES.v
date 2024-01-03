module AES(
    input i_Clk, i_Rst,
    input i_fStart,
    input i_fEnc,
    input [127:0] i_Text,
    input [127:0] i_Key,
    output [127:0] o_Data,
    output o_fDone
);

wire KEXP_i_fIsFirst;
assign KEXP_i_fIsFirst = 1;

wire KEXP_o_fDone;

wire [1407:0] KEXP_o_Key;

KeyExpansion KEP(
    i_Clk,
    i_Rst,
    i_Key,
    KEXP_i_fIsFirst, 
    i_fStart,
    KEXP_o_Key,
    KEXP_o_fDone
);

wire CRPT_o_fDone;

Crypto CRPT(
    i_Clk, 
    i_Rst,
    i_Text,
    KEXP_o_Key,
    i_fEnc, 
    KEXP_o_fDone,
    o_Data,
    o_fDone
);

endmodule
