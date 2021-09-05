//2021.8.5
//xuxin
`include "defines.v"


module mem_wb (
    input wire clk,
    input wire rst,
    input wire [`REG_BUS] mem_w_data,
    input wire mem_w_ena,
    input wire [4 : 0] mem_w_addr,

    output reg [`REG_BUS] wb_w_data,
    output reg wb_w_ena,
    output reg [4 : 0] wb_w_addr
);
    always @(posedge clk) begin
        if(rst == 1'b1) begin
            wb_w_data <= `ZERO_WORD;
            wb_w_ena <= 1'b0;
            wb_w_addr <= `ZERO_REG_ADDR;
        end
        else begin
            wb_w_data <= mem_w_data;
            wb_w_ena <= mem_w_ena;
            wb_w_addr <= mem_w_addr;
        end
    end
endmodule