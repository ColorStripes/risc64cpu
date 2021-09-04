//2021.8.5
//xu xin
`include "defines.v"

module MEM_stage (
    input wire rst,
    input wire [`REG_BUS] ex_w_data,
    input wire ex_w_ena,
    input wire [4 : 0] ex_w_addr,
    
    input wire [`REG_BUS] ex_mem_addr,
    input wire [`REG_BUS] ex_stor_data,
    input wire [4 : 0] ex_memop,

    input wire ex_mem_wr,
    input wire ex_mem_ena,
    input wire [`REG_BUS] mem_data,

    output reg [`REG_BUS] mem_w_data,
    output reg mem_w_ena,
    output reg [4 : 0] mem_w_addr,

    output reg [`REG_BUS] mem_mem_addr,
    output reg [7 : 0] mem_sel,
    output reg [`REG_BUS] mem_stor_data,
    output reg mem_wr,
    output reg mem_mem_ena
);
    always @(*) begin
        if(rst == 1'b1) begin
            mem_w_data = `ZERO_WORD;
            mem_w_ena = 1'b0;
            mem_w_addr = `ZERO_REG_ADDR;
            mem_mem_addr = `ZERO_WORD;
            mem_sel = 8'b0000_0000;
            mem_stor_data = `ZERO_WORD;
            mem_wr = 1'b0;
            mem_mem_ena = 1'b0;
        end
        else begin
            mem_w_data = ex_w_data;
            mem_w_ena = ex_w_ena;
            mem_w_addr = ex_w_addr;
            mem_mem_addr = ex_mem_addr;
            mem_stor_data = ex_stor_data;
            mem_sel = 8'b0000_0000;
            mem_wr = ex_mem_wr;
            mem_mem_ena = ex_mem_ena;
            case(ex_memop)
                 `R_ONE:begin
                     mem_sel = 8'b0000_0001;
                     mem_w_data = {{56{mem_data[7]}} , mem_data[7 : 0]};
                 end
                 `R_ONEu:begin
                     mem_sel = 8'b0000_0001;
                     mem_w_data = {{56{1'b0}} , mem_data[7 : 0]};
                 end
                 `R_DOU:begin
                     mem_sel = 8'b0000_0011;
                     mem_w_data = {{48{mem_data[15]}} , mem_data[15 : 0]};
                 end
                 `R_DOUu:begin
                     mem_sel = 8'b0000_0011;
                     mem_w_data = {{48{1'b0}} , mem_data[15 : 0]};
                 end
                 `R_FOR:begin
                     mem_sel = 8'b0000_1111;
                     mem_w_data = {{32{mem_data[31]}} , mem_data[31 : 0]};
                 end
                 `R_FORu:begin
                     mem_sel = 8'b0000_1111;
                     mem_w_data = {{32{1'b0}} , mem_data[31 : 0]};
                 end
                 `R_EIG:begin
                     mem_sel = 8'b1111_1111;
                     mem_w_data = mem_data;
                 end
                 `W_ONE:begin
                     mem_sel = 8'b0000_0001;
                     mem_mem_ena = 1'b1;
                 end
                 `W_DOU:begin
                     mem_sel = 8'b0000_0011;
                     mem_mem_ena = 1'b1;
                 end
                 `W_FOR:begin
                     mem_sel = 8'b0000_1111;
                     mem_mem_ena = 1'b1;
                 end
                 `W_EIG:begin
                     mem_sel = 8'b1111_1111;
                     mem_mem_ena = 1'b1;
                 end
                 default:begin
                     mem_w_data = ex_w_data;
                     mem_sel = 8'b0000_0000;
                     mem_wr = 1'b0;
                     mem_mem_ena = 1'b0;
                 end
            endcase
        end
    end
endmodule