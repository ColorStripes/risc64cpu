//2022.6.23 xuxin
`include "defines.v"

module ysyx_22040931_IMM(
    input [24 : 0] instr,
    input [2 : 0] opt,

    output wire [63 : 0] imm
);


    ysyx_22040931_MuxD #(5, 3, 64)  imm_mux (
        imm,
        opt,
        `ysyx_22040931_ZERO_NUM,
        {
           `ysyx_22040931_It, {{52{instr[24]}}, instr[24:13]},
           `ysyx_22040931_St, {{52{instr[24]}}, instr[24:18], instr[4:0]},
           `ysyx_22040931_Bt, {{51{instr[24]}}, instr[24], instr[0], instr[23:18], instr[4:1], 1'b0},
           `ysyx_22040931_Jt, {{43{instr[24]}}, instr[24], instr[12 : 5], instr[13], instr[23 : 14], 1'b0},
           `ysyx_22040931_Ut, {{32{instr[24]}}, instr[24 : 5], 12'b0000_0000_0000}
        }
    );

endmodule
