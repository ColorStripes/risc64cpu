//2022.6.23 xuxin
`include "defines.v"

module ysyx_22040931_MEM(

    input wire w_ena_i,
    input wire [`ysyx_22040931_REG_BUS] w_addr_i,
    input wire [`ysyx_22040931_DATA_BUS] w_data_i,
    //mem
    input wire [2 : 0]   memwop,
    input wire [2 : 0]   memrop,
    input wire           mem_ena_i,
    input wire           mem_wr_i,
    input wire [`ysyx_22040931_MEM_BUS] mem_addr_i,
    input wire [`ysyx_22040931_DATA_BUS] mem_stor_data_i,
    input wire [`ysyx_22040931_DATA_BUS] mem_data,
    
    //liushuixian
    input wire [`ysyx_22040931_PC_BUS] pc_i,
    input wire [`ysyx_22040931_INST_BUS] instr,


    output wire w_ena,
    output wire [`ysyx_22040931_REG_BUS] w_addr,
    output wire [`ysyx_22040931_DATA_BUS] w_data,
    //mem
    output wire [1 : 0]       memop,//
    output wire             mem_ena,
    output wire              mem_wr,
    output wire [`ysyx_22040931_MEM_BUS] mem_addr,
    output wire [`ysyx_22040931_DATA_BUS] mem_stor_data,//
    //liushuixian
    output wire [`ysyx_22040931_INST_BUS] instr_o,
    output wire [`ysyx_22040931_PC_BUS] pc_o

);

assign pc_o = pc_i;
assign instr_o = instr;

    assign w_ena = w_ena_i;
    assign w_addr = w_addr_i;

    assign mem_ena = mem_ena_i;
    assign mem_wr = mem_wr_i;
    assign mem_addr = mem_addr_i;

    wire [`ysyx_22040931_DATA_BUS] mem_r_data;
    assign w_data = (mem_ena & ~mem_wr) ? mem_r_data : w_data_i;

    wire [2 : 0] memwrop;
    assign memwrop = mem_wr_i ? memwop : memrop;
    ysyx_22040931_MuxD #(7, 3, 2)  memop_mux (
        memop,
        memwrop,
        `ysyx_22040931_SIZE_B,
        {   
            `ysyx_22040931_R_ONE,  `ysyx_22040931_SIZE_B, 
            `ysyx_22040931_R_ONEU, `ysyx_22040931_SIZE_B,
            `ysyx_22040931_R_DOU,  `ysyx_22040931_SIZE_H,
            `ysyx_22040931_R_DOUU, `ysyx_22040931_SIZE_H,
            `ysyx_22040931_R_FOR,  `ysyx_22040931_SIZE_W,
            `ysyx_22040931_R_FORU, `ysyx_22040931_SIZE_W,
            `ysyx_22040931_R_EIG,  `ysyx_22040931_SIZE_D
        }
    );

    ysyx_22040931_MuxD #(7, 3, 64)  mem_r_data_mux (
        mem_r_data,
        memrop,
        `ysyx_22040931_ZERO_NUM,
        {   
            `ysyx_22040931_R_ONE,    {{56{mem_data[7]}} , mem_data[7 : 0]}, 
            `ysyx_22040931_R_ONEU,   {{56{1'b0}} , mem_data[7 : 0]}, 
            `ysyx_22040931_R_DOU,    {{48{mem_data[15]}} , mem_data[15 : 0]}, 
            `ysyx_22040931_R_DOUU,   {{48{1'b0}} , mem_data[15 : 0]},
            `ysyx_22040931_R_FOR,    {{32{mem_data[31]}} , mem_data[31 : 0]},
            `ysyx_22040931_R_FORU,   {{32{1'b0}} , mem_data[31 : 0]},
            `ysyx_22040931_R_EIG,    mem_data
        }
    );


    wire [`ysyx_22040931_DATA_BUS] stor_data_one;
    wire [`ysyx_22040931_DATA_BUS] stor_data_two;
    wire [`ysyx_22040931_DATA_BUS] stor_data_for;
    ysyx_22040931_MuxD #(4, 3, 64)  mem_stor_data_mux (
        mem_stor_data,
        memwop,
        `ysyx_22040931_ZERO_NUM,
        {   
            `ysyx_22040931_W_ONE,   stor_data_one, 
            `ysyx_22040931_W_DOU,   stor_data_two, 
            `ysyx_22040931_W_FOR,   stor_data_for, 
            `ysyx_22040931_W_EIG,   mem_stor_data_i
        }
    );

    ysyx_22040931_MuxD #(8, 6, 64)  mem_stor_data1_mux (
        stor_data_one,
        {memwop, mem_addr[2 : 0]},
        `ysyx_22040931_ZERO_NUM,
        {   
            {`ysyx_22040931_W_ONE, 3'b000},  {56'b0, mem_stor_data_i[7 : 0]}, 
            {`ysyx_22040931_W_ONE, 3'b001},  {48'b0, mem_stor_data_i[7 : 0], 8'b0},
            {`ysyx_22040931_W_ONE, 3'b010},  {40'b0, mem_stor_data_i[7 : 0], 16'b0},
            {`ysyx_22040931_W_ONE, 3'b011},  {32'b0, mem_stor_data_i[7 : 0], 24'b0},
            {`ysyx_22040931_W_ONE, 3'b100},  {24'b0, mem_stor_data_i[7 : 0], 32'b0},
            {`ysyx_22040931_W_ONE, 3'b101},  {16'b0, mem_stor_data_i[7 : 0], 40'b0},
            {`ysyx_22040931_W_ONE, 3'b110},  {8'b0, mem_stor_data_i[7 : 0], 48'b0},
            {`ysyx_22040931_W_ONE, 3'b111},  {mem_stor_data_i[7 : 0], 56'b0}
        }
    );

    ysyx_22040931_MuxD #(4, 5, 64)  mem_stor_data2_mux (
        stor_data_two,
        {memwop, mem_addr[2 : 1]},
        `ysyx_22040931_ZERO_NUM,
        {   
            {`ysyx_22040931_W_DOU, 2'b00},  {48'b0, mem_stor_data_i[15 : 0]}, 
            {`ysyx_22040931_W_DOU, 2'b01},  {32'b0, mem_stor_data_i[15 : 0], 16'b0},
            {`ysyx_22040931_W_DOU, 2'b10},  {16'b0, mem_stor_data_i[15 : 0], 32'b0},
            {`ysyx_22040931_W_DOU, 2'b11},  {mem_stor_data_i[15 : 0], 48'b0}
        }
    );


    ysyx_22040931_MuxD #(2, 4, 64)  mem_stor_data3_mux (
        stor_data_for,
        {memwop, mem_addr[2]},
        `ysyx_22040931_ZERO_NUM,
        {   
            {`ysyx_22040931_W_FOR, 1'b0},  {32'b0, mem_stor_data_i[31 : 0]}, 
            {`ysyx_22040931_W_FOR, 1'b1},  {mem_stor_data_i[31 : 0], 32'b0}
        }
    );


endmodule
