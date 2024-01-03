module SubByte(
    input [127:0] i_Data,
    output [127:0] o_Data,
    input fEnc
);

genvar i;

generate
    for(i=0;i<128;i=i+8) begin
        SBox Sb(i_Data[i +:8],o_Data[i +:8],fEnc);
    end
endgenerate

endmodule
