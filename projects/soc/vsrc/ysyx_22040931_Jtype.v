//6.28 xuxin
`include "defines.v"

module ysyx_22040931_Jtype(
    input wire [6 : 0] opcode,

    output wire             jump,
    output wire [`ysyx_22040931_ALU_BUS]    aluop,
    output wire [2 : 0]     exop,
    output wire            jtype
);

    wire [6 : 0] chose = opcode;
    wire [10 : 0] out;

    ysyx_22040931_MuxD #(1, 7, 11) Jtype (out, chose, 11'b0000_0000_000, {
    `ysyx_22040931_jal,  {1'b1,`ysyx_22040931_Arith,`ysyx_22040931_JUMP, 1'b1}
    });
    
    assign jump = out[0];
    assign aluop = out[6 : 1];
    assign exop = out[9 : 7];
    assign jtype = out[10];

endmodule
