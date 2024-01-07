`timescale 1 ns / 1 ns
module	tb_AES_Top();

parameter	DW = 16 * 8;

reg	Clk;
reg	Rst;

wire			TOP_i_Rx;
wire			TOP_o_Tx;

reg				Tx_i_fTx;
reg		[ 7:0]	Tx_i_Data;		// 1 byte to transmit
wire			Tx_o_fDone;		// when transmition is o_fDone
wire			Tx_o_fReady;	// when there is no data to transmit

wire			Rx_o_fDone;		// when there is received data
wire	[7:0]	Rx_o_Data;			// received byte 

reg	[DW-1:0]	r_RxData;

parameter	SET_KEY	= 8'h00,
			ENC		= 8'h02,
			DEC		= 8'h03;
parameter	KEY   = 128'h54686174_73206D79_204B756E_67204675,
			PTEXT = 128'h54776F20_4F6E6520_4E696E65_2054776F,
			CTEXT = 128'h29C3505F_571420F6_402299B3_1A02D73A;

integer i;

AES_TOP	TOP(Clk, Rst, TOP_i_Rx, TOP_o_Tx);
UART_TX TX0(Clk, Rst, Tx_i_fTx, Tx_i_Data,	Tx_o_fDone, Tx_o_fReady, TOP_i_Rx);
UART_RX RX0(Clk, Rst,			TOP_o_Tx,	Rx_o_fDone, Rx_o_Data);

always
	#10 Clk = ~Clk;

initial
begin
	Clk			= 1;
	Rst			= 0;
	Tx_i_fTx	= 0;
	Tx_i_Data	= 0;

	@(negedge Clk)	Rst = 1;
	TxByte(SET_KEY);	TxBytes(KEY, 16);	RxByte();
	TxByte(ENC);		TxBytes(PTEXT, 16);	RxByte();	RxBytes(16);

	Rst = 0;
	@(negedge Clk)	Rst = 1;
	TxByte(SET_KEY);	TxBytes(KEY, 16);	RxByte();
	TxByte(DEC);		TxBytes(CTEXT, 16);	RxByte();	RxBytes(16);

	#5000 $stop;
end

task TxByte;
input	[7:0]	i_Data;
begin
	wait(Tx_o_fReady)	Tx_i_fTx = 1;	Tx_i_Data = i_Data;
	@(posedge Clk)		Tx_i_fTx = 0;	
	@(posedge Tx_o_fDone);
end
endtask

task TxBytes;
input	[DW-1:0]	i_Data;
input	[15:0]		i_Len;
reg		[DW-1:0]	r_Data;
begin
	r_Data = i_Data;
	for(i = i_Len ; i < DW / 8 ; i = i + 1)
		r_Data = {r_Data, 8'b0};

	for(i = 0 ; i < i_Len ; i = i + 1) begin
		TxByte(r_Data[DW-1:DW-8]);
		r_Data = {r_Data, 8'b0};
	end	
	$display("Tx: %x", i_Data);
end
endtask

task RxByte;
begin
	@(posedge Rx_o_fDone);
	r_RxData = {r_RxData, Rx_o_Data};
	@(negedge Rx_o_fDone);
end
endtask

task RxBytes;
input	[31:0]	i_len;
begin
	for(i = 0 ; i < i_len ; i=i+1)	RxByte();
	$display("Rx: %x", r_RxData);
end
endtask
endmodule

