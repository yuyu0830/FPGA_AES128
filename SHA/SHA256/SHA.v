module SHA(
    input i_Clk, i_Rst,
    input [511:0] i_Text,
    output [255:0] o_Text,
    input i_fStart,
    input i_fFirst,
    output o_fDone
);
    // function
    function [31:0] sig0 (input [31:0] x);      sig0 = {x[6:0], x[31:7]} ^ {x[17:0], x[31:18]} ^ {3'b0 , x[31:3]}; endfunction

    function [31:0] sig1 (input [31:0] x);      sig1 = {x[16:0], x[31:17]} ^ {x[18:0], x[31:19]} ^ {10'b0 , x[31:10]}; endfunction

    function [31:0] Maj (input [31:0] x, y, z); Maj = (x & y) ^ (x & z) ^ (y & z); endfunction

    function [31:0] Ch (input [31:0] x, y, z);  Ch = (x & y) ^ (~(x) & z); endfunction
    
    function [31:0] SIG0 (input [31:0] x);      SIG0 = {x[1:0], x[31:2]} ^ {x[12:0], x[31:13]} ^ {x[21:0], x[31:22]}; endfunction

    function [31:0] SIG1 (input [31:0] x);      SIG1 = {x[5:0], x[31:6]} ^ {x[10:0], x[31:11]} ^ {x[24:0], x[31:25]}; endfunction

    function [31:0] KeySelect (input [31:0] Round);
        KeySelect = 
            Round[5] ?
                Round[4] ? 
                    Round[3] ?
                        Round[2] ?
                            Round[1] ? (Round[0] ? 32'hc67178f2 : 32'hbef9a3f7) : (Round[0] ? 32'ha4506ceb : 32'h90befffa) :
                            Round[1] ? (Round[0] ? 32'h8cc70208 : 32'h84c87814) : (Round[0] ? 32'h78a5636f : 32'h748f82ee) :
                        Round[2] ?
                            Round[1] ? (Round[0] ? 32'h682e6ff3 : 32'h5b9cca4f) : (Round[0] ? 32'h4ed8aa4a : 32'h391c0cb3) :
                            Round[1] ? (Round[0] ? 32'h34b0bcb5 : 32'h2748774c) : (Round[0] ? 32'h1e376c08 : 32'h19a4c116) :
                    Round[3] ?
                        Round[2] ?
                            Round[1] ? (Round[0] ? 32'h106aa070 : 32'hf40e3585) : (Round[0] ? 32'hd6990624 : 32'hd192e819) :
                            Round[1] ? (Round[0] ? 32'hc76c51a3 : 32'hc24b8b70) : (Round[0] ? 32'ha81a664b : 32'ha2bfe8a1) :
                        Round[2] ?
                            Round[1] ? (Round[0] ? 32'h92722c85 : 32'h81c2c92e) : (Round[0] ? 32'h766a0abb : 32'h650a7354) :
                            Round[1] ? (Round[0] ? 32'h53380d13 : 32'h4d2c6dfc) : (Round[0] ? 32'h2e1b2138 : 32'h27b70a85) :
                Round[4] ? 
                    Round[3] ?
                        Round[2] ?
                            Round[1] ? (Round[0] ? 32'h14292967 : 32'h06ca6351) : (Round[0] ? 32'hd5a79147 : 32'hc6e00bf3) :
                            Round[1] ? (Round[0] ? 32'hbf597fc7 : 32'hb00327c8) : (Round[0] ? 32'ha831c66d : 32'h983e5152) :
                        Round[2] ?
                            Round[1] ? (Round[0] ? 32'h76f988da : 32'h5cb0a9dc) : (Round[0] ? 32'h4a7484aa : 32'h2de92c6f) :
                            Round[1] ? (Round[0] ? 32'h240ca1cc : 32'h0fc19dc6) : (Round[0] ? 32'hefbe4786 : 32'he49b69c1) :
                    Round[3] ?
                        Round[2] ?
                            Round[1] ? (Round[0] ? 32'hc19bf174 : 32'h9bdc06a7) : (Round[0] ? 32'h80deb1fe : 32'h72be5d74) :
                            Round[1] ? (Round[0] ? 32'h550c7dc3 : 32'h243185be) : (Round[0] ? 32'h12835b01 : 32'hd807aa98) :
                        Round[2] ?
                            Round[1] ? (Round[0] ? 32'hab1c5ed5 : 32'h923f82a4) : (Round[0] ? 32'h59f111f1 : 32'h3956c25b) :
                            Round[1] ? (Round[0] ? 32'he9b5dba5 : 32'hb5c0fbcf) : (Round[0] ? 32'h71374491 : 32'h428a2f98);
    endfunction


    // parameter
    parameter
        IDLE     = 2'h0,
        ROUNDING = 2'h1,
        DONE     = 2'h2;

    parameter
        IV       = 512'h6a09_e667_bb67_ae85_3c6e_f372_a54f_f53a_510e_527f_9b05_688c_1f83_d9ab_5be0_cd19;


    // register
    reg [1:0]   c_State, n_State;
    reg [511:0] c_W, n_W;
    reg [5:0]   c_Round, n_Round;
    reg [255:0] c_Digest, n_Digest;
    reg [31:0]  c_a, n_a, c_b, n_b, c_c, n_c, c_d, n_d,
                c_e, n_e, c_f, n_f, c_g, n_g, c_h, n_h;


    // wire
    wire [31:0] Word[15:0];
    wire [31:0] T1, T2;
    wire fLstRound, fIdle, fRounding;

    wire [31:0] newWord;
    wire [31:0] Key;

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

    assign Key = KeySelect(c_Round);

    assign 
        T1 = c_h + SIG1(c_e) + Ch(c_e, c_f, c_g) + Key + Word[0],
        T2 = SIG0(c_a) + Maj(c_a, c_b, c_c),
        newWord = Word[0] + sig0(Word[1]) + Word[9] + sig1(Word[14]);

    assign 
        fLstRound   = &(c_Round),
        fIdle       = c_State == IDLE,
        fRounding   = c_State == ROUNDING,
        o_fDone     = c_State == DONE;

    assign o_Text  = o_fDone ? {c_a + c_Digest[7*32+:32], c_b + c_Digest[6*32+:32], 
                                c_c + c_Digest[5*32+:32], c_d + c_Digest[4*32+:32], 
                                c_e + c_Digest[3*32+:32], c_f + c_Digest[2*32+:32], 
                                c_g + c_Digest[1*32+:32], c_h + c_Digest[0*32+:32]} : 0;

    always@ (posedge i_Clk, negedge i_Rst)
        if (!i_Rst) begin
            c_State = IDLE;
            c_Round = 0;
            c_W     = 0;
            c_a = 0; c_b = 0; c_c = 0; c_d = 0;
            c_e = 0; c_f = 0; c_g = 0; c_h = 0;
            c_Digest = 0;
        end else begin
            c_State = n_State;
            c_Round = n_Round;
            c_W = n_W;
            c_a = n_a; c_b = n_b; c_c = n_c; c_d = n_d;
            c_e = n_e; c_f = n_f; c_g = n_g; c_h = n_h;
            c_Digest = n_Digest;
        end

    always@*
    begin
        n_Round = fRounding ? c_Round + 1 : 0;

        n_W = 
            fIdle & i_fStart ? i_Text : 
            fRounding ? {c_W[479:0], newWord} : c_W;

        n_h = i_fStart ? (i_fFirst ? IV[0*32+:32] : c_Digest[0*32+:32]) : (fRounding ? c_g       : c_h);
        n_g = i_fStart ? (i_fFirst ? IV[1*32+:32] : c_Digest[1*32+:32]) : (fRounding ? c_f       : c_g);
        n_f = i_fStart ? (i_fFirst ? IV[2*32+:32] : c_Digest[2*32+:32]) : (fRounding ? c_e       : c_f);
        n_e = i_fStart ? (i_fFirst ? IV[3*32+:32] : c_Digest[3*32+:32]) : (fRounding ? c_d + T1  : c_e);
        n_d = i_fStart ? (i_fFirst ? IV[4*32+:32] : c_Digest[4*32+:32]) : (fRounding ? c_c       : c_d);
        n_c = i_fStart ? (i_fFirst ? IV[5*32+:32] : c_Digest[5*32+:32]) : (fRounding ? c_b       : c_c);
        n_b = i_fStart ? (i_fFirst ? IV[6*32+:32] : c_Digest[6*32+:32]) : (fRounding ? c_a       : c_b);
        n_a = i_fStart ? (i_fFirst ? IV[7*32+:32] : c_Digest[7*32+:32]) : (fRounding ? T1 + T2   : c_a);

        n_Digest = i_fFirst ? IV : (o_fDone ? o_Text : c_Digest);

        n_State = c_State;
        case(c_State)
            IDLE:       n_State = i_fStart ? ROUNDING : c_State;

            ROUNDING:   n_State = fLstRound ? DONE : c_State;

            DONE:       n_State = IDLE;

        endcase
    end
endmodule