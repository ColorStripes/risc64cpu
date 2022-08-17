//2022.8.14 xuxin
`include "defines.v"

module ib_dr(
    input wire reset,
    input wire clock,
    input wire [`INST_BUS] instr1_i,
    input wire [`INST_BUS] instr2_i,

    output wire [`INST_BUS] instr1,
    output wire [`INST_BUS] instr2
);

    Reg #(128, `ZERO_GROUP) if_ib (
        clock, 
        reset, 
        1'b1, 
        {instr1_i, instr2_i}, 
        {instr1,   instr2}
    );


endmodule
