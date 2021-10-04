//2021.8.3
//xu xin
`include "defines.v"

module ADD (
    input wire [63:0] num1,
    input wire [63:0] num2,

    output wire [63:0] sum
);
    assign sum = num1 + num2;

endmodule