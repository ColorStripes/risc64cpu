//2021.8.5
//xu xin
`include "defines.v"

module ysyx_210457_WB_stage (
    input wire reset,
    input wire mem_w_ena,
    input wire [`REG_BUS] mem_w_data,
    input wire [4 : 0] mem_w_addr,
    input wire mem_csr_ena,                 //csr
    input wire [11 : 0] mem_csr_addr,         
    input wire [`REG_BUS] mem_w_csr_data,
    

    output reg wb_csr_ena,                 ///csr o
    output reg [11 : 0] wb_csr_addr,         
    output reg [`REG_BUS] wb_w_csr_data,
    output reg wb_w_ena,
    output reg [`REG_BUS] wb_w_data,
    output reg [4 : 0] wb_w_addr
);

    always @( * ) begin
        if(reset == 1'b1) begin
            wb_w_ena = 1'b0;
            wb_w_data = `ZERO_WORD;
            wb_w_addr = `ZERO_REG_ADDR;
        end
        else begin
            wb_w_ena = mem_w_ena;
            wb_w_addr = mem_w_addr;
            wb_w_data = mem_w_data;
        end
    end

    always @(*) begin                    //csr
        if(reset == 1'b1) begin
            wb_csr_addr = 12'h000;
            wb_w_csr_data = `ZERO_WORD;
            wb_csr_ena = 1'b0;
        end
        else begin
            wb_csr_addr = mem_csr_addr;
            wb_w_csr_data = mem_w_csr_data;
            wb_csr_ena = mem_csr_ena;
        end
    end

endmodule