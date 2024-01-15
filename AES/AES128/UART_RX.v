module UART_RX(i_Clk,i_Rst,i_Rx,o_fDone,o_Data);
    input i_Clk,i_Rst,i_Rx;

    output [7:0] o_Data;
    output o_fDone;

    wire fLstClk,fLstBit,fCapture,fIncClkCnt;
    wire fCaptureData,fRxData;

    reg c_Rx,n_Rx;
    reg [7:0] c_Data,n_Data;
    reg [15:0] c_ClkCnt,n_ClkCnt;
    reg [2:0] c_BitCnt,n_BitCnt;
    reg [1:0] c_State,n_State;
    
    
    parameter IDLE = 2'b00,
              RX_START = 2'b01,
              RX_DATA = 2'b10,
              RX_STOP = 2'b11,
              CYCLES_PER_BIT = 434;

    assign  fLstClk = c_ClkCnt == CYCLES_PER_BIT,
            fCapture = c_ClkCnt == CYCLES_PER_BIT/2,
            fLstBit = fLstClk && &c_BitCnt,
            o_fDone = c_State == RX_STOP,
            o_Data = c_Data,
            fIncClkCnt = !fLstClk && (c_State == RX_START || c_State == RX_DATA),
            fCaptureData = fCapture && c_State == RX_DATA ;

    always@(posedge i_Clk,negedge i_Rst)
        if(!i_Rst)begin
            c_Rx = 0;
            c_Data = 0;
            c_State = IDLE;
            c_ClkCnt = 0;
            c_BitCnt = 0;
        end else begin
            c_Rx = n_Rx;
            c_Data = n_Data;
            c_State = n_State;
            c_ClkCnt = n_ClkCnt;
            c_BitCnt = n_BitCnt;
        end

    always@*
        begin  
            n_Rx = i_Rx;
            n_ClkCnt = fIncClkCnt ? c_ClkCnt + 1 : 0;
            n_Data = c_Data;
            n_State = c_State;
            case(c_State)
                IDLE: begin
                  n_ClkCnt = 0;
                    if(!c_Rx) n_State = RX_START;
                    else n_State = IDLE;
                end
                RX_START: begin
                    n_BitCnt = 0;
                    if(fLstClk) n_State = RX_DATA;
                    else if(fCapture && c_Rx) n_State = IDLE;
                    else n_State = RX_START;
                end
                RX_DATA: begin
                    n_BitCnt = fLstClk ? c_BitCnt + 1 : c_BitCnt;
                    n_Data = fCaptureData ? {c_Rx, c_Data[7:1]} : c_Data;
                    if(fLstBit) n_State = RX_STOP;
                    else n_State = RX_DATA;
                end
                RX_STOP: begin
                    n_Data = c_Data;
                    n_State = IDLE;
                end
            endcase
        end
endmodule