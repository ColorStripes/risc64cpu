//2022.8.15 xuxin
`include "defines.v"

module Check(
    input wire wen_0,
    input wire [`REG_BUS] w_addr_0,
    input wire wen_1,
    input wire [`REG_BUS] w_addr_1,
    input wire ren1_1,
    input wire [`REG_BUS] r_addr1_1,
    input wire ren2_1,
    input wire [`REG_BUS] r_addr2_1,



    output wire FL_1_1,
    output wire FL_2_1,
    output wire rat_wen_0,
    output wire rat_wen_1

);


    //--------------------------RAW------------------------------------
    assign FL_1_1 = (w_addr_0 == r_addr1_1) & wen_0 & ren1_1 ? 1'b1 : 1'b0;
    assign FL_2_1 = (w_addr_0 == r_addr2_1) & wen_0 & ren2_1 ? 1'b1 : 1'b0;


    //--------------------------WAW------------------------------------
    assign rat_wen_0 = (w_addr_0 == w_addr_1) & wen_0 & wen_1 ? 1'b0 : wen_0;
    assign rat_wen_1 = wen_1;



endmodule
