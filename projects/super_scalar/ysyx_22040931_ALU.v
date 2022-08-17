//2022.6.24 xuxin
`include "defines.v"


module ALU(
    input wire reset,
    input wire clock,
    input wire flush,
    input wire id_valid,
    input wire ex_ready,
    output wire alu_valid,
    output wire alu_ready,
    input wire [`DATA_BUS] num1,
    input wire [`DATA_BUS] num2,
    input wire [`DATA_BUS] imm,
    input wire [`PC_BUS]    pc,
    input wire [`ALU_BUS]   op,


    output wire [`DATA_BUS] out
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
    MuxD #(8, `ALU, 3) D_M_ENA (d_m_ena, op, {1'b0, 1'b0, 1'b0}, {  //{w, ena, sign}
    `REMW  ,  {1'b1, 1'b1, 1'b1},
    `REMUW ,  {1'b1, 1'b1, 1'b0},
    `REMU  ,  {1'b0, 1'b1, 1'b0},
    `REM   ,  {1'b0, 1'b1, 1'b1},
    `DIV   ,  {1'b0, 1'b1, 1'b1},
    `DIVU  ,  {1'b0, 1'b1, 1'b0},
    `DIVUW ,  {1'b1, 1'b1, 1'b0},
    `DIVW  ,  {1'b1, 1'b1, 1'b1}
    });

    assign alu_valid = (d_m_ena[1] & id_valid) ? div_valid : 1'b1;
    assign alu_ready = (d_m_ena[1] & id_valid) ? div_ready : 1'b1;

    wire [`DATA_BUS] quotient, remainder;
    wire div_valid, div_ready;
    divider divider(
    .clock(clock),
    .reset(reset),
    .flush(flush),
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
//     MuxD #(5, `ALU, 4) M_M_ENA (m_m_sign, op, {1'b0, 1'b0, 1'b0, 1'b0}, {  //{w, ena, sign_ed, sign_or}
//     `MUL   ,  {1'b0, 1'b1, 1'b1, 1'b1},
//     `MULH  ,  {1'b0, 1'b1, 1'b1, 1'b1},
//     `MULHSU,  {1'b0, 1'b1, 1'b1, 1'b0},
//     `MULHU ,  {1'b0, 1'b1, 1'b0, 1'b0},
//     `MULW  ,  {1'b1, 1'b1, 1'b1, 1'b1}
//     });

//     wire [`DATA_BUS] result_hi, result_lo;
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
//     MuxD #(31, `ALU, 64) ALU (out, op, `ZERO_NUM, {
//     `ADD   ,  num1 + num2,
//     `SUB   ,  num1 - num2,
//     `AND   ,  num1 & num2,
//     `XOR   ,  num1 ^ num2,
//     `OR    ,  num1 | num2,
//     `COM   ,  {63'b0, {num1 - num2}[63]},
//     `COMU  ,  {63'b0, {{1'b0, num1} - {1'b0, num2}}[64]},
//     `SHIL  ,  num1 << num2[5 : 0],
//     `SHIR  ,  num1 >> num2[5 : 0],
//     `SRA   ,  num1_s >>> num2[5 : 0],
//     `SHILW ,  num1 << num2[4 : 0],
//     `SRAW  ,  {{32{num1_sw[31]}} , {num1_sw >>> num2[4 : 0]}},
//     `SHIRW ,  {{32{1'b0}} , {num1[31 : 0] >> num2[4 : 0]}},
//     `PC    ,  num2 + pc,
//     `SORT  ,  num1 + imm,
//     `JUMP  ,  pc + 4,
//     `REMW  ,  remainder,
//     `REMUW ,  remainder,
//     `REMU  ,  remainder,
//     `REM   ,  remainder,
//     `MUL   ,  result_lo, 
//     `MULH  ,  result_hi,
//     `MULHSU,  result_hi,
//     `MULHU ,  result_hi,
//     `MULW  ,  result_lo,
//     `DIV   ,  quotient,
//     `DIVU  ,  quotient,
//     `DIVUW ,  quotient,     
//     `DIVW  ,  quotient,
//     `ANOR  ,  num1 &~ num2,
//     `NUM1  ,  num1
//     });


    MuxD #(31, `ALU, 64) ALU (out, op, `ZERO_NUM, {
    `ADD   ,  num1 + num2,
    `SUB   ,  num1 - num2,
    `AND   ,  num1 & num2,
    `XOR   ,  num1 ^ num2,
    `OR    ,  num1 | num2,
    `COM   ,  {63'b0, {num1 - num2}[63]},
    `COMU  ,  {63'b0, {{1'b0, num1} - {1'b0, num2}}[64]},
    `SHIL  ,  num1 << num2[5 : 0],
    `SHIR  ,  num1 >> num2[5 : 0],
    `SRA   ,  num1_s >>> num2[5 : 0],
    `SHILW ,  num1 << num2[4 : 0],
    `SRAW  ,  {{32{num1_sw[31]}} , {num1_sw >>> num2[4 : 0]}},
    `SHIRW ,  {{32{1'b0}} , {num1[31 : 0] >> num2[4 : 0]}},
    `PC    ,  num2 + pc,
    `SORT  ,  num1 + imm,
    `JUMP  ,  pc + 4,
    `REMW  ,  remainder,
    `REMUW ,  remainder,
    `REMU  ,  remainder,
    `REM   ,  remainder,
    `MUL   ,  num1_s * num2_s,
    `MULH  ,  (num1_s * num2_s) >> 64,
    `MULHSU,  (num1_s * num2) >> 64,
    `MULHU ,  (num1 * num2) >> 64,
    `MULW  ,  {32'b0, (num1_sw * num2_sw)},
    `DIV   ,  quotient,
    `DIVU  ,  quotient,
    `DIVUW ,  quotient,     
    `DIVW  ,  quotient,
    `ANOR  ,  ~num1 & num2,
    `NUM1  ,  num1
    });


endmodule
