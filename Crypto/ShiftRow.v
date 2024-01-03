module ShiftRow(
    input [127:0] i_Data,
    output [127:0] o_Data,
    input i_fEncrypt
);

    wire [31:0] Word0, Word1, Word2, Word3;

    assign 
        Word0 = i_fEncrypt ?
            {i_Data[127:120], i_Data[87:80], i_Data[47:40], i_Data[7:0]} :
            {i_Data[127:120], i_Data[23:16], i_Data[47:40], i_Data[71:64]},
        Word1 = i_fEncrypt ?
            {i_Data[95:88], i_Data[55:48], i_Data[15:8], i_Data[103:96]} :
            {i_Data[95:88], i_Data[119:112], i_Data[15:8], i_Data[39:32]},
        Word2 = i_fEncrypt ?
            {i_Data[63:56], i_Data[23:16], i_Data[111:104], i_Data[71:64]} :
            {i_Data[63:56], i_Data[87:80], i_Data[111:104], i_Data[7:0]},
        Word3 = i_fEncrypt ?
            {i_Data[31:24], i_Data[119:112], i_Data[79:72], i_Data[39:32]} :
            {i_Data[31:24], i_Data[55:48], i_Data[79:72], i_Data[103:96]};

    assign o_Data = {Word0, Word1, Word2, Word3};

endmodule