module SEED (
    input i_Clk, i_Rst,
    input [127:0] i_Text, i_Key,
    input i_fStart, i_Dec,
    output [127:0] o_Text,
    output o_fDone
);

    //parameter
    parameter
        IDLE    = 2'h0,
        ENC     = 2'h1,
        DEC     = 2'h2,
        DONE    = 2'h3;

    
    //register
    reg [1:0] c_State, n_State;
    reg [3:0] c_Round, n_Round;
    reg [63:0] c_L, n_L, c_R, n_R;


    //wire
    wire fLstRound;
    wire fIdle, fRunning, fDec;
    wire [63:0] F_o_Data;
    wire [63:0] KG_o_Data;


    //module
    KeyGenerator KG0();
    fFunction F0(fDec ? c_L : c_R,  F_o_Data);
    

    //assign
    assign 
        fLstRound   = &c_Round,
        fIdle       = c_State == IDLE,
        fDec        = c_State == DEC,
        fRounding   = (c_State == ENC) | (c_State == DEC);


    always@ (posedge i_Clk, negedge i_Rst)
        if (!i_Rst) begin
            c_State = IDLE;
            c_Round = 0;
            c_L     = 0;
            c_R     = 0;
        end else begin
            c_State = n_State;
            c_Round = n_Round;
            c_L     = n_L;
            c_R     = n_R;
        end

    always
    begin
        n_Round = fRunning ? c_Round + 1 : 0;
        n_L = fRunning ? c_R : (fIdle & i_fStart ? i_Text[127:64] : 0);
        n_R = fRunning ? F_o_Data ^ c_L : (fIdle & i_fStart ? i_Text[63:0] : 0);


        case(c_State)
            IDLE:   n_State = i_fStart ? (i_Dec ? DEC : ENC) : c_State;

            ENC:    n_State = fLstRound ? DONE : c_State;

            DEC:    n_State = fLstRound ? DONE : c_State;

            DONE:   n_State = IDLE;
        endcase
    end




endmodule