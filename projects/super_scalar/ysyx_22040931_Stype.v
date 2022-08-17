//6.25 xuxin
`include "defines.v"

module Stype(
    input wire [6 : 0] opcode,
    input wire [2 : 0] opcode_3,

    output wire [2 : 0]    memwop,
    output wire [`ALU_BUS]    aluop,
    output wire [2 : 0]     exop,
    output wire            stype
);


    wire [12 : 0] out;
    wire [9 : 0] chose = {opcode_3, opcode};

    MuxD #(4, 10, 13) Stype (out, chose, 13'b0000_0000_00000, {
    `sd,  {1'b1,`Stort,`SORT,`W_EIG},
    `sw,  {1'b1,`Stort,`SORT,`W_FOR},
    `sh,  {1'b1,`Stort,`SORT,`W_DOU},
    `sb,  {1'b1,`Stort,`SORT,`W_ONE}
    });


    assign memwop = out[2 : 0];
    assign aluop = out[8 : 3];
    assign exop = out[11 : 9];
    assign stype = out[12];

endmodule
