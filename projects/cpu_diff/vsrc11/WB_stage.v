//2021.8.5
//xu xin
`include "defines.v"

module WB_stage (
    input wire rst,
    input wire mem_w_ena,
    input wire [`REG_BUS] mem_w_data,
    input wire [4 : 0] mem_w_addr,

    output reg wb_w_ena,
    output reg [`REG_BUS] wb_w_data,
    output reg [4 : 0] wb_w_addr
);

    always @( * ) begin
        if(rst == 1'b1) begin
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

endmodule