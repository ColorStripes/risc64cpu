//2021.8.5
//xuxin
`include "defines.v"


module mem_wb (
    input wire clk,
    input wire rst,
    input wire [`REG_BUS] mem_w_data,
    input wire mem_w_ena,
    input wire [4 : 0] mem_w_addr,
    input wire [`PC_BUS] mem_pc,
    input wire [`INST_BUS] mem_instr,

    input wire [11 : 0] mem_csr_addr,         //csr
    input wire [`REG_BUS] mem_w_csr_data,
    input wire mem_csr_ena,
    input wire flush,
    input wire [63 : 0] except_type,

    output reg [11 : 0] wb_csr_addr,         ///csr o
    output reg [`REG_BUS] wb_w_csr_data,
    output reg wb_csr_ena,
    
    output reg [`INST_BUS] wb_instr,
    output reg [`PC_BUS] wb_pc,
    output reg [`REG_BUS] wb_w_data,
    output reg wb_w_ena,
    output reg [4 : 0] wb_w_addr
);
    always @(posedge clk) begin
        if(rst == 1'b1) begin
            wb_w_data <= `ZERO_WORD;
            wb_w_ena <= 1'b0;
            wb_w_addr <= `ZERO_REG_ADDR;
            wb_pc <= `PC_START;
            wb_instr <= `ZERO_INST;
            wb_csr_addr <= 12'h000;
            wb_w_csr_data <= `ZERO_WORD;
            wb_csr_ena <= 1'b0;
        end
        else begin
            wb_w_data <= mem_w_data;
            wb_w_ena <= mem_w_ena;
            wb_w_addr <= mem_w_addr;
            wb_pc <= mem_pc;
            wb_instr <= mem_instr;
            wb_csr_addr <= mem_csr_addr;
            wb_w_csr_data <= mem_w_csr_data;
            wb_csr_ena <= mem_csr_ena;

            if(flush == 1'b1) begin
                wb_w_ena <= 1'b0;
                wb_csr_ena <= 1'b0;
                if(except_type == 64'h1) begin
                

                end


            end

        end
    end
endmodule