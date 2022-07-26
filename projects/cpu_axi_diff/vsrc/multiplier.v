//2022.7.22 xuxin
`include "defines.v"

module multiplier(

    input wire mulw,
    input wire mulena,
    input wire mul_signed,
    input wire mul_signor,
    input wire [63 : 0] multiplicand,
    input wire [63 : 0] multiplier,


    output reg [63 : 0] result_hi,
    output reg [63 : 0] result_lo
);

wire [64 : 0] multiplicand_s, multiplier_s;
assign multiplicand_s = mulena ? (mulw ? (mul_signed ? {{33{multiplicand[31]}}, multiplicand[31 : 0]} : {33'b0, multiplicand[31 : 0]}) : 
                                        (mul_signed ? {multiplicand[63], multiplicand} : {1'b0, multiplicand}))
                               :  65'h0;
assign multiplier_s   = mulena ? (mulw ? (mul_signor ? {{33{multiplier[31]}}, multiplier[31 : 0]} : {33'b0, multiplier[31 : 0]}) : 
                                         (mul_signor ? {multiplier[63], multiplier} : {1'b0, multiplier}))
                               :  65'h0;

wire [131 : 0] p[32 : 0];
booth booth(
    .multiplicand(multiplicand_s),
    .multiplier(multiplier_s),

    .p(p)
);


wire [131 : 0] sum, cout, result;
walloc_33in walloc_33in(
    .src_in(p),


    .s(sum),
    .cout(cout)
);

   assign result = sum + cout;

   assign result_hi = result[127 : 64];
   assign result_lo = result[63 : 0];




endmodule
