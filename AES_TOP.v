module AES_TOP(
    input i_Clk, i_Rst,
    input i_Rx,
    output o_Tx);

    // parameter
    parameter 
        IDLE        = 3'b000,
        RX_KEY      = 3'b001,
        RX_TEXT     = 3'b010,
        AES_START   = 3'b011,
        AES_WAIT    = 3'b100,
        TX_RES      = 3'b101,
        TX_TEXT     = 3'b110;


    // register
    reg [2:0] c_State, n_State;
    reg [3:0] c_ByteCnt, n_ByteCnt;
    reg [1:0] c_Cmd, n_Cmd;
    reg [127:0] c_Key, n_Key, c_Text, n_Text;


    // wire
    wire fIdle, fRxKey, fRxText, fAesStart, 
         fAesWait, fTxRes, fTxText;

    wire [7:0] Tx_i_Data, Rx_o_Data;
    wire [127:0] AES_o_Data;

    wire Rx_o_fDone;
    wire Tx_i_fTx;
    wire Tx_o_fDone, Tx_o_fRdy;
    
    wire AES_i_fDec;
    wire AES_o_fDone;

    wire fLstByte;


    // Module
    AES AES0(i_Clk, i_Rst, fAesStart, AES_i_fDec, c_Text, c_Key, AES_o_Data, AES_o_fDone);

    UART_RX URX0(i_Clk, i_Rst, i_Rx, Rx_o_fDone, Rx_o_Data);
    UART_TX UTX0(i_Clk, i_Rst, Tx_i_fTx, Tx_i_Data, Tx_o_fDone, Tx_o_fRdy, o_Tx);


    // assign
    assign 
        fLstByte     = &c_ByteCnt,
        Tx_i_fTx     = Tx_o_fRdy && (c_State == TX_RES || c_State == TX_TEXT),
        Tx_i_Data    = c_State == TX_RES ? c_Cmd : c_Text[127:120],
        AES_i_fDec   = c_Cmd[0];

    assign
        fIdle       = c_State == IDLE,
        fRxKey      = c_State == RX_KEY,
        fRxText     = c_State == RX_TEXT,
        fAesStart   = c_State == AES_START,
        fAesWait    = c_State == AES_WAIT,
        fTxRes      = c_State == TX_RES,
        fTxText     = c_State == TX_TEXT;


    always@ (posedge i_Clk, negedge i_Rst)
        if (!i_Rst) begin
            c_State     = IDLE;
            c_ByteCnt   = 0;
            c_Cmd       = 0;
            c_Key       = 0;
            c_Text      = 0;
        end else begin
            c_State     = n_State;
            c_ByteCnt   = n_ByteCnt;
            c_Cmd       = n_Cmd;
            c_Key       = n_Key;
            c_Text      = n_Text;
        end
    

    always@*
    begin
        n_Cmd   = fIdle & Rx_o_fDone ? Rx_o_Data : c_Cmd;
        n_Text  = 
            fRxText  & Rx_o_fDone  ? {c_Text[120:0], Rx_o_Data} :
            fAesWait & AES_o_fDone ? AES_o_Data :
            fTxText  & Tx_o_fDone  ? {c_Text[120:0], Rx_o_Data} : c_Text;
        n_Key   = fRxKey & Rx_o_fDone ? {c_Key[120:0], Rx_o_Data} : c_Key;

        n_ByteCnt =
             fIdle   & fTxRes ? 0 :
            ((fRxKey | fRxText) & Rx_o_fDone) | (fTxText & Tx_o_fDone) ? c_ByteCnt + 1 : c_ByteCnt;

        n_State = c_State;
        case(c_State)
            IDLE:       n_State = Rx_o_fDone ? (Rx_o_Data[1] ? RX_TEXT : RX_KEY) : c_State;

            RX_KEY:     n_State = Rx_o_fDone && fLstByte ? TX_RES : c_State;

            RX_TEXT:    n_State = Rx_o_fDone && fLstByte ? AES_START : c_State;

            AES_START:  n_State = AES_WAIT;

            AES_WAIT:   n_State = AES_o_fDone ? TX_RES : c_State;
            
            TX_RES:     n_State = Tx_o_fDone ? (c_Cmd[1] ? TX_TEXT : IDLE) : c_State;
            
            TX_TEXT:    n_State = Tx_o_fDone && fLstByte ? IDLE : c_State;
        endcase
    end
endmodule
