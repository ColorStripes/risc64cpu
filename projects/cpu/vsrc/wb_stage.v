//xuxin
//2021.7.29
`include "defines.v"


module wb_stage (
    input wire rst,
    input wire wb_ena_i,
    input wire [`REG_BUS] wb_data,
    input wire [4:0] wb_addr_i,

    output wire wb_ena_o,
    output wire [`REG_BUS] wb_data_o,
    output wire [4:0] wb_addr_o

);
  assign wb_ena_o = (rst == 1'b1)? 0 : wb_ena_i;
  assign wb_addr_o = (rst == 1'b1)? 0: wb_addr_i;
  assign wb_data_o = (rst == 1'b1)? 0 : wb_data;  
endmodule