//6.29 xuxin
`include "defines.v"

module ysyx_22040931_WB(

    //woshou
    output wire wb_ready,
    //regfile
    input wire w_ena_i,
    input wire [`ysyx_22040931_REG_BUS] w_addr_i,
    input wire [`ysyx_22040931_DATA_BUS] w_data_i,
    //except
    input wire [`ysyx_22040931_EXCEPT_BUS] except,
    input wire arbiter_if_valid,
    output wire flush,
    //liushuixian
    input wire [`ysyx_22040931_PC_BUS] pc_i,
    

    output wire w_ena,
    output wire [`ysyx_22040931_REG_BUS] w_addr,
    output wire [`ysyx_22040931_DATA_BUS] w_data,
    //except
    output wire now_except
);


    assign w_ena  = w_ena_i;
    assign w_addr = w_addr_i;
    assign w_data = w_data_i;




//except
assign now_except = (except == 0) ? 1'b0 : 1'b1;
assign wb_ready = now_except ? arbiter_if_valid : 1'b1;
assign flush = now_except & wb_ready;



endmodule
