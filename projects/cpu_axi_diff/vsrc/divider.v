//2022.7.20 xuxin
`include "defines.v"

module divider(
    input wire clock,
    input wire reset,
    //woshou
    input wire id_valid,
    input wire ex_ready,
    output reg div_valid,
    output wire div_ready,
    //sign
    input wire w,
    input wire div_ena,
    input wire div_signed,
    input wire [63 : 0] dividend,
    input wire [63 : 0] divisor,


    output wire [63 : 0] quotient,
    output wire [63 : 0] remainder
);

    reg [127 : 0] dividend_reg;
    reg [63 : 0] quotient_reg;
    reg [64 : 0] remainder_reg;
    reg [6 : 0] count;

    //1
    wire [63 : 0] abs_dividend, abs_divisor;
    wire quotient_signed, remainder_signed;
    assign abs_dividend = div_signed ? (dividend[63] ? ~dividend+1 : dividend) : dividend; 
    assign abs_divisor =  div_signed ? (divisor[63]  ? ~divisor+1  : divisor)  : divisor;
    assign quotient_signed = divisor[63] ^ dividend[63];  //1- 0+
    assign remainder_signed = dividend[63];


    //2
    wire [64 : 0] sub_64;
    assign sub_64 = {dividend_reg[127 : 63] - {1'b0, abs_divisor}};
    //32
    wire [32 : 0] sub_32;
    assign sub_32 = {dividend_reg[63 : 31] - {1'b0, abs_divisor[31 : 0]}};

    always@(posedge clock) begin
        if(reset == 1'b1) begin
            dividend_reg <= 0;
            quotient_reg <= 0;
            remainder_reg <= 0;
            div_valid <= 0;
            count <= 0;
        end
        else begin
            if(div) begin
                if(w) begin
                    dividend_reg <= {64'b0, 32'b0, abs_dividend[31 : 0]};
                    count <= 33;
                end
                else begin
                    dividend_reg <= {64'b0, abs_dividend};
                    count <= 1;
                end
            end
            else if(count != 0) begin
                    
                if(w) begin
                    quotient_reg <= {32'b0, quotient_reg[30 : 0], ~sub_32[32]};
                    remainder_reg <= {32'b0, sub_32};
                    if(sub_32[32]) begin
                        dividend_reg <= dividend_reg << 1;
                    end
                    else begin
                        dividend_reg <= {64'b0, sub_32, dividend_reg[30 : 0]} << 1;
                    end
                end
                else begin
                    quotient_reg <= {quotient_reg[62 : 0], ~sub_64[64]};
                    remainder_reg <= sub_64;
                    if(sub_64[64]) begin
                        dividend_reg <= dividend_reg << 1;
                    end
                    else begin
                        dividend_reg <= {sub_64, dividend_reg[62 : 0]} << 1;
                    end
                end
                
                if(count == 64) begin
                    div_valid <= 1'b1;
                    count <= 0;
                end
                else begin
                    count <= count + 1;
                end

            end
        end
    end


    
    //3
    wire [63 : 0] quotient_64;
    assign quotient_64 =  div_signed ? (quotient_signed  ? ~quotient_reg + 1  : quotient_reg)  : quotient_reg;
    //quotient_result;
    assign quotient = w ? {32'b0, quotient_64[31 : 0]} : quotient_64;

    wire [63 : 0] last_remainder_64;
    assign last_remainder_64 = remainder_reg[64] ? dividend_reg[127 : 64] : remainder_reg[63 : 0];
    wire [63 : 0] remainder_64;
    assign remainder_64 = div_signed ? (remainder_signed ? ~last_remainder_64 + 1 : last_remainder_64) : last_remainder_64;
    //32
    wire [31 : 0] last_remainder_32;
    assign last_remainder_32 = remainder_reg[32] ? dividend_reg[63 : 32] : remainder_reg[31 : 0];
    wire [31 : 0] remainder_32;
    assign remainder_32 = div_signed ? (remainder_signed ? ~last_remainder_32 + 1 : last_remainder_32) : last_remainder_32;
    //remainder_result;
    assign remainder = w ? {{32{remainder_32[31]}}, remainder_32} : remainder_64;

    //4
    wire div;
    assign div = (id_valid && ~div_valid && (count == 0) ) ? div_ena : 1'b0; //start

    assign div_ready = div_valid & ex_ready;
    always @(posedge clock) begin
        if(reset == 1) begin
            div_valid <= 0;
        end
        else if(div_ready) begin
            div_valid <= 0;
            quotient_reg <= 0;
            remainder_reg <= 0;
        end
    end

endmodule
