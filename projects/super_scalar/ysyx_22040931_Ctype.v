//8.5 xuxin
`include "defines.v"

module Ctype(
    input wire [6 : 0] opcode,
    input wire [2 : 0] opcode_3,


    output wire [`ALU_BUS] aluop,
    output wire [2 : 0]     exop,
    output wire             cena,
    output wire            ctype
);

    wire [9 : 0] chose = {opcode_3, opcode};
    wire [10 : 0] out;


    MuxD #(6, 10, 11) Ctype (out, chose, 10'b00000_00000, {
    `csrrw , {1'b1, 1'b1, `Csr, `NUM1},
    `csrrs , {1'b1, 1'b1, `Csr, `OR},
    `csrrc , {1'b1, 1'b1, `Csr, `ANOR},
    `csrrwi, {1'b1, 1'b0, `Csr, `NUM1},
    `csrrsi, {1'b1, 1'b0, `Csr, `OR},
    `csrrci, {1'b1, 1'b0, `Csr, `ANOR}
    });

    assign aluop = out[5 : 0];
    assign exop = out[8 : 6];
    assign cena = out[9];
    assign ctype = out[10];

endmodule
