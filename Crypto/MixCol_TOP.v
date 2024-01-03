module MixCol_Top(
   input [127:0] i_Data,
   output [127:0] o_Data,
   input fEnc
);

wire [127:0] MixCol_o_Data;
wire [127:0] InvMixCol_o_Data;

assign o_Data = fEnc ? MixCol_o_Data : InvMixCol_o_Data;

MixCol MC(i_Data,MixCol_o_Data);

InvMixCol IMC(i_Data,InvMixCol_o_Data);



endmodule