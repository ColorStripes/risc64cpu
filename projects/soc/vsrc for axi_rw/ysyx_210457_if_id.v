
//2021.8.4
//xu xin

`include "defines.v"

module ysyx_210457_if_id (
    input wire reset,
    input wire clock,
    input wire [`PC_BUS] if_pc,
    input wire [`INST_BUS] if_instr,
    input wire pc_con,
    input wire wash,
    input wire flush,
    input wire if_forecase,
    input wire [`PC_BUS] if_branch,
    input wire [1: 0] stall,

    output reg [`PC_BUS] id_branch,
    output reg id_forecase,
    output reg [`PC_BUS] id_pc,
    output reg [`INST_BUS] id_instr
);
    always @(posedge clock) begin
        if(reset == 1'b1) begin
            id_pc <= `PC_START;
            id_instr <= `ZERO_INST;
        end
        else begin
            if(flush == 1'b1) begin
                id_pc <= `PC_START;
                id_instr <= `ZERO_INST;
            end
            else if(stall[1] & ~stall[0]) begin
                id_pc <= `PC_START;
                id_instr <= `ZERO_INST;
            end
            else if(~stall[1]) begin
                if(wash == 1'b1) begin
                    if(pc_con == 1'b0) begin
                        id_pc <= `PC_START;
                        id_instr <= `ZERO_INST;
                    end
                end
                else begin
                    if (pc_con == 1'b0) begin
                        id_pc <= if_pc;
                        id_instr <= if_instr;
                        id_forecase <= if_forecase;
                        id_branch <= if_branch;
                    end 
                end        
            end
        end
    end
endmodule