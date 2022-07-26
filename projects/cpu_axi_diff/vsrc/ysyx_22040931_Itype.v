//6.25 xuxin
`include "defines.v"

module ysyx_22040931_Itype(
    input wire [6 : 0] opcode,
    input wire [2 : 0] opcode_3,
    input wire         opcode_1,
    input wire [6 : 0] opcode_7,
    

    output wire              jump,
    output wire [2 : 0]    memrop,
    output wire [`ysyx_22040931_ALU_BUS]    aluop,
    output wire [2 : 0]     exop,
    output wire            itype
);

    wire [13 : 0] out;
    wire [13 : 0] out1;
    wire [12 : 0] out2;
    wire [12 : 0] out3;
    wire [12 : 0] out4;

    wire [9 : 0]  chose1 = {opcode_3, opcode};
    wire [15 : 0] chose2 = {opcode_7[6 : 1], opcode_3, opcode};
    wire [16 : 0] chose3 = {opcode_7, opcode_3, opcode};
    wire [17 : 0] chose4 = {opcode_7, opcode_1, opcode_3, opcode};

    ysyx_22040931_MuxD #(4, 4, 14) Itype (out, {out1[13], out2[12], out3[12], out4[12]}, 14'b0000_0000_000000, {
        4'b1000,  out1,
        4'b0100,  {out2,1'b0},
        4'b0010,  {out3,1'b0},
        4'b0001,  {out4,1'b0}
    });
    
    ysyx_22040931_MuxD #(13, 10, 14) Itype1 (out1, chose1, 14'b0000_0000_000000, {
    `ysyx_22040931_addi,    {1'b1,`ysyx_22040931_Arith,`ysyx_22040931_ADD,`ysyx_22040931_MNO, 1'b0},
    `ysyx_22040931_addiw,   {1'b1,`ysyx_22040931_Short,`ysyx_22040931_ADD,`ysyx_22040931_MNO, 1'b0},
    `ysyx_22040931_andi,    {1'b1,`ysyx_22040931_Arith,`ysyx_22040931_AND,`ysyx_22040931_MNO, 1'b0},
    `ysyx_22040931_ld,      {1'b1,`ysyx_22040931_LOAD,`ysyx_22040931_ADD,`ysyx_22040931_R_EIG, 1'b0},
    `ysyx_22040931_lw,      {1'b1,`ysyx_22040931_LOAD,`ysyx_22040931_ADD,`ysyx_22040931_R_FOR, 1'b0},
    `ysyx_22040931_lh,      {1'b1,`ysyx_22040931_LOAD,`ysyx_22040931_ADD,`ysyx_22040931_R_DOU, 1'b0},
    `ysyx_22040931_lb,      {1'b1,`ysyx_22040931_LOAD,`ysyx_22040931_ADD,`ysyx_22040931_R_ONE, 1'b0},
    `ysyx_22040931_lwu,     {1'b1,`ysyx_22040931_LOAD,`ysyx_22040931_ADD,`ysyx_22040931_R_FORU, 1'b0},
    `ysyx_22040931_lhu,     {1'b1,`ysyx_22040931_LOAD,`ysyx_22040931_ADD,`ysyx_22040931_R_DOUU, 1'b0},
    `ysyx_22040931_lbu,     {1'b1,`ysyx_22040931_LOAD,`ysyx_22040931_ADD,`ysyx_22040931_R_ONEU, 1'b0},
    `ysyx_22040931_xori,    {1'b1,`ysyx_22040931_Arith,`ysyx_22040931_XOR,`ysyx_22040931_MNO, 1'b0},
    `ysyx_22040931_jalr,    {1'b1,`ysyx_22040931_Arith,`ysyx_22040931_JUMP,`ysyx_22040931_MNO, 1'b1},
    `ysyx_22040931_ori,     {1'b1,`ysyx_22040931_Arith,`ysyx_22040931_OR,`ysyx_22040931_MNO, 1'b0}
  });


    ysyx_22040931_MuxD #(3, 16, 13) Itype2 (out2, chose2, 13'b0000_0000_00000, {
    `ysyx_22040931_slli,    {1'b1,`ysyx_22040931_Arith,`ysyx_22040931_SHIL,`ysyx_22040931_MNO},
    `ysyx_22040931_srai,    {1'b1,`ysyx_22040931_Arith,`ysyx_22040931_SRA,`ysyx_22040931_MNO},
    `ysyx_22040931_srli,    {1'b1,`ysyx_22040931_Arith,`ysyx_22040931_SHIR,`ysyx_22040931_MNO}
  });



    ysyx_22040931_MuxD #(5, 17, 13) Itype3 (out3, chose3, 13'b0000_0000_00000, {
    `ysyx_22040931_slliw,   {1'b1,`ysyx_22040931_Short, `ysyx_22040931_SHILW, `ysyx_22040931_MNO},
    `ysyx_22040931_slti,    {1'b1,`ysyx_22040931_Arith, `ysyx_22040931_COM,   `ysyx_22040931_MNO},
    `ysyx_22040931_sltiu,   {1'b1,`ysyx_22040931_Arith, `ysyx_22040931_COMU,  `ysyx_22040931_MNO},
    `ysyx_22040931_sraiw,   {1'b1,`ysyx_22040931_Arith, `ysyx_22040931_SRAW,  `ysyx_22040931_MNO},
    `ysyx_22040931_srliw,   {1'b1,`ysyx_22040931_Arith, `ysyx_22040931_SHIRW, `ysyx_22040931_MNO}
  });

    ysyx_22040931_MuxD #(2, 18, 13) Itype4 (out4, chose4, 13'b0000_0000_00000, {
    `ysyx_22040931_ecall,   {1'b1,`ysyx_22040931_System,`ysyx_22040931_NO,    `ysyx_22040931_MNO},
    `ysyx_22040931_ebreak,  {1'b1,`ysyx_22040931_System,`ysyx_22040931_NO,    `ysyx_22040931_MNO}
    });

    assign jump = out[0];
    assign memrop = out[3 : 1];
    assign aluop = out[9 : 4];
    assign exop = out[12 : 10];
    assign itype = out[13];

endmodule
