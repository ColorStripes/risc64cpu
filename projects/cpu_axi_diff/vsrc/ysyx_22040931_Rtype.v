//2022.6.23 xuxin
`include "defines.v"

module ysyx_22040931_Rtype(
    input wire [6 : 0] opcode,
    input wire [2 : 0] opcode_3,
    input wire [6 : 0] opcode_7,
    
    output wire [`ysyx_22040931_ALU_BUS]    aluop,
    output wire [2 : 0]     exop,
    output wire            rtype
);
    wire [9 : 0] out;
    wire [16 : 0] chose = {opcode_7, opcode_3, opcode};
    
    ysyx_22040931_MuxD #(28, 17, 10) Rtype (out, chose, 10'b0000_0000_00, {
    `ysyx_22040931_add,    {1'b1,`ysyx_22040931_Arith,`ysyx_22040931_ADD},
    `ysyx_22040931_addw,   {1'b1,`ysyx_22040931_Short,`ysyx_22040931_ADD},
    `ysyx_22040931_and,    {1'b1,`ysyx_22040931_Arith,`ysyx_22040931_AND},
    `ysyx_22040931_sll,    {1'b1,`ysyx_22040931_Arith,`ysyx_22040931_SHIL},
    `ysyx_22040931_sllw,   {1'b1,`ysyx_22040931_Arith,`ysyx_22040931_SHILW},
    `ysyx_22040931_slt,    {1'b1,`ysyx_22040931_Arith,`ysyx_22040931_COM},
    `ysyx_22040931_sltu,   {1'b1,`ysyx_22040931_Arith,`ysyx_22040931_COMU},
    `ysyx_22040931_sra,    {1'b1,`ysyx_22040931_Arith,`ysyx_22040931_SRA},
    `ysyx_22040931_sraw,   {1'b1,`ysyx_22040931_Arith,`ysyx_22040931_SRAW},
    `ysyx_22040931_srl,    {1'b1,`ysyx_22040931_Arith,`ysyx_22040931_SHIR},
    `ysyx_22040931_srlw,   {1'b1,`ysyx_22040931_Arith,`ysyx_22040931_SHIRW},
    `ysyx_22040931_sub,    {1'b1,`ysyx_22040931_Arith,`ysyx_22040931_SUB},
    `ysyx_22040931_subw,   {1'b1,`ysyx_22040931_Short,`ysyx_22040931_SUB},
    `ysyx_22040931_xor,    {1'b1,`ysyx_22040931_Arith,`ysyx_22040931_XOR},
    `ysyx_22040931_remw,   {1'b1,`ysyx_22040931_Short,`ysyx_22040931_REMW},
    `ysyx_22040931_remuw,  {1'b1,`ysyx_22040931_Short,`ysyx_22040931_REMUW},
    `ysyx_22040931_remu,   {1'b1,`ysyx_22040931_Arith,`ysyx_22040931_REMU},
    `ysyx_22040931_rem,    {1'b1,`ysyx_22040931_Arith,`ysyx_22040931_REM},
    `ysyx_22040931_or,     {1'b1,`ysyx_22040931_Arith,`ysyx_22040931_OR},
    `ysyx_22040931_mul,    {1'b1,`ysyx_22040931_Arith,`ysyx_22040931_MUL},
    `ysyx_22040931_mulh,   {1'b1,`ysyx_22040931_Arith,`ysyx_22040931_MULH},
    `ysyx_22040931_mulhsu, {1'b1,`ysyx_22040931_Arith,`ysyx_22040931_MULHSU},
    `ysyx_22040931_mulhu,  {1'b1,`ysyx_22040931_Arith,`ysyx_22040931_MULHU},
    `ysyx_22040931_mulw,   {1'b1,`ysyx_22040931_Short,`ysyx_22040931_MULW},
    `ysyx_22040931_div,    {1'b1,`ysyx_22040931_Arith,`ysyx_22040931_DIV},
    `ysyx_22040931_divu,   {1'b1,`ysyx_22040931_Arith,`ysyx_22040931_DIVU},
    `ysyx_22040931_divuw,  {1'b1,`ysyx_22040931_Arith,`ysyx_22040931_DIVUW},
    `ysyx_22040931_divw,   {1'b1,`ysyx_22040931_Short,`ysyx_22040931_DIVW}
  });

    assign aluop = out[5 : 0];
    assign exop = out[8 : 6];
    assign rtype = out[9];

endmodule
