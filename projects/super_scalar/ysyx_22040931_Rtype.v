//2022.6.23 xuxin
`include "defines.v"

module Rtype(
    input wire [6 : 0] opcode,
    input wire [2 : 0] opcode_3,
    input wire [6 : 0] opcode_7,
    
    output wire [`ALU_BUS]    aluop,
    output wire [2 : 0]     exop,
    output wire            rtype
);
    wire [9 : 0] out;
    wire [16 : 0] chose = {opcode_7, opcode_3, opcode};
    
    MuxD #(28, 17, 10) Rtype (out, chose, 10'b0000_0000_00, {
    `add,    {1'b1,`Arith,`ADD},
    `addw,   {1'b1,`Short,`ADD},
    `and,    {1'b1,`Arith,`AND},
    `sll,    {1'b1,`Arith,`SHIL},
    `sllw,   {1'b1,`Short,`SHILW},
    `slt,    {1'b1,`Arith,`COM},
    `sltu,   {1'b1,`Arith,`COMU},
    `sra,    {1'b1,`Arith,`SRA},
    `sraw,   {1'b1,`Arith,`SRAW},
    `srl,    {1'b1,`Arith,`SHIR},
    `srlw,   {1'b1,`Short,`SHIRW},
    `sub,    {1'b1,`Arith,`SUB},
    `subw,   {1'b1,`Short,`SUB},
    `xor,    {1'b1,`Arith,`XOR},
    `remw,   {1'b1,`Short,`REMW},
    `remuw,  {1'b1,`Short,`REMUW},
    `remu,   {1'b1,`Arith,`REMU},
    `rem,    {1'b1,`Arith,`REM},
    `or,     {1'b1,`Arith,`OR},
    `mul,    {1'b1,`Arith,`MUL},
    `mulh,   {1'b1,`Arith,`MULH},
    `mulhsu, {1'b1,`Arith,`MULHSU},
    `mulhu,  {1'b1,`Arith,`MULHU},
    `mulw,   {1'b1,`Short,`MULW},
    `div,    {1'b1,`Arith,`DIV},
    `divu,   {1'b1,`Arith,`DIVU},
    `divuw,  {1'b1,`Arith,`DIVUW},
    `divw,   {1'b1,`Short,`DIVW}
  });

    assign aluop = out[5 : 0];
    assign exop = out[8 : 6];
    assign rtype = out[9];

endmodule
