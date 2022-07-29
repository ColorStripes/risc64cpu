//2022.7.22 xuxin
`include "defines.v"

module booth_pi(
    input wire [2 : 0] x_3,

    input wire sel_negative,
    input wire sel_double_negative,
    input wire sel_positive,
    input wire sel_double_positive,

    output wire pi
);

//x+1,x,x-1
wire x_add, x_non, x_sub;
assign {x_add,x_non,x_sub} = x_3;
//pi
assign pi = ~(~(sel_negative & ~x_non) & ~(sel_double_negative & ~x_sub) 
           & ~(sel_positive & x_non ) & ~(sel_double_positive &  x_sub));


endmodule
