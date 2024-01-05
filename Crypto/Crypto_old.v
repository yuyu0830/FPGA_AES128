module Crypto (
    input i_Clk, i_Rst,
    input [127:0] i_Data,
    input [1407:0] i_Key,
    input i_fEncrypt, i_fStart,
    output [127:0] o_Data,
    output o_fDone
);
    parameter
        IDLE         = 3'b000,
        FIRST_ROUND  = 3'b001,
        MIDDLE_ROUND = 3'b010,
        LAST_ROUND   = 3'b011,
        DONE         = 3'b100;

    parameter
        ROUND_MAX = 9;
        
    reg [2:0] c_State, n_State;
    reg [8:0] c_Round, n_Round;

    reg [127:0] c_RoundKey, n_RoundKey,
                c_RoundData, n_RoundData;

    wire [127:0] SB_o_Data;
    wire [127:0] SR_o_Data;
    wire [127:0] MC_o_Data;
    wire [127:0] MC_o_Key;

    wire fLastRepeat;
    wire fIdle, fFirstRound, fMiddleRound, fLastRound, fDone;
    wire fDecryptionKey;

    SubByte     SB(c_RoundData, SB_o_Data, i_fEncrypt);
    ShiftRow    SR(SB_o_Data, SR_o_Data, i_fEncrypt);
    MixCol_Top  MC0(SR_o_Data, MC_o_Data, i_fEncrypt);
    MixCol_Top  MC1(c_RoundKey, MC_o_Key, 1'b0);

    assign fLastRepeat = c_Round[8];
    
    assign fDecryptionKey = !i_fEncrypt & !fFirstRound & !fLastRound;

    assign
        fIdle        = c_State == IDLE,
        fFirstRound  = c_State == FIRST_ROUND,
        fMiddleRound = c_State == MIDDLE_ROUND,
        fLastRound   = c_State == LAST_ROUND,
        fDone        = c_State == DONE;

    assign o_Data = c_RoundData;

    assign o_fDone = c_State == DONE;

    always@ (posedge i_Clk, negedge i_Rst)
        if (!i_Rst) begin
            c_State     = IDLE;
            c_Round     = 0;
            c_RoundKey  = 0;
            c_RoundData = 0;
        end else begin
            c_State     = n_State;
            c_Round     = n_Round;
            c_RoundKey  = n_RoundKey;
            c_RoundData = n_RoundData;
        end

    always@*
    begin
        n_RoundKey = i_fEncrypt ?
        (i_fStart ? i_Key[1407:1280]     : 0) |
        (fFirstRound ? i_Key[1279:1152]  : 0) |
        (c_Round[0] ? i_Key[1151:1024]   : 0) |
        (c_Round[1] ? i_Key[1023:896]    : 0) |
        (c_Round[2] ? i_Key[895:768]     : 0) |
        (c_Round[3] ? i_Key[767:640]     : 0) |
        (c_Round[4] ? i_Key[639:512]     : 0) |
        (c_Round[5] ? i_Key[511:384]     : 0) |
        (c_Round[6] ? i_Key[383:256]     : 0) |
        (c_Round[7] ? i_Key[255:128]     : 0) |
        (c_Round[8] ? i_Key[127:0]       : 0) :
        (c_Round[8] ? i_Key[1407:1280]   : 0) |
        (c_Round[7] ? i_Key[1279:1152]   : 0) |
        (c_Round[6] ? i_Key[1151:1024]   : 0) |
        (c_Round[5] ? i_Key[1023:896]    : 0) |
        (c_Round[4] ? i_Key[895:768]     : 0) |
        (c_Round[3] ? i_Key[767:640]     : 0) |
        (c_Round[2] ? i_Key[639:512]     : 0) |
        (c_Round[1] ? i_Key[511:384]     : 0) |
        (c_Round[0] ? i_Key[383:256]     : 0) |
        (fFirstRound ? i_Key[255:128]    : 0) |
        (i_fStart ? i_Key[127:0]         : 0);

        n_RoundData = 
            fFirstRound  ? i_Data ^ c_RoundKey :
            fMiddleRound ? (fDecryptionKey ? MC_o_Data ^ MC_o_Key : MC_o_Data ^ c_RoundKey) :
            fLastRound   ? SR_o_Data ^ c_RoundKey : c_RoundKey;

        n_Round = 
            fFirstRound ? 9'b0000_00001 :
            fMiddleRound ? {c_Round[7:0], 1'b0} : 0;

        case(c_State)
            IDLE:
                n_State = i_fStart ? FIRST_ROUND : c_State;

            FIRST_ROUND:
                n_State = MIDDLE_ROUND;

            MIDDLE_ROUND:
                n_State = fLastRepeat ? LAST_ROUND : c_State;

            LAST_ROUND:
                n_State = DONE;

            DONE:
                n_State = IDLE;
        endcase
    end
endmodule