//2022.7.15 xuxin
`include "defines.v"

module mem_wb(
    input wire reset,
    input wire clock,
    input wire flush,
    input wire stall,
    //wo shou
    input wire ex_valid,
    input wire wb_ready,
    output wire mem_ready,
    output wire mem_valid,
    //liushuixian
    input wire [`PC_BUS] MEM_pc,
    input wire [`INST_BUS] MEM_instr,
    input wire clint_ena_i,
    //regfile 
    input wire          MEM_w_ena,
    input wire [`REG_BUS] MEM_w_addr,
    input wire [`DATA_BUS] MEM_w_data,
    //except
    input wire [`EXCEPT_BUS] MEM_except,
    //csr
    input wire          MEM_csr_w_ena,
    input wire [`CSR_BUS] MEM_csr_w_addr,
    input wire [`DATA_BUS] MEM_csr_w_data,

    
    //regfile
    output reg          WB_w_ena,
    output reg [`REG_BUS]  WB_w_addr,
    output reg [`DATA_BUS] WB_w_data,
    //except
    output wire [`EXCEPT_BUS] WB_except,
    //csr
    output wire          WB_csr_w_ena,
    output wire [`CSR_BUS] WB_csr_w_addr,
    output wire [`DATA_BUS] WB_csr_w_data,
    //liushuixian
    output reg clint_ena_o,
    output reg [`INST_BUS] WB_instr,
    output reg [`PC_BUS] WB_pc
);


reg mem_now_valid;
wire mem_go;
assign mem_go = ~stall;
assign mem_ready = mem_go & wb_ready;   //当前时钟不是有效数据，或者当前已经处理完这个周期的活
assign mem_valid = mem_now_valid ;

    always@(posedge clock) begin
        if(reset == 1'b1) begin
            mem_now_valid <= 0;
        end
        else if(mem_ready) begin
            mem_now_valid <= ex_valid & ~flush;
        end
    end


    always @(posedge clock) begin
        if(reset == 1'b1) begin
            WB_w_ena <= `N_ENA;
            WB_w_addr <= `ZERO_REG;
            WB_w_data <= `ZERO_NUM;
            WB_pc <= `ZERO_PC;
            WB_instr <= `NONE_INST;
            WB_csr_w_ena  <= `N_ENA;
            WB_csr_w_addr <= `ZERO_CSR;
            WB_csr_w_data <= `ZERO_NUM;
            WB_except <= `NO_EXCEPT;
        end
        else if(flush) begin
            WB_w_ena <= `N_ENA;
            WB_w_addr <= `ZERO_REG;
            WB_w_data <= `ZERO_NUM;
            WB_pc <= `ZERO_PC;
            WB_instr <= `NONE_INST;
            WB_csr_w_ena  <= `N_ENA;
            WB_csr_w_addr <= `ZERO_CSR;
            WB_csr_w_data <= `ZERO_NUM;
            WB_except <= `NO_EXCEPT;
        end
        else begin
            if(ex_valid & mem_ready) begin
                WB_w_ena <= MEM_w_ena;
                WB_w_addr <= MEM_w_addr;
                WB_w_data <= MEM_w_data;
                WB_pc <= MEM_pc;
                WB_instr <= MEM_instr;
                WB_csr_w_ena  <= MEM_csr_w_ena ;
                WB_csr_w_addr <= MEM_csr_w_addr;
                WB_csr_w_data <= MEM_csr_w_data;
                WB_except <= MEM_except;
                clint_ena_o <= clint_ena_i;
            end
            else if(!ex_valid) begin
                //WB_w_ena <= `N_ENA;
                //WB_csr_w_ena  <= `N_ENA;
                //WB_w_addr <= `ZERO_REG;
                //WB_w_data <= `ZERO_NUM;
                WB_pc <= `ZERO_PC;
                WB_instr <= `NONE_INST;
                //WB_except <= `NO_EXCEPT;
            end
        end
    end


endmodule
