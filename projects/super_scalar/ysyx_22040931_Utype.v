//6.28 xuxin
`include "defines.v"

module Utype(
    input wire [6 : 0] opcode,

    output wire [`ALU_BUS]    aluop,
    output wire [2 : 0]     exop,
    output wire            utype
);

    wire [6 : 0] chose = opcode;
    wire [9 : 0] out;

    MuxD #(2, 7, 10) Utype (out, chose, 10'b0000_0000_00, {
    `auipc,  {1'b1,`Arith,`PC},
    `lui,    {1'b1,`Lui  ,`NO}
    });

    assign aluop = out[5 : 0];
    assign exop = out[8 : 6];
    assign utype = out[9];


endmodule
