//2022.7.23 xuxin
`include "defines.v"


module ICACHE_RAM(
    Q, CLK, CEN, WEN, A, D
);

parameter Bits = 128;
parameter Word_Depth = 64;
parameter Add_Width = 7;

output  [Bits-1:0]      Q;
input                   CLK;
input                   CEN;
input                   WEN;
input   [Add_Width-1:0] A;
input   [Bits-1:0]      D;


    wire WEN1 = A[Add_Width-1] ? 1'b1 : WEN;

    wire WEN2 = A[Add_Width-1] ? WEN : 1'b1;


    wire [Bits-1:0] Q1,Q2;
    assign Q = A[Add_Width-1] ? Q2 : Q1;

    S011HD1P_X32Y2D128 ONE(
    Q1, CLK, CEN, WEN1, A[Add_Width-2 : 0], D
    );

    S011HD1P_X32Y2D128 TWO(
    Q2, CLK, CEN, WEN2, A[Add_Width-2 : 0], D
    );



endmodule
