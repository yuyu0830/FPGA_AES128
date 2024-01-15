module KeySubByte(
    input [31:0] i_Data,
    output [31:0] o_Data
);

SBox SB0(i_Data[24+:8],o_Data[24+:8], 1'b0);
SBox SB1(i_Data[16+:8],o_Data[16+:8], 1'b0);
SBox SB2(i_Data[ 8+:8],o_Data[ 8+:8], 1'b0);
SBox SB3(i_Data[ 0+:8],o_Data[ 0+:8], 1'b0);

endmodule