//2022.7.15 xuxin
`include "defines.v"

module mem_wb(
    input wire reset,
    input wire clock,
    input wire flush,
    input wire stall,
    //wo shou
    input wire ex_valid,
    //input wire wb_ready,
    output wire mem_ready,
    output wire mem_valid,
    //liushuixian
    input wire [`ysyx_22040931_PC_BUS] MEM_pc,
    input wire [`ysyx_22040931_INST_BUS] MEM_instr,
    //regfile 
    input wire          MEM_w_ena,
    input wire [`ysyx_22040931_REG_BUS] MEM_w_addr,
    input wire [`ysyx_22040931_DATA_BUS] MEM_w_data,


    output reg          WB_w_ena,
    output reg [`ysyx_22040931_REG_BUS]  WB_w_addr,
    output reg [`ysyx_22040931_DATA_BUS] WB_w_data,
    //liushuixian
    output reg [`ysyx_22040931_INST_BUS] WB_instr,
    output reg [`ysyx_22040931_PC_BUS] WB_pc
);

//assign wb_valid = ~stall;
//assign mem_ready = wb_valid & wb_ready;

reg mem_now_valid;
wire mem_go;
assign mem_go = ~stall;
assign mem_ready = mem_go;   //当前时钟不是有效数据，或者当前已经处理完这个周期的活
assign mem_valid = mem_now_valid;

    always@(posedge clock) begin
        if(reset == 1'b1) begin
            mem_now_valid <= 0;
        end
        else if(mem_ready) begin
            mem_now_valid <= ex_valid;
        end
    end


    always @(posedge clock) begin
        if(reset == 1'b1) begin
            WB_w_ena <= `ysyx_22040931_N_ENA;
            WB_w_addr <= `ysyx_22040931_ZERO_REG;
            WB_w_data <= `ysyx_22040931_ZERO_NUM;
            WB_pc <= `ysyx_22040931_ZERO_PC;
            WB_instr <= `ysyx_22040931_NONE_INST;
        end
        else begin
            if(ex_valid & mem_ready) begin
                WB_w_ena <= MEM_w_ena;
                WB_w_addr <= MEM_w_addr;
                WB_w_data <= MEM_w_data;
                WB_pc <= MEM_pc;
                WB_instr <= MEM_instr;
            end
            else if(mem_go) begin
                WB_w_ena <= `ysyx_22040931_N_ENA;
                //WB_w_addr <= `ysyx_22040931_ZERO_REG;
                //WB_w_data <= `ysyx_22040931_ZERO_NUM;
                WB_pc <= `ysyx_22040931_ZERO_PC;
                WB_instr <= `ysyx_22040931_NONE_INST;
            end
        end
    end

endmodule
