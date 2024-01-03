module KeyExpansion(
    input i_Clk, i_Rst,
    input [127:0] i_Key,
    input i_fIsFirst, i_fStart,
    output [1407:0] o_Key,
    output o_fDone
);
    reg [3:0] c_State, n_State;
    reg [2:0] c_Clk, n_Clk;
    reg [127:0] c_LastKey, n_LastKey;
    reg [127:0] c_RoundKey, n_RoundKey;
    reg [1407:0] c_Key, n_Key;

    wire [31:0] GF_i_Word, GF_o_Word;

    wire [127:0] CurrentRoundKey;
    wire [9:0] fRound;
    wire fIdle, fLast;
    wire fRoundDone;
    wire fLstClk;

    parameter
        IDLE     = 4'b0000,
        S1ST     = 4'b0001,
        S2ND     = 4'b0010,
        S3RD     = 4'b0011,
        S4TH     = 4'b0100,
        S5TH     = 4'b0101,
        S6TH     = 4'b0110,
        S7TH     = 4'b0111,
        S8TH     = 4'b1000,
        S9TH     = 4'b1001,
        S10TH    = 4'b1010,
        LAST     = 4'b1011,
        DONE     = 4'b1100;

    gFunction GF(GF_i_Word, c_State, GF_o_Word);

    assign fLstClk = c_Clk == 3'b101;
    assign
        fRound[9]   = c_State == S1ST, fRound[8]   = c_State == S2ND,
        fRound[7]   = c_State == S3RD, fRound[6]   = c_State == S4TH,
        fRound[5]   = c_State == S5TH, fRound[4]   = c_State == S6TH,
        fRound[3]   = c_State == S7TH, fRound[2]   = c_State == S8TH,
        fRound[1]   = c_State == S9TH, fRound[0]   = c_State == S10TH,
        fIdle   = c_State == IDLE,
        fLast   = c_State == LAST, 
        o_fDone = c_State == DONE;

    assign GF_i_Word = c_RoundKey[31:0];

    assign CurrentRoundKey = 
        (fRound[9] ? o_Key[1407:1280]   : 0) |
        (fRound[8] ? o_Key[1279:1152]   : 0) |
        (fRound[7] ? o_Key[1151:1024]   : 0) |
        (fRound[6] ? o_Key[1023:896]    : 0) |
        (fRound[5] ? o_Key[895:768]     : 0) |
        (fRound[4] ? o_Key[767:640]     : 0) |
        (fRound[3] ? o_Key[639:512]     : 0) |
        (fRound[2] ? o_Key[511:384]     : 0) |
        (fRound[1] ? o_Key[383:256]     : 0) |
        (fRound[0] ? o_Key[255:128]     : 0) |
        (fLast     ? o_Key[127:0]       : 0);

    assign o_Key = c_Key;

    always@ (posedge i_Clk, negedge i_Rst)
        if (!i_Rst) begin
            c_State     = IDLE;
            c_Clk       = 0;
            c_Key       = 0;
            c_LastKey   = 0;
            c_RoundKey  = 0;
        end else begin
            c_State     = n_State;
            c_Clk       = n_Clk;
            c_Key       = n_Key;
            c_LastKey   = n_LastKey;
            c_RoundKey  = n_RoundKey;
        end

    integer i;

    always@*
    begin
        n_Clk = fIdle ? 0 : c_Clk + 1;

        n_Key[1407:1280] = i_fStart ? (i_fIsFirst ? i_Key : c_LastKey) : c_Key[1407:1280];
        for (i = 0; i < 10; i = i + 1) begin
            n_Key[128*i+:128] = fRound[i] & fLstClk ? c_RoundKey : c_Key[128*i+:128];
        end

        n_RoundKey = 
            c_Clk == 3'b000 ? CurrentRoundKey :
            c_Clk == 3'b001 ? {c_RoundKey[127:96] ^ GF_o_Word, c_RoundKey[95:0]} :
            c_Clk == 3'b010 ? {c_RoundKey[127:96], c_RoundKey[127:96] ^ c_RoundKey[95:64], c_RoundKey[63:0]} : 
            c_Clk == 3'b011 ? {c_RoundKey[127:64], c_RoundKey[95:64] ^ c_RoundKey[63:32], c_RoundKey[31:0]} : 
            c_Clk == 3'b100 ? {c_RoundKey[127:32], c_RoundKey[63:32] ^ c_RoundKey[31:0]} : c_RoundKey;

        n_LastKey = fLast & fLstClk ? c_RoundKey : c_LastKey;
        n_State = c_State;
        case(c_State)
            IDLE:
                n_State = i_fStart ? S1ST : c_State;
            S1ST:
                n_State = fLstClk ? S2ND : c_State;
            S2ND:
                n_State = fLstClk ? S3RD : c_State;
            S3RD:
                n_State = fLstClk ? S4TH : c_State;
            S4TH:
                n_State = fLstClk ? S5TH : c_State;
            S5TH:
                n_State = fLstClk ? S6TH : c_State;
            S6TH:
                n_State = fLstClk ? S7TH : c_State;
            S7TH:   
                n_State = fLstClk ? S8TH : c_State;
            S8TH:
                n_State = fLstClk ? S9TH : c_State;
            S9TH:
                n_State = fLstClk ? S10TH : c_State;
            S10TH:
                n_State = fLstClk ? LAST : c_State;
            LAST:
                n_State = fLstClk ? DONE: c_State;
            DONE:
                n_State = IDLE;
        endcase
    end
endmodule