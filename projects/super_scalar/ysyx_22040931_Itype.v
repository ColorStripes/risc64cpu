//6.25 xuxin
`include "defines.v"

module Itype(
    input wire [6 : 0] opcode,
    input wire [2 : 0] opcode_3,
    input wire [4 : 0] opcode_5,
    input wire [6 : 0] opcode_7,
    
    output wire [`EXCEPT_BUS] except,////
    output wire              jump,
    output wire [2 : 0]    memrop,
    output wire [`ALU_BUS]  aluop,
    output wire [2 : 0]     exop,
    output wire            itype
);

    wire [13 : 0] out;
    wire [13 : 0] out1;
    wire [12 : 0] out2;
    wire [12 : 0] out3;
    wire [19 : 0] out4;

    wire [9 : 0]  chose1 = {opcode_3, opcode};
    wire [15 : 0] chose2 = {opcode_7[6 : 1], opcode_3, opcode};
    wire [16 : 0] chose3 = {opcode_7, opcode_3, opcode};
    wire [21 : 0] chose4 = {opcode_7, opcode_5, opcode_3, opcode};

    MuxD #(4, 4, 14) Itype (out, {out1[13], out2[12], out3[12], out4[12]}, 14'b0000_0000_000000, {
        4'b1000,  out1,
        4'b0100,  {out2,1'b0},
        4'b0010,  {out3,1'b0},
        4'b0001,  {out4[19 : 7],1'b0}
    });
    
    MuxD #(15, 10, 14) Itype1 (out1, chose1, 14'b0000_0000_000000, {
    `addi,    {1'b1,`Arith,  `ADD,  `MNO,    1'b0},
    `addiw,   {1'b1,`Short,  `ADD,  `MNO,    1'b0},
    `andi,    {1'b1,`Arith,  `AND,  `MNO,    1'b0},
    `ld,      {1'b1,`Load,   `ADD,  `R_EIG,  1'b0},
    `lw,      {1'b1,`Load,   `ADD,  `R_FOR,  1'b0},
    `lh,      {1'b1,`Load,   `ADD,  `R_DOU,  1'b0},
    `lb,      {1'b1,`Load,   `ADD,  `R_ONE,  1'b0},
    `lwu,     {1'b1,`Load,   `ADD,  `R_FORU, 1'b0},
    `lhu,     {1'b1,`Load,   `ADD,  `R_DOUU, 1'b0},
    `lbu,     {1'b1,`Load,   `ADD,  `R_ONEU, 1'b0},
    `xori,    {1'b1,`Arith,  `XOR,  `MNO,    1'b0},
    `jalr,    {1'b1,`Arith,  `JUMP, `MNO,    1'b1},
    `ori,     {1'b1,`Arith,  `OR,   `MNO,    1'b0},
    `slti,    {1'b1,`Arith,  `COM,  `MNO,    1'b0},
    `sltiu,   {1'b1,`Arith,  `COMU, `MNO,    1'b0}
  });


    MuxD #(3, 16, 13) Itype2 (out2, chose2, 13'b0000_0000_00000, {
    `slli,    {1'b1,`Arith,`SHIL,`MNO},
    `srai,    {1'b1,`Arith,`SRA, `MNO},
    `srli,    {1'b1,`Arith,`SHIR,`MNO}
  });



    MuxD #(3, 17, 13) Itype3 (out3, chose3, 13'b0000_0000_00000, {
    `slliw,   {1'b1,`Short, `SHILW, `MNO},
    `sraiw,   {1'b1,`Short, `SRAW,  `MNO},
    `srliw,   {1'b1,`Short, `SHIRW, `MNO}
  });

    MuxD #(3, 22, 20) Itype4 (out4, chose4, 20'b0000_0000_00000_0000000, {
    `ecall,   {1'b1,`System, `NO, `MNO, `ECALL },
    `ebreak,  {1'b1,`System, `NO, `MNO, `EBREAK},
    `mret,    {1'b1,`System, `NO, `MNO, `MRET  }
  });

    assign jump = out[0];
    assign memrop = out[3 : 1];
    assign aluop = out[9 : 4];
    assign exop = out[12 : 10];
    assign itype = out[13];
    assign except = out4[`EXCEPT_BUS];

endmodule
