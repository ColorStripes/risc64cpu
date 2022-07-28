//2022.7.15 xuxin
`include "defines.v"

module id_ex(
    input wire reset,
    input wire clock,
    input wire flush,     //记得flush与各级使能相与
    input wire stall,
    input wire nop,
    //wo shou
    input wire if_valid,
    input wire ex_ready,
    output wire id_ready,
    output wire id_valid,
    input wire [`ysyx_22040931_PC_BUS] ID_pc,
    input wire [`ysyx_22040931_INST_BUS] ID_instr,  
    //regfile
    input wire 		     ID_w_ena,
    input wire [`ysyx_22040931_REG_BUS]  ID_w_addr,
    input wire [`ysyx_22040931_DATA_BUS] ID_data1,
    input wire [`ysyx_22040931_DATA_BUS] ID_data2,
    input wire [`ysyx_22040931_DATA_BUS] ID_imm,
    
    //ex
    input wire [2 : 0]     ID_exop,
    input wire [`ysyx_22040931_ALU_BUS]    ID_aluop,
    //mem    
    input wire [2 : 0]   ID_memwop,
    input wire [2 : 0]   ID_memrop,
    input wire          ID_mem_ena,
    input wire           ID_mem_wr,


    output reg          EX_w_ena,
    output reg [`ysyx_22040931_REG_BUS]  EX_w_addr,
    output reg [`ysyx_22040931_DATA_BUS] EX_data1,
    output reg [`ysyx_22040931_DATA_BUS] EX_data2,
    output reg [`ysyx_22040931_DATA_BUS] EX_imm,

    output reg [2 : 0]     EX_exop,
    output reg [`ysyx_22040931_ALU_BUS]    EX_aluop,
    //mem    
    output reg [2 : 0]   EX_memwop,
    output reg [2 : 0]   EX_memrop,
    output reg          EX_mem_ena,
    output reg           EX_mem_wr,

    output reg [`ysyx_22040931_INST_BUS] EX_instr,
    output reg [`ysyx_22040931_PC_BUS] EX_pc
);

//assign ex_valid = ~stall;
//assign id_ready = ex_valid & ex_ready;

wire id_go;
reg id_now_valid;
assign id_go = ~stall;
assign id_ready =  id_go & ex_ready;   //当前时钟不是有效数据，或者当前已经处理完这个周期的活
assign id_valid = id_now_valid;

    always@(posedge clock) begin
        if(reset == 1'b1) begin
            id_now_valid <= 0;
        end
        else if(id_ready) begin
            id_now_valid <= if_valid;
        end
    end


    always @(posedge clock) begin
        if(reset == 1'b1) begin
            EX_w_ena <= `ysyx_22040931_N_ENA;
            EX_w_addr <= `ysyx_22040931_ZERO_REG;
            EX_data1 <= `ysyx_22040931_ZERO_NUM;
            EX_data2 <= `ysyx_22040931_ZERO_NUM;
            EX_imm <= `ysyx_22040931_ZERO_NUM;
            EX_exop <= `ysyx_22040931_No;
            EX_aluop <= `ysyx_22040931_NO;
            EX_memwop <= `ysyx_22040931_MNO;
            EX_memrop <= `ysyx_22040931_MNO;
            EX_mem_ena <= `ysyx_22040931_N_ENA;
            EX_mem_wr <= `ysyx_22040931_READ;
            EX_pc <= `ysyx_22040931_ZERO_PC;
            EX_instr <= `ysyx_22040931_NONE_INST;
        end
        else begin
            if(if_valid & id_ready) begin
                if(nop) begin
                    EX_w_ena <= `ysyx_22040931_N_ENA;
                    EX_w_addr <= `ysyx_22040931_ZERO_REG;
                    EX_data1 <= `ysyx_22040931_ZERO_NUM;
                    EX_data2 <= `ysyx_22040931_ZERO_NUM;
                    EX_imm <= `ysyx_22040931_ZERO_NUM;
                    EX_exop <= `ysyx_22040931_No;
                    EX_aluop <= `ysyx_22040931_NO;
                    EX_memwop <= `ysyx_22040931_MNO;
                    EX_memrop <= `ysyx_22040931_MNO;
                    EX_mem_ena <= `ysyx_22040931_N_ENA;
                    EX_mem_wr <= `ysyx_22040931_READ;
                    EX_pc <= `ysyx_22040931_ZERO_PC;
                    EX_instr <= `ysyx_22040931_NONE_INST;
                end
                else begin
                    EX_w_ena <= ID_w_ena;
                    EX_w_addr <= ID_w_addr;
                    EX_data1 <= ID_data1;
                    EX_data2 <= ID_data2;
                    EX_imm <= ID_imm;
                    EX_exop <= ID_exop;
                    EX_aluop <= ID_aluop;
                    EX_memwop <= ID_memwop;
                    EX_memrop <= ID_memrop;
                    EX_mem_ena <= ID_mem_ena;
                    EX_mem_wr <= ID_mem_wr;
                    EX_pc <= ID_pc;
                    EX_instr <= ID_instr;
                end
            end
            // else if(id_go) begin
            //     EX_w_ena <= `ysyx_22040931_N_ENA;
            //     EX_w_addr <= `ysyx_22040931_ZERO_REG;
            //     EX_data1 <= `ysyx_22040931_ZERO_NUM;
            //     EX_data2 <= `ysyx_22040931_ZERO_NUM;
            //     EX_imm <= `ysyx_22040931_ZERO_NUM;
            //     EX_exop <= `ysyx_22040931_No;
            //     EX_aluop <= `ysyx_22040931_NO;
            //     EX_memwop <= `ysyx_22040931_MNO;
            //     EX_memrop <= `ysyx_22040931_MNO;
            //     EX_mem_ena <= `ysyx_22040931_N_ENA;
            //     EX_mem_wr <= `ysyx_22040931_READ;
            //     EX_pc <= `ysyx_22040931_ZERO_PC;
            //     EX_instr <= `ysyx_22040931_NONE_INST;
            // end
        end
    end

endmodule
