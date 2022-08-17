//6.29 xuxin
`include "defines.v"

module WB(

    //handshake
    output wire wb_ready,
    //regfile
    input wire w_ena_i,
    input wire [`REG_BUS] w_addr_i,
    input wire [`DATA_BUS] w_data_i,
    //CSR
    input wire csr_w_ena_i,
    input wire [`CSR_BUS] csr_w_addr_i,
    input wire [`DATA_BUS] csr_w_data_i,
    //except
    input wire [`EXCEPT_BUS] except,
    input wire arbiter_if_valid,
    //liushuixian
    input wire [`PC_BUS] pc_i,
    
    //regfile
    output wire w_ena,
    output wire [`REG_BUS] w_addr,
    output wire [`DATA_BUS] w_data,
    //CSR
    output wire csr_w_ena,
    output wire [`CSR_BUS] csr_w_addr,
    output wire [`DATA_BUS] csr_w_data,
    //except
    output wire flush,
    output wire now_except
);


    assign w_ena  = w_ena_i;
    assign w_addr = w_addr_i;
    assign w_data = w_data_i;

    assign csr_w_ena = csr_w_ena_i;
    assign csr_w_addr = csr_w_addr_i;
    assign csr_w_data = csr_w_data_i;



//except
assign now_except = (except == 0) ? 1'b0 : 1'b1;
assign wb_ready = now_except ? arbiter_if_valid : 1'b1;
assign flush = now_except & wb_ready;



endmodule
