//2022.7.22 xuxin
`include "defines.v"

module booth_select(
    
    input wire [2 : 0] y_3,

    output wire sel_negative,
    output wire sel_double_negative,
    output wire sel_positive,
    output wire sel_double_positive

);



///y+1,y,y-1///
wire y_add, y_non, y_sub;
assign {y_add,y_non,y_sub} = y_3;

assign sel_negative =  y_add & (y_non & ~y_sub | ~y_non & y_sub);
assign sel_positive = ~y_add & (y_non & ~y_sub | ~y_non & y_sub);
assign sel_double_negative =  y_add & ~y_non & ~y_sub;
assign sel_double_positive = ~y_add &  y_non &  y_sub;


endmodule
