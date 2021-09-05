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
        end
        else begin
            wb_w_data <= mem_w_data;
            wb_w_ena <= mem_w_ena;
            wb_w_addr <= mem_w_addr;
            wb_pc <= mem_pc;
            wb_instr <= mem_instr;
        end
    end
endmodule