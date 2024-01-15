module SHA(
    input i_Clk, i_Rst,
    input [511:0] i_Text,
    output [255:0] o_Text,
    input i_fStart,
    output o_fDone
);
    // function
    function [31:0] sig0 (input [31:0] x);      sig0 = {x[6:0], x[31:7]} ^ {x[17:0], x[31:18]} ^ {3'b0 , x[31:3]}; endfunction

    function [31:0] sig1 (input [31:0] x);      sig1 = {x[16:0], x[31:17]} ^ {x[18:0], x[31:19]} ^ {10'b0 , x[31:10]}; endfunction

    function [31:0] Maj (input [31:0] x, y, z); Maj = (x & y) ^ (x & z) ^ (y & z); endfunction

    function [31:0] Ch (input [31:0] x, y, z);  Ch = (x & y) ^ (~(x) & z); endfunction
    
    function [31:0] SIG0 (input [31:0] x);      SIG0 = {x[1:0], x[31:2]} ^ {x[12:0], x[31:13]} ^ {x[21:0], x[31:22]}; endfunction

    function [31:0] SIG1 (input [31:0] x);      SIG1 = {x[5:0], x[31:6]} ^ {x[10:0], x[31:11]} ^ {x[24:0], x[31:25]}; endfunction


    // parameter
    parameter
        IDLE     = 1'b0,
        ROUNDING = 1'b1;

    // register
    reg c_State, n_State;
    reg [511:0] c_W, n_W;
    reg [5:0]   c_Round, n_Round;
    reg [31:0]  c_PrevWord [7:0], n_PrevWord [7:0];
    reg [31:0]  c_a, n_a, c_b, n_b, c_c, n_c, c_d, n_d,
                c_e, n_e, c_f, n_f, c_g, n_g, c_h, n_h;

    reg [31:0]  r_Key;


    // wire
    wire [31:0] Word[15:0];
    wire [31:0] Msg, T1, T2;
    wire fWordGen, fLstRound, fIdle, fRounding;

    wire [31:0] newWord;

    // assign
    assign 
        Word[ 0] = c_W[15*32+:32],
        Word[ 1] = c_W[14*32+:32],
        Word[ 2] = c_W[13*32+:32],
        Word[ 3] = c_W[12*32+:32],
        Word[ 4] = c_W[11*32+:32],
        Word[ 5] = c_W[10*32+:32],
        Word[ 6] = c_W[ 9*32+:32],
        Word[ 7] = c_W[ 8*32+:32],
        Word[ 8] = c_W[ 7*32+:32],
        Word[ 9] = c_W[ 6*32+:32],
        Word[10] = c_W[ 5*32+:32],
        Word[11] = c_W[ 4*32+:32],
        Word[12] = c_W[ 3*32+:32],
        Word[13] = c_W[ 2*32+:32],
        Word[14] = c_W[ 1*32+:32],
        Word[15] = c_W[ 0*32+:32];

    assign 
        Msg = fWordGen ? Word[15] : Word[c_Round],
        T1 = c_h + SIG1(c_e) + Ch(c_e, c_f, c_g) + r_Key + Msg,
        T2 = SIG0(c_a) + Maj(c_a, c_b, c_c),
        newWord = Word[0] + sig0(Word[1]) + Word[9] + sig1(Word[14]);

    assign 
        fWordGen    = c_Round > 14,
        fLstRound   = &(c_Round),
        fIdle       = c_State == IDLE,
        fRounding   = c_State == ROUNDING,
        o_fDone     = fLstRound;

    assign o_Text  = o_fDone ? {(T1 + T2) + c_PrevWord[7], c_a + c_PrevWord[6], c_b + c_PrevWord[5], c_c + c_PrevWord[4], 
                                 c_d + T1 + c_PrevWord[3], c_e + c_PrevWord[2], c_f + c_PrevWord[1], c_g + c_PrevWord[0]} : 0;

    always@ (posedge i_Clk, negedge i_Rst)
        if (!i_Rst) begin
            c_State = IDLE;
            c_Round = 0;
            c_W = 0;
            c_a = 32'h6a09_e667; c_b = 32'hbb67_ae85; c_c = 32'h3c6e_f372; c_d = 32'ha54f_f53a;
            c_e = 32'h510e_527f; c_f = 32'h9b05_688c; c_g = 32'h1f83_d9ab; c_h = 32'h5be0_cd19;
            c_PrevWord[7] = 32'h6a09_e667; c_PrevWord[6] = 32'hbb67_ae85; c_PrevWord[5] = 32'h3c6e_f372; c_PrevWord[4] = 32'ha54f_f53a;
            c_PrevWord[3] = 32'h510e_527f; c_PrevWord[2] = 32'h9b05_688c; c_PrevWord[1] = 32'h1f83_d9ab; c_PrevWord[0] = 32'h5be0_cd19;
        end else begin
            c_State = n_State;
            c_Round = n_Round;
            c_W = n_W;
            c_a = n_a; c_b = n_b; c_c = n_c; c_d = n_d;
            c_e = n_e; c_f = n_f; c_g = n_g; c_h = n_h;
            c_PrevWord[7] = n_PrevWord[7]; c_PrevWord[6] = n_PrevWord[6]; c_PrevWord[5] = n_PrevWord[5]; c_PrevWord[4] = n_PrevWord[4];
            c_PrevWord[3] = n_PrevWord[3]; c_PrevWord[2] = n_PrevWord[2]; c_PrevWord[1] = n_PrevWord[1]; c_PrevWord[0] = n_PrevWord[0];
        end

    always@*
    begin
        n_Round = c_State == ROUNDING ? c_Round + 1 : 0;

        n_W = 
            fIdle & i_fStart ? i_Text : 
            fWordGen ? {c_W[479:0], newWord} : c_W;

        n_h = fRounding ? c_g       : c_h;
        n_g = fRounding ? c_f       : c_g;
        n_f = fRounding ? c_e       : c_f;
        n_e = fRounding ? c_d + T1  : c_e;
        n_d = fRounding ? c_c       : c_d;
        n_c = fRounding ? c_b       : c_c;
        n_b = fRounding ? c_a       : c_b;
        n_a = fRounding ? T1 + T2   : c_a;

        n_PrevWord[7] = o_fDone ? o_Text[7*32+:32] : c_PrevWord[7];
        n_PrevWord[6] = o_fDone ? o_Text[6*32+:32] : c_PrevWord[6];
        n_PrevWord[5] = o_fDone ? o_Text[5*32+:32] : c_PrevWord[5];
        n_PrevWord[4] = o_fDone ? o_Text[4*32+:32] : c_PrevWord[4];
        n_PrevWord[3] = o_fDone ? o_Text[3*32+:32] : c_PrevWord[3];
        n_PrevWord[2] = o_fDone ? o_Text[2*32+:32] : c_PrevWord[2];
        n_PrevWord[1] = o_fDone ? o_Text[1*32+:32] : c_PrevWord[1];
        n_PrevWord[0] = o_fDone ? o_Text[0*32+:32] : c_PrevWord[0];

        n_State = c_State;
        case(c_State)
            IDLE:       n_State = i_fStart ? ROUNDING : c_State;

            ROUNDING:   n_State = fLstRound ? IDLE : c_State;

        endcase

        case(c_Round)
            6'd00: r_Key = 32'h428a2f98; 6'd01: r_Key = 32'h71374491; 6'd02: r_Key = 32'hb5c0fbcf; 6'd03: r_Key = 32'he9b5dba5; 
            6'd04: r_Key = 32'h3956c25b; 6'd05: r_Key = 32'h59f111f1; 6'd06: r_Key = 32'h923f82a4; 6'd07: r_Key = 32'hab1c5ed5; 
            6'd08: r_Key = 32'hd807aa98; 6'd09: r_Key = 32'h12835b01; 6'd10: r_Key = 32'h243185be; 6'd11: r_Key = 32'h550c7dc3;
            6'd12: r_Key = 32'h72be5d74; 6'd13: r_Key = 32'h80deb1fe; 6'd14: r_Key = 32'h9bdc06a7; 6'd15: r_Key = 32'hc19bf174; 
                            
            6'd16: r_Key = 32'he49b69c1; 6'd17: r_Key = 32'hefbe4786; 6'd18: r_Key = 32'h0fc19dc6; 6'd19: r_Key = 32'h240ca1cc; 
            6'd20: r_Key = 32'h2de92c6f; 6'd21: r_Key = 32'h4a7484aa; 6'd22: r_Key = 32'h5cb0a9dc; 6'd23: r_Key = 32'h76f988da;
            6'd24: r_Key = 32'h983e5152; 6'd25: r_Key = 32'ha831c66d; 6'd26: r_Key = 32'hb00327c8; 6'd27: r_Key = 32'hbf597fc7; 
            6'd28: r_Key = 32'hc6e00bf3; 6'd29: r_Key = 32'hd5a79147; 6'd30: r_Key = 32'h06ca6351; 6'd31: r_Key = 32'h14292967; 
                        
            6'd32: r_Key = 32'h27b70a85; 6'd33: r_Key = 32'h2e1b2138; 6'd34: r_Key = 32'h4d2c6dfc; 6'd35: r_Key = 32'h53380d13;
            6'd36: r_Key = 32'h650a7354; 6'd37: r_Key = 32'h766a0abb; 6'd38: r_Key = 32'h81c2c92e; 6'd39: r_Key = 32'h92722c85; 
            6'd40: r_Key = 32'ha2bfe8a1; 6'd41: r_Key = 32'ha81a664b; 6'd42: r_Key = 32'hc24b8b70; 6'd43: r_Key = 32'hc76c51a3; 
            6'd44: r_Key = 32'hd192e819; 6'd45: r_Key = 32'hd6990624; 6'd46: r_Key = 32'hf40e3585; 6'd47: r_Key = 32'h106aa070;
                            
            6'd48: r_Key = 32'h19a4c116; 6'd49: r_Key = 32'h1e376c08; 6'd50: r_Key = 32'h2748774c; 6'd51: r_Key = 32'h34b0bcb5; 
            6'd52: r_Key = 32'h391c0cb3; 6'd53: r_Key = 32'h4ed8aa4a; 6'd54: r_Key = 32'h5b9cca4f; 6'd55: r_Key = 32'h682e6ff3; 
            6'd56: r_Key = 32'h748f82ee; 6'd57: r_Key = 32'h78a5636f; 6'd58: r_Key = 32'h84c87814; 6'd59: r_Key = 32'h8cc70208;
            6'd60: r_Key = 32'h90befffa; 6'd61: r_Key = 32'ha4506ceb; 6'd62: r_Key = 32'hbef9a3f7; 6'd63: r_Key = 32'hc67178f2;
        endcase
    end
endmodule




