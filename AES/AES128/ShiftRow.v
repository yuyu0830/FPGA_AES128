module ShiftRow(
    input [127:0] i_Data,
    output [127:0] o_Data,
    input i_fDec
);

    assign 
        o_Data[96+:32] = i_fDec ?
            {i_Data[15*8+:8], i_Data[ 2*8+:8], i_Data[ 5*8+:8], i_Data[ 8*8+:8]} :
            {i_Data[15*8+:8], i_Data[10*8+:8], i_Data[ 5*8+:8], i_Data[ 0*8+:8]},
            
        o_Data[64+:32] = i_fDec ?
            {i_Data[11*8+:8], i_Data[14*8+:8], i_Data[ 1*8+:8], i_Data[ 4*8+:8]} :
            {i_Data[11*8+:8], i_Data[ 6*8+:8], i_Data[ 1*8+:8], i_Data[12*8+:8]},

        o_Data[32+:32] = i_fDec ?
            {i_Data[ 7*8+:8], i_Data[10*8+:8], i_Data[13*8+:8], i_Data[ 0*8+:8]} :
            {i_Data[ 7*8+:8], i_Data[ 2*8+:8], i_Data[13*8+:8], i_Data[ 8*8+:8]},

        o_Data[ 0+:32] = i_fDec ?
            {i_Data[ 3*8+:8], i_Data[ 6*8+:8], i_Data[ 9*8+:8], i_Data[12*8+:8]} :
            {i_Data[ 3*8+:8], i_Data[14*8+:8], i_Data[ 9*8+:8], i_Data[ 4*8+:8]};

endmodule