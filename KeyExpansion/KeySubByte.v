module KeySubByte(
    input [31:0] i_Data,
    output [31:0] o_Data
);

genvar i;
generate
    for(i=0;i<31;i=i+8) begin :KeySubByte
        SBox Sb(i_Data[i +:8],o_Data[i +:8], 1'b0);
    end
endgenerate

endmodule