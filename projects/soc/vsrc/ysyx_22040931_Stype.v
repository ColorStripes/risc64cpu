//6.25 xuxin
`include "defines.v"

module ysyx_22040931_Stype(
    input wire [6 : 0] opcode,
    input wire [2 : 0] opcode_3,

    output wire [2 : 0]    memwop,
    output wire [`ysyx_22040931_ALU_BUS]    aluop,
    output wire [2 : 0]     exop,
    output wire            stype
);


    wire [12 : 0] out;
    wire [9 : 0] chose = {opcode_3, opcode};

    ysyx_22040931_MuxD #(4, 10, 13) Stype (out, chose, 13'b0000_0000_00000, {
    `ysyx_22040931_sd,  {1'b1,`ysyx_22040931_Stort,`ysyx_22040931_SORT,`ysyx_22040931_W_EIG},
    `ysyx_22040931_sw,  {1'b1,`ysyx_22040931_Stort,`ysyx_22040931_SORT,`ysyx_22040931_W_FOR},
    `ysyx_22040931_sh,  {1'b1,`ysyx_22040931_Stort,`ysyx_22040931_SORT,`ysyx_22040931_W_DOU},
    `ysyx_22040931_sb,  {1'b1,`ysyx_22040931_Stort,`ysyx_22040931_SORT,`ysyx_22040931_W_ONE}
    });


    assign memwop = out[2 : 0];
    assign aluop = out[8 : 3];
    assign exop = out[11 : 9];
    assign stype = out[12];

endmodule
