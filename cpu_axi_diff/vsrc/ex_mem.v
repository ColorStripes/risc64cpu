//2022.7.15 xuxin
`include "defines.v"

module ex_mem(
    input wire reset,
    input wire clock,
    input wire flush,
    input wire stall,
    //wo shou
    input wire id_valid,
    input wire mem_ready,
    output wire ex_ready,
    output wire ex_valid,
    //liushuixian
    input wire [`ysyx_22040931_PC_BUS] EX_pc,
    input wire [`ysyx_22040931_INST_BUS] EX_instr,
    //regfile
    input wire         EX_w_ena,
    input wire [`ysyx_22040931_REG_BUS] EX_w_addr,
    input wire [`ysyx_22040931_DATA_BUS] EX_w_data,
    //mem
    input wire [2 : 0]   EX_memwop,
    input wire [2 : 0]   EX_memrop,
    input wire          EX_mem_ena,
    input wire           EX_mem_wr,    
    input wire [`ysyx_22040931_MEM_BUS] EX_mem_addr,
    input wire [`ysyx_22040931_DATA_BUS] EX_mem_data,


    output reg          MEM_w_ena,
    output reg [`ysyx_22040931_REG_BUS] MEM_w_addr,
    output reg [`ysyx_22040931_DATA_BUS] MEM_w_data,
    //mem
    output reg [2 : 0]   MEM_memwop,
    output reg [2 : 0]   MEM_memrop,
    output reg           MEM_mem_ena,
    output reg           MEM_mem_wr,
    output reg [`ysyx_22040931_MEM_BUS]  MEM_mem_addr,
    output reg [`ysyx_22040931_DATA_BUS] MEM_mem_stor_data,
    //liushuixian
    output reg [`ysyx_22040931_INST_BUS] MEM_instr,
    output reg [`ysyx_22040931_PC_BUS]  MEM_pc

);



//assign mem_valid = ~stall;
//assign ex_ready = mem_valid & mem_ready;
reg ex_now_valid;
wire ex_go;
assign ex_go = ~stall;

assign ex_ready = ex_go & mem_ready;   //当前时钟不是有效数据，或者当前已经处理完这个周期的活
assign ex_valid = ex_now_valid;

    always@(posedge clock) begin
        if(reset == 1'b1) begin
            ex_now_valid <= 0;
        end
        else if(ex_ready) begin
            ex_now_valid <= id_valid;
        end
    end


    always @(posedge clock) begin
        if(reset == 1'b1) begin
            MEM_w_ena <= `ysyx_22040931_N_ENA;
            MEM_w_addr <= `ysyx_22040931_ZERO_REG;
            MEM_memwop <= `ysyx_22040931_MNO;
            MEM_memrop <= `ysyx_22040931_MNO;
            MEM_mem_ena <= `ysyx_22040931_N_ENA;
            MEM_mem_wr <= `ysyx_22040931_READ;
            MEM_mem_addr <= `ysyx_22040931_ZERO_NUM;
            MEM_mem_stor_data <= `ysyx_22040931_ZERO_NUM;
            MEM_pc <= `ysyx_22040931_ZERO_PC;
            MEM_instr <= `ysyx_22040931_NONE_INST;
        end
        else begin
            if(id_valid & ex_ready) begin
                MEM_w_ena <= EX_w_ena; 
                MEM_w_addr <= EX_w_addr;
                MEM_w_data <= EX_w_data;
                MEM_memwop <= EX_memwop;
                MEM_memrop <= EX_memrop;
                MEM_mem_ena <= EX_mem_ena;
                MEM_mem_wr <= EX_mem_wr;
                MEM_mem_addr <= EX_mem_addr;
                MEM_mem_stor_data <= EX_mem_data;
                MEM_pc <= EX_pc;
                MEM_instr <= EX_instr;
            end
            // else if(ex_go) begin
            //     MEM_w_ena <= `ysyx_22040931_N_ENA;
            //     MEM_w_addr <= `ysyx_22040931_ZERO_REG;
            //     MEM_w_data <= `ysyx_22040931_ZERO_NUM;
            //     MEM_memwop <= `ysyx_22040931_MNO;
            //     MEM_memrop <= `ysyx_22040931_MNO;
            //     MEM_mem_ena <= `ysyx_22040931_N_ENA;
            //     MEM_mem_wr <= `ysyx_22040931_READ;
            //     MEM_mem_addr <= `ysyx_22040931_ZERO_NUM;
            //     MEM_mem_stor_data <= `ysyx_22040931_ZERO_NUM;
            //     MEM_pc <= `ysyx_22040931_ZERO_PC;
            //     MEM_instr <= `ysyx_22040931_NONE_INST;
            // end
        end 
    end

endmodule
