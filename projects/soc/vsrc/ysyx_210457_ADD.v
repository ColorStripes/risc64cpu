
//2021.8.3
//xu xin

`include "ysyx_210457_defines.v"

module ysyx_210457_ADD (
    input wire [63:0] num1,
    input wire [63:0] num2,

    output wire [63:0] sum
);
    assign sum = num1 + num2;

endmodule