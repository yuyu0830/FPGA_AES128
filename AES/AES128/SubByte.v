module SubByte(
    input [127:0] i_Data,
    output [127:0] o_Data,
    input i_fDec
);

    SBox Sb0(i_Data[ 0*8+:8], o_Data[ 0*8+:8], i_fDec);
    SBox Sb1(i_Data[ 1*8+:8], o_Data[ 1*8+:8], i_fDec);
    SBox Sb2(i_Data[ 2*8+:8], o_Data[ 2*8+:8], i_fDec);
    SBox Sb3(i_Data[ 3*8+:8], o_Data[ 3*8+:8], i_fDec);
    SBox Sb4(i_Data[ 4*8+:8], o_Data[ 4*8+:8], i_fDec);
    SBox Sb5(i_Data[ 5*8+:8], o_Data[ 5*8+:8], i_fDec);
    SBox Sb6(i_Data[ 6*8+:8], o_Data[ 6*8+:8], i_fDec);
    SBox Sb7(i_Data[ 7*8+:8], o_Data[ 7*8+:8], i_fDec);
    SBox Sb8(i_Data[ 8*8+:8], o_Data[ 8*8+:8], i_fDec);
    SBox Sb9(i_Data[ 9*8+:8], o_Data[ 9*8+:8], i_fDec);
    SBox SbA(i_Data[10*8+:8], o_Data[10*8+:8], i_fDec);
    SBox SbB(i_Data[11*8+:8], o_Data[11*8+:8], i_fDec);
    SBox SbC(i_Data[12*8+:8], o_Data[12*8+:8], i_fDec);
    SBox SbD(i_Data[13*8+:8], o_Data[13*8+:8], i_fDec);
    SBox SbE(i_Data[14*8+:8], o_Data[14*8+:8], i_fDec);
    SBox SbF(i_Data[15*8+:8], o_Data[15*8+:8], i_fDec);

endmodule
