module SEED (
    input i_Clk, i_Rst,
    input [128:0] i_Data,
    output [127:0] o_Text,
    output o_fDone
);

    //parameter
    parameter
        IDLE    = 3'h0,
        GETKEY  = 3'h1,
        ENC     = 3'h2,
        JUMPKEY = 3'h3,
        DEC     = 3'h4,
        DONE    = 3'h5;

    parameter
        KC = {
            32'hBCDCCF1B, 32'hDE6E678D, 32'hEF3733C6, 32'h779B99E3,
            32'hBBCDCCF1, 32'hDDE6E678, 32'h6EF3733C, 32'h3779B99E,
            32'h1BBCDCCF, 32'h8DDE6E67, 32'hC6EF3733, 32'hE3779B99,
            32'hF1BBCDCC, 32'h78DDE6E6, 32'h3C6EF373, 32'h9E3779b9};

    
    //register
    reg c_fDec, n_fDec;
    reg [2:0] c_Clk, n_Clk;
    reg [3:0] c_Round, n_Round, c_State, n_State;
    reg [31:0] c_A, n_A, c_B, n_B, c_C, n_C, c_D, n_D, c_g0_Out, n_g0_Out, c_g1_Out, n_g1_Out;
    reg [63:0] c_L, n_L, c_R, n_R, c_Key, n_Key;


    //wire
    wire fLstRound, fLstClk, fRunning,;
    wire fIdle, fGetKey, fEnc, fJumpKey, fDec;
    wire fOdd;
    wire [31:0] g_In, g_Out;
    wire [63:0] F_i_Data, F_o_Data;
    wire [63:0] KG_o_Data;


    //module
    gFunction g0(g_in, g_out);
    

    //assign
    assign
        fFirst      = i_Data[128];
        fLstRound   = &c_Round,
        fLstClk     = c_Clk == (fJumpKey ? 2 : 4),
        fIdle       = c_State == IDLE,
        fGetKey     = c_State == GETKEY,
        fEnc        = c_State == ENC,
        fJumpKey    = c_State == JUMPKEY,
        fDec        = c_State == DEC,
        fRunning    = fEnc | fJumpKey | fDec,
        o_Text      = o_fDone ? {c_R, c_L} : 0,
        o_fDone     = c_State == DONE;

    always@ (posedge i_Clk, negedge i_Rst)
        if (!i_Rst) begin
            c_State     = IDLE;
            c_fDec      = 0;
            c_Clk       = 0;
            c_Round     = 0;
            c_L         = 0;
            c_R         = 0;
            c_A         = 0;
            c_B         = 0;
            c_C         = 0;
            c_D         = 0;
            c_g0_Out    = 0;
            c_g1_Out    = 0;
        end else begin
            c_State     = n_State;
            c_fDec      = n_fDec;
            c_Clk       = n_Clk; 
            c_Round     = n_Round;
            c_L         = n_L;
            c_R         = n_R;
            c_A         = n_A;
            c_B         = n_B;
            c_C         = n_C;
            c_D         = n_D;
            c_g0_Out    = n_g0_Out;
            c_g1_Out    = n_g1_Out;
        end

    always@*
    begin
        n_fDec = fGetKey ? fFirst : c_fDec;
        n_Round = fRunning ? c_Round + 1 : 0;
        n_L = fIdle & i_fStart ? (i_fDec ? i_Data[ 63: 0] : i_Data[127:64]) : (fDec ? F_o_Data ^ c_R : (fEnc ? c_R : c_L));
        n_R = fIdle & i_fStart ? (i_fDec ? i_Data[127:64] : i_Data[ 63: 0]) : (fDec ? c_L : (fEnc ? F_o_Data ^ c_L : c_R));


        n_State = c_State;
        case(c_State)
            IDLE:       n_State = fFirst ? GETTEXT : c_State;

            GETKEY:     n_State = fFirst ? DEC : ENC;

            ENC:        n_State = fLstRound && fLstClk ? DONE : c_State;

            JUMPKEY     n_State = fLstRound && fLstClk ? DEC : c_State;

            DEC:        n_State = fLstRound && fLstClk ? DONE : c_State;

            DONE:       n_State = IDLE;
        endcase
    end

endmodule