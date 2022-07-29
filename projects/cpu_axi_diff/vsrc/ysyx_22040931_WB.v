//6.29 xuxin
`include "defines.v"

module ysyx_22040931_WB(

    input wire w_ena_i,
    input wire [`ysyx_22040931_REG_BUS] w_addr_i,
    input wire [`ysyx_22040931_DATA_BUS] w_data_i,
    //liushuixian
    input wire [`ysyx_22040931_PC_BUS] pc_i,
    

    output wire w_ena,
    output wire [`ysyx_22040931_REG_BUS] w_addr,
    output wire [`ysyx_22040931_DATA_BUS] w_data
);


    assign w_ena = w_ena_i;
    assign w_addr = w_addr_i;
    assign w_data = w_data_i;

endmodule
