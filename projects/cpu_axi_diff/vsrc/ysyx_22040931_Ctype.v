//8.5 xuxin
`include "defines.v"

module ysyx_22040931_Ctype(
    input wire [6 : 0] opcode,
    input wire [2 : 0] opcode_3,


    output wire [`ysyx_22040931_ALU_BUS] aluop,
    output wire [2 : 0]     exop,
    output wire             cena,
    output wire            ctype
);

    wire [9 : 0] chose = {opcode_3, opcode};
    wire [10 : 0] out;


    ysyx_22040931_MuxD #(6, 10, 11) Ctype (out, chose, 10'b00000_00000, {
    `ysyx_22040931_csrrw , {1'b1, 1'b1, `ysyx_22040931_Csr, `ysyx_22040931_NUM1},
    `ysyx_22040931_csrrs , {1'b1, 1'b1, `ysyx_22040931_Csr, `ysyx_22040931_OR},
    `ysyx_22040931_csrrc , {1'b1, 1'b1, `ysyx_22040931_Csr, `ysyx_22040931_ANOR},
    `ysyx_22040931_csrrwi, {1'b1, 1'b0, `ysyx_22040931_Csr, `ysyx_22040931_NUM1},
    `ysyx_22040931_csrrsi, {1'b1, 1'b0, `ysyx_22040931_Csr, `ysyx_22040931_OR},
    `ysyx_22040931_csrrci, {1'b1, 1'b0, `ysyx_22040931_Csr, `ysyx_22040931_ANOR}
    });

    assign aluop = out[5 : 0];
    assign exop = out[8 : 6];
    assign cena = out[9];
    assign ctype = out[10];

endmodule
