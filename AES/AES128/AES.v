module AES(
    input i_Clk, i_Rst,
    input i_fStart,
    input i_fDec,
    input [127:0] i_Text,
    input [127:0] i_Key,
    output [127:0] o_Data,
    output o_fDone
);
    // parameter
    parameter
        IDLE    = 3'h0,
        GEN_KEY = 3'h1,
        FIRST   = 3'h2,
        MIDDLE  = 3'h3,
        FINAL   = 3'h4;

    parameter ROUND_MAX = 12;

    // register
    reg c_fDec, n_fDec;
    reg [2:0] c_State, n_State;
    reg [3:0] c_Round, n_Round;

    reg [127:0] c_Key, n_Key,
                c_Text, n_Text;

    // wire
    wire [127:0] SB_o_Data;
    wire [127:0] SR_o_Data;
    wire [127:0] MC_i_Data;
    wire [127:0] MC_o_Data;

    wire [127:0] KE_o_Key;
    wire KE_i_Dec;

    wire fMCAddKey;
    wire fLstRepeat;
    wire fIdle, fFirst, fGenKey, fMiddle, fFinal;

    // Module
    SubByte      SB(c_Text, SB_o_Data, c_fDec);
    ShiftRow     SR(SB_o_Data, SR_o_Data, c_fDec);
    MixCol       MC0(MC_i_Data, MC_o_Data, c_fDec);

    KeyExpansion KE(c_Key, c_Round, KE_o_Key, KE_i_Dec);


    // assign
    assign o_fDone = fFinal;

    assign o_Data = o_fDone ? SR_o_Data ^ c_Key : 0;

    assign fLstRepeat = c_Round == ROUND_MAX;

    assign KE_i_Dec = !fGenKey & c_fDec;

    assign fMCAddKey = fMiddle & c_fDec;

    assign MC_i_Data = fMCAddKey ? SR_o_Data ^ c_Key : SR_o_Data;

    assign
        fIdle   = c_State == IDLE,
        fGenKey = c_State == GEN_KEY,
        fFirst  = c_State == FIRST,
        fMiddle = c_State == MIDDLE,
        fFinal  = c_State == FINAL;


    always@ (posedge i_Clk, negedge i_Rst)
        if (!i_Rst) begin
            c_State     = IDLE;
            c_Round     = 3;
            c_Key       = 0;
            c_Text      = 0;
            c_fDec      = 0;
        end else begin
            c_State     = n_State;
            c_Round     = n_Round;
            c_Key       = n_Key;
            c_Text      = n_Text;
            c_fDec      = n_fDec;
        end

    always@*
    begin
        n_fDec = fIdle & i_fStart ? i_fDec : c_fDec;

        n_Text = 
            fIdle   & i_fStart ? i_Text :
            fFirst  ? c_Text ^ c_Key :
            fMiddle ? (c_fDec ? MC_o_Data : MC_o_Data ^ c_Key) : c_Text;

        n_Key = 
            fIdle   & i_fStart ? i_Key :
            fGenKey | fFirst | fMiddle ? KE_o_Key : c_Key;
            
        n_Round = 
            fGenKey ? (fLstRepeat ? 3 : c_Round + 1) :
            fFirst | fMiddle ? c_Round + 1 : 3;
        
        n_State = c_State;
        case(c_State)
            IDLE:    n_State = i_fStart ? (i_fDec ? GEN_KEY : FIRST) : c_State;

            GEN_KEY: n_State = fLstRepeat ? FIRST : c_State;

            FIRST:   n_State = MIDDLE;

            MIDDLE:  n_State = fLstRepeat ? FINAL : c_State;

            FINAL:   n_State = IDLE;
        endcase
    end
endmodule
