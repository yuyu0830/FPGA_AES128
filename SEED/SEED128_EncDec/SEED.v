module SEED (
    input i_Clk, i_Rst,
    input [127:0] i_Text,
    input i_fStart, i_fDec,
    output [127:0] o_Text,
    output o_fDone
);

    //parameter
    parameter
        IDLE    = 3'h0,
        KEYIN   = 3'h1,
        GENKEY  = 3'h2,
        ENC     = 3'h3,
        DEC     = 3'h4,
        DONE    = 3'h5;

    
    //register
    reg c_fDec, n_fDec;
    reg [2:0] c_State, n_State;
    reg [3:0] c_Round, n_Round;
    reg [63:0] c_L, n_L, c_R, n_R;


    //wire
    wire fLstRound;
    wire fIdle, fKeyIn, fEnc, fGenKey, fRunning, fDec;
    wire [63:0] F_i_Data, F_o_Data;
    wire [63:0] KG_o_Data;


    //module
    KeyGenerator KG0(i_Clk, i_Rst, fKeyIn, fDec, fRunning & !fLstRound, i_Text, c_Round, KG_o_Data);
    fFunction F0(F_i_Data, KG_o_Data, F_o_Data);
    

    //assign
    assign 
        fLstRound   = &c_Round,
        fIdle       = c_State == IDLE,
        fKeyIn      = c_State == KEYIN,
        fEnc        = c_State == ENC,
        fGenKey     = c_State == GENKEY,
        fDec        = c_State == DEC,
        fRunning    = fEnc | fGenKey | fDec,
        F_i_Data    = fDec ? c_L : c_R,
        o_Text      = o_fDone ? (c_fDec ? {c_L, c_R} : {c_R, c_L}) : 0,
        o_fDone     = c_State == DONE;

    always@ (posedge i_Clk, negedge i_Rst)
        if (!i_Rst) begin
            c_State = IDLE;
            c_Round = 0;
            c_L     = 0;
            c_R     = 0;
            c_fDec   = 0;
        end else begin
            c_State = n_State;
            c_Round = n_Round;
            c_L     = n_L;
            c_R     = n_R;
            c_fDec   = n_fDec;
        end

    always@*
    begin
        n_fDec = i_fStart ? i_fDec : c_fDec;
        n_Round = fRunning ? c_Round + 1 : 0;
        n_L = fIdle & i_fStart ? (i_fDec ? i_Text[ 63: 0] : i_Text[127:64]) : (fDec ? F_o_Data ^ c_R : (fEnc ? c_R : c_L));
        n_R = fIdle & i_fStart ? (i_fDec ? i_Text[127:64] : i_Text[ 63: 0]) : (fDec ? c_L : (fEnc ? F_o_Data ^ c_L : c_R));

        // n_L = fDec | fEnc ? (fDec ? F_o_Data ^ c_R : c_R) : (fIdle & i_fStart ? i_Text[127:64] : 0);
        // n_R = fDec | fEnc ? (fDec ? c_L : F_o_Data ^ c_L) : (fIdle & i_fStart ? i_Text[63:0] : 0);

        n_State = c_State;
        case(c_State)
            IDLE:   n_State = i_fStart ? KEYIN : c_State;

            KEYIN:  n_State = c_fDec ? GENKEY : ENC;

            GENKEY: n_State = fLstRound ? DEC : c_State;

            ENC:    n_State = fLstRound ? DONE : c_State;

            DEC:    n_State = fLstRound ? DONE : c_State;

            DONE:   n_State = IDLE;
        endcase
    end

endmodule