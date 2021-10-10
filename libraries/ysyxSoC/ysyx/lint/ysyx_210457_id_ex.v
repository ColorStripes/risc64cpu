//2021.8.4
//xu xin
`include "defines.v"

module ysyx_210457_id_ex (
    input wire reset,
    input wire clock,
    input wire [63 : 0] id_imm,

    input wire [`PC_BUS] id_pc,
    input wire [`INST_BUS] id_instr,

    input wire [4 : 0] id_memop,
    input wire [6 : 0] id_aluop,
    input wire [3 : 0] id_alusel,
    input wire id_mem_wr,
    input wire id_mem_ena,

    input wire [`REG_BUS] id_reg1_data,
    input wire [`REG_BUS] id_reg2_data,

    input wire id_w_ena,
    input wire [4 : 0] id_w_addr,
    input wire flush,
    input wire [1: 0] stall,

    input wire id_csr_ena,           //csr

    output reg ex_csr_ena,

    output reg [4 : 0] ex_w_addr,
    output reg ex_w_ena,

    output reg [`REG_BUS] ex_reg1_data,
    output reg [`REG_BUS] ex_reg2_data,

    output reg [4 : 0] ex_memop,
    output reg [6 : 0] ex_aluop,
    output reg [3 : 0] ex_alusel,
    output reg [63 : 0] ex_imm,
    output reg ex_mem_wr,
    output reg ex_mem_ena,

    output reg [`INST_BUS] ex_instr,
    output reg [`PC_BUS] ex_pc

); 

always @(posedge clock) begin
    if (reset == 1'b1) begin
        ex_w_addr <= `ZERO_REG_ADDR;
        ex_w_ena <= 1'b0;

        ex_reg1_data <= `ZERO_WORD;
        ex_reg2_data <= `ZERO_WORD;

        ex_memop <= 5'b00000;
        ex_aluop <= 7'b0000000;
        ex_alusel <= 4'b000;
        ex_imm <= `ZERO_WORD;
        ex_mem_wr <= 1'b0;
        ex_mem_ena <= 1'b0;

        ex_pc <= `PC_START;
        ex_instr <= `ZERO_INST;

        ex_csr_ena <= 1'b0;
    end
    else begin
        if(flush == 1'b1) begin
            ex_w_addr <= `ZERO_REG_ADDR;
            ex_w_ena <= 1'b0;

            ex_reg1_data <= `ZERO_WORD;
            ex_reg2_data <= `ZERO_WORD;

            ex_memop <= 5'b00000;
            ex_aluop <= 7'b0000000;
            ex_alusel <= 4'b000;
            ex_imm <= `ZERO_WORD;
            ex_mem_wr <= 1'b0;
            ex_mem_ena <= 1'b0;

            ex_pc <= `PC_START;
            ex_instr <= `ZERO_INST;
            ex_csr_ena <= 1'b0;
        end
        else if(stall[1] & ~stall[0]) begin
            ex_w_addr <= `ZERO_REG_ADDR;
            ex_w_ena <= 1'b0;

            ex_reg1_data <= `ZERO_WORD;
            ex_reg2_data <= `ZERO_WORD;

            ex_memop <= 5'b00000;
            ex_aluop <= 7'b0000000;
            ex_alusel <= 4'b000;
            ex_imm <= `ZERO_WORD;
            ex_mem_wr <= 1'b0;
            ex_mem_ena <= 1'b0;

            ex_pc <= `PC_START;
            ex_instr <= `ZERO_INST;
            ex_csr_ena <= 1'b0;
        end
        else if(~stall[1]) begin
            
            ex_w_addr <= id_w_addr;
            ex_w_ena <= id_w_ena;

            ex_reg1_data <= id_reg1_data;
            ex_reg2_data <= id_reg2_data;

            ex_memop <= id_memop;
            ex_aluop <= id_aluop;
            ex_alusel <= id_alusel;
            ex_imm <= id_imm;
            ex_mem_wr <= id_mem_wr;
            ex_mem_ena <= id_mem_ena;

            ex_pc <= id_pc;
            ex_instr <= id_instr;
            ex_csr_ena <= id_csr_ena;
            
        end
    end
  end
endmodule