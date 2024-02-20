module fFunction(
    input [63:0] i_Data, i_Key,
    output [63:0] o_Data
);
    //wire
    wire [31:0] C, D;
    wire [31:0] G0_in, G0_out, G1_in, G1_out, G2_in, G2_out;


    //module
    gFunction g0(G0_in, G0_out);
    gFunction g1(G1_in, G1_out);
    gFunction g2(G2_in, G2_out);


    //assign
    assign
        C   = i_Data[63:32] ^ i_Key[63:32],
        D   = i_Data[31: 0] ^ i_key[31: 0];

    assign 
        G0_in = D ^ C,
        G1_in = C + G0_out,
        G2_in = G1_out ^ G2_out;

    assign
        o_Data = {G1_out + G2_out, G2_out};


endmodule