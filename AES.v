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
        IDLE    = 3'b000,
        GEN_KEY = 3'b001,
        FIRST   = 3'b010,
        MIDDLE  = 3'b011,
        FINAL   = 3'b100,
        DONE    = 3'b101;

    parameter ROUND_MAX = 9;


    // register
    reg c_FirstText, n_FirstText;
    reg [2:0] c_State, n_State;
    reg [3:0] c_Round, n_Round;

    reg [127:0] c_Key, n_Key,
                c_Text, n_Text,
                c_NextKey, n_NextKey;


    // wire
    wire [127:0] SB_o_Data;
    wire [127:0] SR_o_Data;
    wire [127:0] MC_i_Data;
    wire [127:0] MC_o_Data;

    wire [127:0] KE_o_Key;

    wire fKE_Dec;
    wire fKeyMC;

    wire fIsFirstText;
    wire fLstMiddle;
    wire fIdle, fFirst, fGenKey, fMiddle, fFinal;


    // Module
    SubByte      SB(c_Text, SB_o_Data, i_fDec);
    ShiftRow     SR(SB_o_Data, SR_o_Data, i_fDec);
    MixCol_Top   MC0(MC_i_Data, MC_o_Data, i_fDec);

    KeyExpansion KE(c_Key, c_Round, KE_o_Key, fKE_Dec);


    // assign
    assign o_fDone = c_State == DONE;

    assign o_Data = o_fDone ? c_Text : 0;

    assign fLstMiddle = c_Round == ROUND_MAX;

    assign fIsFirstText = i_fStart & c_FirstText;

    assign fKE_Dec = !fGenKey & i_fDec;

    assign fKeyMC = fMiddle & i_fDec;

    assign MC_i_Data = fKeyMC ? SR_o_Data ^ c_Key : SR_o_Data;

    assign
        fIdle   = c_State == IDLE,
        fGenKey = c_State == GEN_KEY,
        fFirst  = c_State == FIRST,
        fMiddle = c_State == MIDDLE,
        fFinal  = c_State == FINAL;

    always@ (posedge i_Clk, negedge i_Rst)
        if (!i_Rst) begin
            c_State     = IDLE;
            c_Round     = 0;
            c_Key       = 0;
            c_Text      = 0;
            c_FirstText = 1;
            c_NextKey   = 0;
        end else begin
            c_State     = n_State;
            c_Round     = n_Round;
            c_Key       = n_Key;
            c_Text      = n_Text;
            c_FirstText = n_FirstText;
            c_NextKey   = n_NextKey;
        end
    

    always@*
    begin
        n_Text = 
            fIdle   ? 0 :
            fFirst  ? i_Text ^ c_NextKey :
            fMiddle ? (fKeyMC ? MC_o_Data : MC_o_Data ^ c_Key) :
            fFinal  ? SR_o_Data ^ c_Key : c_Text;

        n_Key = 
            fIsFirstText ? i_Key :
            !fIdle & !fFinal & !o_fDone ? KE_o_Key : 0;
            
        n_FirstText = fFirst ? 0 : c_FirstText;

        n_Round = fFirst ? 1 : (fMiddle | fGenKey ? (fLstMiddle ? 0 : c_Round + 1) : 0);
        
        n_NextKey = 
            fIsFirstText ? i_Key :
            !i_fDec & fFinal ? c_Key :
            fLstMiddle & fGenKey ? KE_o_Key : c_NextKey;

        n_State = c_State;
        case(c_State)
            IDLE:    n_State = i_fStart ? (!i_fDec ? FIRST : GEN_KEY) : c_State;

            GEN_KEY: n_State = fLstMiddle ? FIRST : c_State;

            FIRST:   n_State = MIDDLE;

            MIDDLE:  n_State = fLstMiddle ? FINAL : c_State;

            FINAL:   n_State = DONE;

            DONE:    n_State = IDLE;
        endcase
    end
endmodule
