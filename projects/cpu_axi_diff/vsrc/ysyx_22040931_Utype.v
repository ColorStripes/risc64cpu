//6.28 xuxin
`include "defines.v"

module ysyx_22040931_Utype(
    input wire [6 : 0] opcode,

    output wire [`ysyx_22040931_ALU_BUS]    aluop,
    output wire [2 : 0]     exop,
    output wire            utype
);

    wire [6 : 0] chose = opcode;
    wire [9 : 0] out;

    ysyx_22040931_MuxD #(2, 7, 10) Utype (out, chose, 10'b0000_0000_00, {
    `ysyx_22040931_auipc,  {1'b1,`ysyx_22040931_Arith,`ysyx_22040931_PC},
    `ysyx_22040931_lui,    {1'b1,`ysyx_22040931_LUI  ,`ysyx_22040931_NO}
    });

    assign aluop = out[5 : 0];
    assign exop = out[8 : 6];
    assign utype = out[9];


endmodule
