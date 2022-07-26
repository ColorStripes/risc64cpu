//2022.6.24 xuxin
`include "defines.v"


module ysyx_22040931_ALU(
    input wire reset,
    input wire clock,
    input wire id_valid,
    input wire ex_ready,
    output wire alu_valid,
    output wire alu_ready,
    input wire [`ysyx_22040931_DATA_BUS] num1,
    input wire [`ysyx_22040931_DATA_BUS] num2,
    input wire [`ysyx_22040931_DATA_BUS] imm,
    input wire [`ysyx_22040931_PC_BUS]    pc,
    input wire [`ysyx_22040931_ALU_BUS] op,


    output wire [`ysyx_22040931_DATA_BUS] out
);

wire signed [63 : 0] num1_s;
wire signed [31 : 0] num1_sw;
wire signed [63 : 0] num2_s;
wire signed [31 : 0] num2_sw;

assign num1_s = num1;
assign num2_s = num2;
assign num1_sw = num1[31 : 0];
assign num2_sw = num2[31 : 0];

//DIV   
    wire [2 : 0] d_m_ena;
    ysyx_22040931_MuxD #(8, `ysyx_22040931_ALU, 3) D_M_ENA (d_m_ena, op, {1'b0, 1'b0, 1'b0}, {  //{w, ena, sign}
    `ysyx_22040931_REMW  ,  {1'b1, 1'b1, 1'b1},
    `ysyx_22040931_REMUW ,  {1'b1, 1'b1, 1'b0},
    `ysyx_22040931_REMU  ,  {1'b0, 1'b1, 1'b0},
    `ysyx_22040931_REM   ,  {1'b0, 1'b1, 1'b1},
    `ysyx_22040931_DIV   ,  {1'b0, 1'b1, 1'b1},
    `ysyx_22040931_DIVU  ,  {1'b0, 1'b1, 1'b0},
    `ysyx_22040931_DIVUW ,  {1'b1, 1'b1, 1'b0},
    `ysyx_22040931_DIVW  ,  {1'b1, 1'b1, 1'b1}
    });

    assign alu_valid = d_m_ena[1] ? div_valid : 1'b1;
    assign alu_ready = d_m_ena[1] ? div_ready : 1'b1;

    wire [`ysyx_22040931_DATA_BUS] quotient, remainder;
    wire div_valid, div_ready;
    divider divider(
    .clock(clock),
    .reset(reset),
    .id_valid(id_valid),
    .ex_ready(ex_ready),
    .div_valid(div_valid),
    .div_ready(div_ready),

    .w(d_m_ena[2]),
    .div_ena(d_m_ena[1]),
    .div_signed(d_m_ena[0]),
    .dividend(num1),
    .divisor(num2),

    .quotient(quotient),
    .remainder(remainder)
    );


// //MUL
//     wire [3 : 0] m_m_sign;
//     ysyx_22040931_MuxD #(5, `ysyx_22040931_ALU, 4) M_M_ENA (m_m_sign, op, {1'b0, 1'b0, 1'b0, 1'b0}, {  //{w, ena, sign_ed, sign_or}
//     `ysyx_22040931_MUL   ,  {1'b0, 1'b1, 1'b1, 1'b1},
//     `ysyx_22040931_MULH  ,  {1'b0, 1'b1, 1'b1, 1'b1},
//     `ysyx_22040931_MULHSU,  {1'b0, 1'b1, 1'b1, 1'b0},
//     `ysyx_22040931_MULHU ,  {1'b0, 1'b1, 1'b0, 1'b0},
//     `ysyx_22040931_MULW  ,  {1'b1, 1'b1, 1'b1, 1'b1}
//     });

//     wire [`ysyx_22040931_DATA_BUS] result_hi, result_lo;
//     multiplier multiplier(

//     .mulw(m_m_sign[3]),
//     .mulena(m_m_sign[2]),
//     .mul_signed(m_m_sign[1]),
//     .mul_signor(m_m_sign[0]),
//     .multiplicand(num1),
//     .multiplier(num2),


//     .result_hi(result_hi),
//     .result_lo(result_lo)
// );



// //ALU
//     ysyx_22040931_MuxD #(29, `ysyx_22040931_ALU, 64) ALU (out, op, `ysyx_22040931_ZERO_NUM, {
//     `ysyx_22040931_ADD   ,  num1 + num2,
//     `ysyx_22040931_SUB   ,  num1 - num2,
//     `ysyx_22040931_AND   ,  num1 & num2,
//     `ysyx_22040931_XOR   ,  num1 ^ num2,
//     `ysyx_22040931_OR    ,  num1 | num2,
//     `ysyx_22040931_COM   ,  {63'b0, {num1 - num2}[63]},
//     `ysyx_22040931_COMU  ,  {63'b0, {{1'b0, num1} - {1'b0, num2}}[64]},
//     `ysyx_22040931_SHIL  ,  num1 << num2[5 : 0],
//     `ysyx_22040931_SHIR  ,  num1 >> num2[5 : 0],
//     `ysyx_22040931_SRA   ,  num1_s >>> num2[5 : 0],
//     `ysyx_22040931_SHILW ,  num1 << num2[4 : 0],
//     `ysyx_22040931_SRAW  ,  {{32{num1_sw[31]}} , {num1_sw >>> num2[4 : 0]}},
//     `ysyx_22040931_SHIRW ,  {{32{1'b0}} , {num1[31 : 0] >> num2[4 : 0]}},
//     `ysyx_22040931_PC    ,  num2 + pc,
//     `ysyx_22040931_SORT  ,  num1 + imm,
//     `ysyx_22040931_JUMP  ,  pc + 4,
//     `ysyx_22040931_REMW  ,  remainder,
//     `ysyx_22040931_REMUW ,  remainder,
//     `ysyx_22040931_REMU  ,  remainder,
//     `ysyx_22040931_REM   ,  remainder,
//     `ysyx_22040931_MUL   ,  result_lo, 
//     `ysyx_22040931_MULH  ,  result_hi,
//     `ysyx_22040931_MULHSU,  result_hi,
//     `ysyx_22040931_MULHU ,  result_hi,
//     `ysyx_22040931_MULW  ,  result_lo,
//     `ysyx_22040931_DIV   ,  quotient,
//     `ysyx_22040931_DIVU  ,  quotient,
//     `ysyx_22040931_DIVUW ,  quotient,     
//     `ysyx_22040931_DIVW  ,  quotient
//     });


    ysyx_22040931_MuxD #(29, `ysyx_22040931_ALU, 64) ALU (out, op, `ysyx_22040931_ZERO_NUM, {
    `ysyx_22040931_ADD   ,  num1 + num2,
    `ysyx_22040931_SUB   ,  num1 - num2,
    `ysyx_22040931_AND   ,  num1 & num2,
    `ysyx_22040931_XOR   ,  num1 ^ num2,
    `ysyx_22040931_OR    ,  num1 | num2,
    `ysyx_22040931_COM   ,  {63'b0, {num1 - num2}[63]},
    `ysyx_22040931_COMU  ,  {63'b0, {{1'b0, num1} - {1'b0, num2}}[64]},
    `ysyx_22040931_SHIL  ,  num1 << num2[5 : 0],
    `ysyx_22040931_SHIR  ,  num1 >> num2[5 : 0],
    `ysyx_22040931_SRA   ,  num1_s >>> num2[5 : 0],
    `ysyx_22040931_SHILW ,  num1 << num2[4 : 0],
    `ysyx_22040931_SRAW  ,  {{32{num1_sw[31]}} , {num1_sw >>> num2[4 : 0]}},
    `ysyx_22040931_SHIRW ,  {{32{1'b0}} , {num1[31 : 0] >> num2[4 : 0]}},
    `ysyx_22040931_PC    ,  num2 + pc,
    `ysyx_22040931_SORT  ,  num1 + imm,
    `ysyx_22040931_JUMP  ,  pc + 4,
    `ysyx_22040931_REMW  ,  remainder,
    `ysyx_22040931_REMUW ,  remainder,
    `ysyx_22040931_REMU  ,  remainder,
    `ysyx_22040931_REM   ,  remainder,
    `ysyx_22040931_MUL   ,  num1_s * num2_s,
    `ysyx_22040931_MULH  ,  (num1_s * num2_s) >> 64,
    `ysyx_22040931_MULHSU,  (num1_s * num2) >> 64,
    `ysyx_22040931_MULHU ,  (num1 * num2) >> 64,
    `ysyx_22040931_MULW  ,  {32'b0, (num1_sw * num2_sw)},
    `ysyx_22040931_DIV   ,  quotient,
    `ysyx_22040931_DIVU  ,  quotient,
    `ysyx_22040931_DIVUW ,  quotient,     
    `ysyx_22040931_DIVW  ,  quotient
    });


endmodule
