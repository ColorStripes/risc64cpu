//2021.8.5
//xu xin
`include "defines.v"

module ex_mem (
    input wire rst,
    input wire clk,
    input wire [`PC_BUS] ex_pc,
    input wire  [`REG_BUS] ex_w_data,
    input wire ex_w_ena,
    input wire [4 : 0] ex_w_addr,
    input wire [`REG_BUS] ex_mem_addr,
    input wire [4 : 0] ex_memop,
    input wire [`REG_BUS] ex_stor_data,
    input wire ex_mem_wr,
    input wire ex_mem_ena,

    output reg [`REG_BUS] mem_w_data,
    output reg mem_w_ena,
    output reg [4 : 0] mem_w_addr,

    output reg [`REG_BUS] mem_mem_addr,
    output reg [4 : 0] mem_memop,
    output reg [`REG_BUS] mem_stor_data,
    output reg mem_mem_wr,
    output reg mem_mem_ena,

    output reg [`PC_BUS] men_pc 
);
    always @(posedge clk) begin
        if(rst == 1'b1) begin
            mem_w_data <= `ZERO_WORD;
            mem_w_ena <= 1'b0;
            mem_w_addr <= `ZERO_REG_ADDR;
            men_pc <= `ZERO_WORD;
            mem_mem_addr <= `ZERO_WORD;
            mem_memop <= 5'b00000;
            mem_stor_data <= `ZERO_WORD;
            mem_mem_wr <= 1'b0;
            mem_mem_ena <= 1'b0;
        end
        else begin
            mem_w_data <= ex_w_data;
            mem_w_ena <= ex_w_ena;
            mem_w_addr <= ex_w_addr;
            men_pc <= ex_pc;
            mem_mem_addr <= ex_mem_addr;
            mem_memop <= ex_memop;
            mem_stor_data <= ex_stor_data;
            mem_mem_wr <= ex_mem_wr;
            mem_mem_ena <= ex_mem_ena;
        end
    end
endmodule