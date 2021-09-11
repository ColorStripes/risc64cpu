//2021.8.4
//xu xin

`include "defines.v"

module if_id (
    input wire rst,
    input wire clk,
    input wire [`PC_BUS] if_pc,
    input wire [`INST_BUS] if_instr,
    input wire wash,
    input wire pc_con,

    output reg [`PC_BUS] id_pc,
    output reg [`INST_BUS] id_instr
);
    always @(posedge clk) begin
        if(rst == 1'b1) begin
            id_pc <= `PC_START;
            id_instr <= `ZERO_INST;
        end
        else begin
            
            if(wash == 1'b1) begin
                id_pc <= `PC_START;
                id_instr <= `ZERO_INST;
            end
            else begin
                 if (pc_con == 1'b0) begin
                      id_pc <= if_pc;
                      id_instr <= if_instr;
                end
                
            end
            
        end
    end
endmodule