module MixCol(
    input [127:0] i_State,
    output reg [127:0] o_State,
    input i_fDec
);

parameter shift3 = 3,
          shift2 = 2,
          shift1 = 1;        

function [7:0] hex02(input [7:0] state,input integer n);
    begin
        case(n)
            default:begin
                state = state[7] ? (({state[6:0],1'b0})^8'h1b) : {state[6:0],1'b0};
            end
            shift2:begin
                state = state[7] ? (({state[6:0],1'b0})^8'h1b) : {state[6:0],1'b0};
                state = state[7] ? (({state[6:0],1'b0})^8'h1b) : {state[6:0],1'b0};
            end
            shift3:begin
                state = state[7] ? (({state[6:0],1'b0})^8'h1b) : {state[6:0],1'b0};
                state = state[7] ? (({state[6:0],1'b0})^8'h1b) : {state[6:0],1'b0};
                state = state[7] ? (({state[6:0],1'b0})^8'h1b) : {state[6:0],1'b0};
            end
        endcase
        hex02 = state;
    end      
endfunction

function [7:0] hex03; 
    input [7:0] state;
    begin
        hex03 = hex02(state,shift1) ^ state;
    end
    
endfunction

function [7:0] hex0e; 
    input [7:0] state;
    begin
        hex0e = hex02(state,shift3) ^ hex02(state,shift2) ^ hex02(state,shift1);
    end
    
endfunction

function [7:0] hex0b; 
    input [7:0] state;
    begin
        hex0b = hex02(state,shift3) ^ hex02(state,shift1) ^ state;
    end
    
endfunction

function [7:0] hex0d; 
    input [7:0] state;
    begin
        hex0d = hex02(state,shift3) ^ hex02(state,shift2) ^ state;
    end
    
endfunction

function [7:0] hex09; 
    input [7:0] state;
    begin
        hex09 = hex02(state,shift3) ^ state;
    end
endfunction

function [31:0] enc_State;
    input[31:0] state;
    begin
        enc_State = {  hex02(state[24+:8],1) ^ hex03(state[16+:8]) ^ state[8+:8]        ^ state[0+:8],                   
                       state[24+:8]        ^ hex02(state[16+:8],1) ^ hex03(state[8+:8]) ^ state[0+:8],                   
                       state[24+:8]        ^ state[16+:8]        ^ hex02(state[8+:8],1) ^ hex03(state[0+:8]),            
                       hex03(state[24+:8]) ^ state[16+:8]        ^ state[8+:8]        ^ hex02(state[0+:8],1)};     
    end
endfunction

function [31:0] dec_State;
    input[31:0] state;
    begin
        dec_State = { hex0e(state[24+:8]) ^ hex0b(state[16+:8]) ^ hex0d(state[8+:8]) ^ hex09(state[0+:8]),                
                      hex09(state[24+:8]) ^ hex0e(state[16+:8]) ^ hex0b(state[8+:8]) ^ hex0d(state[0+:8]),               
                      hex0d(state[24+:8]) ^ hex09(state[16+:8]) ^ hex0e(state[8+:8]) ^ hex0b(state[0+:8]),               
                      hex0b(state[24+:8]) ^ hex0d(state[16+:8]) ^ hex09(state[8+:8]) ^ hex0e(state[0+:8])};                    
    end
endfunction


always@(*) begin
    if(i_fDec) begin
        o_State[0+:128] = {dec_State(i_State[96+:32]),dec_State(i_State[64+:32]),dec_State(i_State[32+:32]),dec_State(i_State[0+:32])};
    end 
    else begin
        o_State[0+:128] = {enc_State(i_State[96+:32]),enc_State(i_State[64+:32]),enc_State(i_State[32+:32]),enc_State(i_State[0+:32])};
    end
end
endmodule
