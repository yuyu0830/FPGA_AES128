
`timescale 1ns/1ns
module tb_AES;
reg 	Clk;
reg 	Rst;

/* inputs and outputs of DES module */
reg				AES_i_Start;
reg				AES_i_fEnc;
reg		[127:0]	AES_i_Key;
reg		[127:0]	AES_i_Text;
wire	[127:0]	AES_o_Data;
wire			AES_o_fDone;

/* temp variable to store the result */
reg		[127:0]	OutText;

parameter ENC = 1'b1, 	DEC = 1'b0;

/* Test vectors */
parameter KEY   = 128'h5468617473206D79204B756E67204675;
parameter PTEXT = 128'h54776F204F6E65204E696E652054776F;
parameter CTEXT = 128'h29C3505F571420F6402299B31A02D73A;

AES  AES0(
    .i_Clk(Clk), 
    .i_Rst(Rst),
    .i_fStart(AES_i_Start),
    .i_fEnc(AES_i_fEnc),
    .i_Text(AES_i_Text),
    .i_Key(AES_i_Key),
    .o_Data(AES_o_Data),
    .o_fDone(AES_o_fDone)
);

/* 10 MHz clock */
always
	#10	Clk = ~Clk;

initial
begin
	Clk = 1;
	Rst = 0;
	OutText		= 0;
	AES_i_Start	= 0;
	AES_i_fEnc	= 1;
	AES_i_Text	= 0;
	AES_i_Key	= 0;
	@(negedge Clk)	Rst = 1;
	RunAES(ENC, KEY, PTEXT);	
	RunAES(DEC, KEY, OutText);
end

task RunAES;
input			i_fDec;
input	[127:0]	i_Key;
input	[127:0]	i_Text;
begin
	AES_i_fEnc	= i_fDec;
	AES_i_Key	= i_Key;
	AES_i_Text	= i_Text;
    #100;
	@(posedge Clk)	AES_i_Start = 1;
	@(posedge Clk)	AES_i_Start = 0;
	@(posedge AES_o_fDone);
	@(negedge Clk)	OutText = AES_o_Data;
	$monitor("OutPut= %H \nCTEXT = %h",AES_o_Data,CTEXT);
end
endtask
endmodule
