//6.28 xuxin
`include "defines.v"

module Jtype(
    input wire [6 : 0] opcode,

    output wire             jump,
    output wire [`ALU_BUS]    aluop,
    output wire [2 : 0]     exop,
    output wire            jtype
);

    wire [6 : 0] chose = opcode;
    wire [10 : 0] out;

    MuxD #(1, 7, 11) Jtype (out, chose, 11'b0000_0000_000, {
    `jal,  {1'b1,`Arith,`JUMP, 1'b1}
    });
    
    assign jump = out[0];
    assign aluop = out[6 : 1];
    assign exop = out[9 : 7];
    assign jtype = out[10];

endmodule
