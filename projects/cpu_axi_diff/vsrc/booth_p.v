//2022.7.22 xuxin
`include "defines.v"

module booth_p(
    input wire [133 : 0] x_src, //{1'bf, 132 , 1'b0}
    input wire [2 : 0] y_3,

    output wire [131 : 0] p
);

    
    booth_select booth_select(

        .y_3(y_3),

        .sel_negative(sel_negative),
        .sel_double_negative(sel_double_negative),
        .sel_positive(sel_positive),
        .sel_double_positive(sel_double_positive)

    );

    wire sel_negative,sel_double_negative,sel_positive,sel_double_positive;
    genvar i;
    generate
    for(i = 0; i < 132; i = i + 1) begin
        booth_pi booth_pi(  x_src[i+2 : i], 
                            sel_negative, 
                            sel_double_negative, 
                            sel_positive, 
                            sel_double_positive, 
                            product[i]
                         );
    end
    endgenerate


    wire [131 : 0] product;
    assign p = (sel_negative | sel_double_negative) ? product + 1 : product;

endmodule
