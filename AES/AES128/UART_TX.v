module UART_TX(i_Clk,i_Rst,i_fTx,i_Data,o_fDone,o_fReady,o_Tx);
    input i_Clk,i_Rst,i_fTx;
    input [7:0] i_Data;

    output o_fDone,o_fReady,o_Tx;

reg [15:0] c_ClkCnt,n_ClkCnt;
reg [1:0] c_State,n_State;
reg [2:0] c_BitCnt,n_BitCnt;
reg [8:0] c_Data,n_Data;

wire fLstBit,fLstClk,fIncClkCnt,fIdle,fTxData;

parameter IDLE = 2'b00,
          TX_START = 2'b01,
          TX_Data = 2'b10,
          TX_STOP = 2'b11,
          CYCLES_PER_BIT = 434;

assign o_fDone = c_State == TX_STOP && fLstClk,
       o_fReady = c_State == IDLE,
       o_Tx = c_Data[0];

assign fLstClk = c_ClkCnt == CYCLES_PER_BIT,
       fLstBit = fLstClk && &c_BitCnt,
       fIncClkCnt = c_State != IDLE && !fLstClk,
       fIdle = c_State == IDLE,
       fTxData = c_State == TX_Data;

always@(posedge i_Clk,negedge i_Rst)
    if(!i_Rst)begin
        c_State = IDLE;
        c_BitCnt = 0;
        c_ClkCnt = 0;
        c_Data = -1;
    end else begin
        c_State = n_State;
        c_BitCnt = n_BitCnt;
        c_Data = n_Data;
        c_ClkCnt = n_ClkCnt;
    end

always@*
    begin

        n_ClkCnt = fIncClkCnt ? c_ClkCnt + 1 : 0;
        n_BitCnt = fTxData ? fLstClk ? c_BitCnt + 1 : c_BitCnt : 0;
        n_Data =  fIdle && i_fTx ? {i_Data, 1'b0} : fLstClk ? {1'b1, c_Data[8:1]} : c_Data;
        
        n_State = c_State;
        case(c_State)

            IDLE:begin
                if(i_fTx) n_State = TX_START;
                else n_State = IDLE;
            end

            TX_START:begin
                if(fLstClk) n_State = TX_Data;
                else n_State = TX_START;
            end

            TX_Data:begin
                if(fLstBit) n_State = TX_STOP;
                else n_State = TX_Data;
            end

            TX_STOP:begin
                n_State = fLstClk ? IDLE : TX_STOP;
            end

        endcase

    end

endmodule