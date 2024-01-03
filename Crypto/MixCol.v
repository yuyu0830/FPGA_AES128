module MixCol(
    input [127:0] i_Data,
    output [127:0] o_Data
);

function [7:0] multiplyb2;
    input [7:0] mb2;
    begin
        if(mb2[7] == 1) multiplyb2 = (({mb2[6:0],1'b0})^8'h1b);
        else multiplyb2 = {mb2[6:0],1'b0};
    end
    
endfunction


function [7:0] multiplyb3; 
    input [7:0] mb3;
    begin
        multiplyb3 = multiplyb2(mb3)^mb3;
    end
    
endfunction

genvar i;

generate
    for(i=0;i<4;i=i+1)begin
        assign o_Data[(i*32 + 24)+:8] = multiplyb2(i_Data[(i*32 + 24)+:8]) ^ multiplyb3(i_Data[(i*32 + 16)+:8]) ^ i_Data[(i*32 + 8)+:8] ^ i_Data[i*32+:8];
        assign o_Data[(i*32 + 16)+:8] = i_Data[(i*32 + 24)+:8] ^ multiplyb2(i_Data[(i*32 + 16)+:8]) ^ multiplyb3(i_Data[(i*32 + 8)+:8]) ^ i_Data[i*32+:8];
        assign o_Data[(i*32 + 8)+:8] = i_Data[(i*32 + 24)+:8] ^ i_Data[(i*32 + 16)+:8] ^ multiplyb2(i_Data[(i*32 + 8)+:8]) ^ multiplyb3(i_Data[i*32+:8]);
        assign o_Data[i*32+:8] = multiplyb3(i_Data[(i*32 + 24)+:8]) ^ i_Data[(i*32 + 16)+:8] ^ i_Data[(i*32 + 8)+:8] ^ multiplyb2(i_Data[i*32+:8]);
    end
endgenerate


endmodule