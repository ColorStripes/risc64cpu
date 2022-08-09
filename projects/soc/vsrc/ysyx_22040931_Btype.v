//6.27 xuxin
`include "defines.v"

module ysyx_22040931_Btype(
    input wire [6 : 0] opcode,
    input wire [2 : 0] opcode_3,
    input wire [`ysyx_22040931_DATA_BUS] r_data1,
    input wire [`ysyx_22040931_DATA_BUS] r_data2,

    output wire             jump,
    output wire [`ysyx_22040931_ALU_BUS]    aluop,
    output wire [2 : 0]     exop,
    output wire            btype
);


    wire [9 : 0] chose = {opcode_3, opcode};
    wire [9 : 0] out;
    wire [2 : 0] jumpb;

    assign jumpb[2] = {r_data1 - r_data2}[63];
    assign jumpb[1] = {{1'b0, r_data1} - {1'b0, r_data2}}[64];
    assign jumpb[0] = (r_data1 == r_data2) ? 1'b0 : 1'b1;

    ysyx_22040931_MuxD #(6, 10, 1) Jump_b (jump, chose, 1'b0, {
    `ysyx_22040931_beq,   ~jumpb[0],
    `ysyx_22040931_bge,   ~jumpb[2],
    `ysyx_22040931_bgeu,  ~jumpb[1],
    `ysyx_22040931_blt,   jumpb[2],
    `ysyx_22040931_bltu,  jumpb[1],
    `ysyx_22040931_bne,   jumpb[0]
    });


    ysyx_22040931_MuxD #(6, 10, 10) Btype (out, chose, 10'b0000_0000_0000_0, {
    `ysyx_22040931_beq,  {1'b1,`ysyx_22040931_No,`ysyx_22040931_NO},
    `ysyx_22040931_bge,  {1'b1,`ysyx_22040931_No,`ysyx_22040931_NO},
    `ysyx_22040931_bgeu, {1'b1,`ysyx_22040931_No,`ysyx_22040931_NO},
    `ysyx_22040931_blt,  {1'b1,`ysyx_22040931_No,`ysyx_22040931_NO},
    `ysyx_22040931_bltu, {1'b1,`ysyx_22040931_No,`ysyx_22040931_NO},
    `ysyx_22040931_bne,  {1'b1,`ysyx_22040931_No,`ysyx_22040931_NO}
    });


    //assign jump = out[0];
    assign aluop = out[5 : 0];
    assign exop = out[8 : 6];
    assign btype = out[9];


endmodule
