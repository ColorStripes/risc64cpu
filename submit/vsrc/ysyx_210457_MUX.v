//xuxin
//2021.8.3
`include "defines.v"

module ysyx_210457_MUX (
    input wire [`REG_BUS] data1,
    input wire [`REG_BUS] data2,
    input wire ch,


    output wire [`REG_BUS] data
);
    assign data =(ch == 1)? data2 : data1;
    
endmodule