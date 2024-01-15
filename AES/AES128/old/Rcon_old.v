module Rcon(
    input i_Clk, i_Rst, i_fStart
);
    reg [3:0] c_State, n_State;
    reg [7:0] c_Rcon, n_Rcon;

    wire fDone, fIdle, fLast;

    parameter
        IDLE    = 4'b0000,
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
        LAST    = 4'b1011,
        DONE    = 4'b1100;

    assign
        fIdle   = c_State == IDLE,
        fLast   = c_State == LAST,
        fDone   = c_State == DONE;

    always@ (posedge i_Clk, negedge i_Rst)
        if (!i_Rst) begin
            c_State     = IDLE;
            c_Rcon      = 8'h01;
        end else begin
            c_State     = n_State;
            c_Rcon      = n_Rcon;
        end

    always@* 
    begin
        n_Rcon = fIdle | fDone | c_State == S10TH ? 8'h01 : (c_Rcon[7] ? {c_Rcon[6:0], 1'b0} ^ 8'h1b : {c_Rcon[6:0], c_Rcon[7]});
        n_State = c_State;
        case(c_State)
            IDLE:
                n_State = i_fStart ? S1ST : c_State;
            S1ST:
                n_State = S2ND;
            S2ND:
                n_State = S3RD;
            S3RD:
                n_State = S4TH;
            S4TH:
                n_State = S5TH;
            S5TH:
                n_State = S6TH;
            S6TH:
                n_State = S7TH;
            S7TH:
                n_State = S8TH;
            S8TH:
                n_State = S9TH;
            S9TH:
                n_State = S10TH;
            S10TH:
                n_State = LAST;
            LAST:
                n_State = DONE;
            DONE:
                n_State = IDLE;
        endcase
    end


endmodule