module DES_Top(i_Clk,i_Rst,i_Rx,o_Tx,o_LED);
  input i_Clk,i_Rst,i_Rx;
  output [7:0] o_LED;
  output o_Tx;
  
  parameter IDLE = 3'b000,
            RX_KEY = 3'b001,
            RX_TEXT = 3'b010,
            START_DES = 3'b011,
            WAIT_DES = 3'b100,
            TX_RES = 3'b101,
            TX_TEXT = 3'b110;

  reg [2:0] c_State,n_State,c_ByteCnt,n_ByteCnt;
  reg [1:0] c_Cmd,n_Cmd;
  reg [63:0] c_Key,n_Key,c_Text,n_Text;

  wire [7:0] Tx_i_Data,Rx_o_Data;
  wire [63:0] DES_o_Data;
  wire Rx_o_fDone,Tx_o_fDone,Tx_o_fRdy,DES_o_fDone; 
  wire fLstByte,Tx_i_fTx,DES_i_fStart,DES_i_fDec; 

  assign fLstByte = &c_ByteCnt,
         Tx_i_fTx = Tx_o_fRdy && (c_State == TX_RES || c_State == TX_TEXT),
         Tx_i_Data = c_State == TX_RES ? c_Cmd : c_Text[63:56],
         DES_i_fStart = c_State == START_DES,
         DES_i_fDec = c_Cmd[0],
         o_LED = {5'b00000,c_State}; 

  DES DES0(i_Clk,i_Rst,DES_i_fStart,DES_i_fDec,c_Key,c_Text,DES_o_fDone,DES_o_Data);
  UART_RX URX0(i_Clk,i_Rst,i_Rx,Rx_o_fDone,Rx_o_Data);
  UART_TX UTX0(i_Clk,i_Rst,Tx_i_fTx,Tx_i_Data,Tx_o_fDone,Tx_o_fRdy,o_Tx);

  always@(posedge i_Clk,negedge i_Rst)
    if(!i_Rst)begin
        c_State = IDLE;
        c_ByteCnt = 0;
        c_Cmd = 0;
        c_Key = 0;
        c_Text = 0;
    end 
    else begin
        c_State = n_State;
        c_ByteCnt = n_ByteCnt;
        c_Cmd = n_Cmd;
        c_Key = n_Key;
        c_Text = n_Text;
    end

  always@*
    begin
        n_State = c_State;
        n_Cmd = c_State == IDLE ? Rx_o_fDone ? Rx_o_Data : c_Cmd : c_Cmd;
        n_Key = c_State == RX_KEY ? Rx_o_fDone ? {c_Key[55:0],Rx_o_Data} : c_Key : c_Key;
        case(c_State)
            IDLE:begin
                n_ByteCnt = 0;
                n_Text = c_Text;
                if(Rx_o_fDone)begin
                    if(Rx_o_Data[1]) n_State = RX_TEXT;
                    else n_State = RX_KEY;
                end
                else n_State = IDLE;
            end
            RX_KEY:begin
                n_ByteCnt = Rx_o_fDone ? c_ByteCnt + 1 : c_ByteCnt;
                n_Text = c_Text;
                if(Rx_o_fDone && fLstByte) n_State = TX_RES;
                else n_State = RX_KEY;
            end
            RX_TEXT:begin
                n_ByteCnt = Rx_o_fDone ? c_ByteCnt + 1 : c_ByteCnt;
                n_Text = Rx_o_fDone ? {c_Text[55:0],Rx_o_Data} : c_Text;
                if(Rx_o_fDone && fLstByte) n_State = START_DES;
                else n_State = RX_TEXT;
            end
            START_DES:begin
                n_Text = c_Text;
                n_ByteCnt = 0;
                n_State = WAIT_DES;
            end
            WAIT_DES:begin
                n_Text = DES_o_fDone ? DES_o_Data : c_Text;
                n_ByteCnt = 0;
                if(DES_o_fDone) n_State = TX_RES;
                else n_State = WAIT_DES;
            end
            TX_RES:begin
                n_Text = c_Text;
                n_ByteCnt = 0;
                if(Tx_o_fDone)begin
                    if(c_Cmd[1]) n_State = TX_TEXT;
                    else n_State = IDLE;
                end
                else n_State = TX_RES;
            end
            TX_TEXT:begin
                n_Text = Tx_o_fDone ? {c_Text[55:0],Rx_o_Data} : c_Text;
                n_ByteCnt = Tx_o_fDone ? c_ByteCnt + 1 : c_ByteCnt;
                if(Tx_o_fDone && fLstByte) n_State = IDLE;
                else n_State = TX_TEXT;
            end
        endcase
    end

endmodule
