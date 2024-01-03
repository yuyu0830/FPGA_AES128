module InvMixCol(
    input [127:0] i_Data,
    output [127:0] o_Data
);

function [7:0] multiplyb(input [7:0] mb,input integer n);
    integer i;
    begin
        for(i=0;i<n;i=i+1) begin
            if(mb[7] == 1) mb = (({mb[6:0],1'b0})^8'h1b);
            else mb = {mb[6:0],1'b0};
        end
        multiplyb = mb;
    end

endfunction

function [7:0] multiplyb0e;
    input [7:0] mb0e;
    begin
        multiplyb0e = multiplyb(mb0e,3)^multiplyb(mb0e,2)^multiplyb(mb0e,1);
    end

endfunction

function [7:0] multiplyb0b;
    input [7:0] mb0b;
    begin
        multiplyb0b = multiplyb(mb0b,3)^multiplyb(mb0b,1)^mb0b;
    end

endfunction


function [7:0] multiplyb0d;
    input [7:0] mb0d;
    begin
        multiplyb0d = multiplyb(mb0d,3)^multiplyb(mb0d,2)^mb0d;
    end

endfunction


function [7:0] multiplyb09;
    input [7:0] mb09;
    begin
        multiplyb09 = multiplyb(mb09,3)^mb09;
    end

endfunction

genvar i;

generate
    for(i=0;i<4;i=i+1)begin
     assign o_Data[(i*32 + 24)+:8] = multiplyb0e(i_Data[(i*32 + 24)+:8]) ^ multiplyb0b(i_Data[(i*32 + 16)+:8]) ^ multiplyb0d(i_Data[(i*32 + 8)+:8]) ^ multiplyb09(i_Data[(i*32)+:8]);
     assign o_Data[(i*32 + 16)+:8] = multiplyb09(i_Data[(i*32 + 24)+:8]) ^ multiplyb0e(i_Data[(i*32 + 16)+:8]) ^ multiplyb0b(i_Data[(i*32 + 8)+:8]) ^ multiplyb0d(i_Data[(i*32)+:8]);
     assign o_Data[(i*32 + 8)+:8] = multiplyb0d(i_Data[(i*32 + 24)+:8]) ^ multiplyb09(i_Data[(i*32 + 16)+:8]) ^ multiplyb0e(i_Data[(i*32 + 8)+:8]) ^ multiplyb0b(i_Data[(i*32)+:8]);
     assign o_Data[(i*32)+:8] = multiplyb0b(i_Data[(i*32 + 24)+:8]) ^ multiplyb0d(i_Data[(i*32 + 16)+:8]) ^ multiplyb09(i_Data[(i*32 + 8)+:8]) ^ multiplyb0e(i_Data[(i*32)+:8]);    
    end
endgenerate

endmodule