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
    input wire [`PC_BUS] ID_pc,
    input wire [`INST_BUS] ID_instr,  
    //regfile
    input wire 		     ID_w_ena,
    input wire [`REG_BUS]  ID_w_addr,
    input wire [`DATA_BUS] ID_data1,
    input wire [`DATA_BUS] ID_data2,
    input wire [`DATA_BUS] ID_imm,
    //csr
    input wire ID_csr_ena,
    input wire [`CSR_BUS] ID_csr_addr,
    //ex
    input wire [2 : 0]     ID_exop,
    input wire [`ALU_BUS]    ID_aluop,
    //mem    
    input wire [2 : 0]   ID_memwop,
    input wire [2 : 0]   ID_memrop,
    input wire          ID_mem_ena,
    input wire           ID_mem_wr,
    input wire [`EXCEPT_BUS] ID_except,


    output reg          EX_w_ena,
    output reg [`REG_BUS]  EX_w_addr,
    output reg [`DATA_BUS] EX_data1,
    output reg [`DATA_BUS] EX_data2,
    output reg [`DATA_BUS] EX_imm,
    //csr
    output wire EX_csr_ena,
    output wire [`CSR_BUS] EX_csr_addr,
    //ex
    output reg [2 : 0]     EX_exop,
    output reg [`ALU_BUS]    EX_aluop,
    //mem    
    output reg [2 : 0]   EX_memwop,
    output reg [2 : 0]   EX_memrop,
    output reg          EX_mem_ena,
    output reg           EX_mem_wr,
    output reg [`EXCEPT_BUS] EX_except,

    output reg [`INST_BUS] EX_instr,
    output reg [`PC_BUS] EX_pc
);



wire id_go;
reg id_now_valid;
assign id_go = ~stall;
assign id_ready =  id_go & ex_ready;   //当前时钟不是有效数据，或者当前已经处理完这个周期的活
assign id_valid = id_now_valid ;

    always@(posedge clock) begin
        if(reset == 1'b1) begin
            id_now_valid <= 0;
        end
        else if(id_ready) begin
            id_now_valid <= if_valid & ~flush;
        end
    end


    always @(posedge clock) begin
        if(reset == 1'b1) begin
            EX_w_ena <= `N_ENA;
            EX_w_addr <= `ZERO_REG;
            EX_data1 <= `ZERO_NUM;
            EX_data2 <= `ZERO_NUM;
            EX_imm <= `ZERO_NUM;
            EX_exop <= `No;
            EX_aluop <= `NO;
            EX_memwop <= `MNO;
            EX_memrop <= `MNO;
            EX_mem_ena <= `N_ENA;
            EX_mem_wr <= `READ;
            EX_pc <= `ZERO_PC;
            EX_instr <= `NONE_INST;
            EX_csr_ena  <= `N_ENA;
            EX_csr_addr <= `ZERO_CSR;
            EX_except <= `NO_EXCEPT;
        end
        else if(flush) begin
            EX_w_ena <= `N_ENA;
            EX_w_addr <= `ZERO_REG;
            EX_data1 <= `ZERO_NUM;
            EX_data2 <= `ZERO_NUM;
            EX_imm <= `ZERO_NUM;
            EX_exop <= `No;
            EX_aluop <= `NO;
            EX_memwop <= `MNO;
            EX_memrop <= `MNO;
            EX_mem_ena <= `N_ENA;
            EX_mem_wr <= `READ;
            EX_pc <= `ZERO_PC;
            EX_instr <= `NONE_INST;
            EX_csr_ena  <= `N_ENA;
            EX_csr_addr <= `ZERO_CSR;
            EX_except <= `NO_EXCEPT;
        end
        else begin
            if(if_valid & id_ready) begin
                if(nop) begin
                    EX_w_ena <= `N_ENA;
                    EX_w_addr <= `ZERO_REG;
                    EX_data1 <= `ZERO_NUM;
                    EX_data2 <= `ZERO_NUM;
                    EX_imm <= `ZERO_NUM;
                    EX_exop <= `No;
                    EX_aluop <= `NO;
                    EX_memwop <= `MNO;
                    EX_memrop <= `MNO;
                    EX_mem_ena <= `N_ENA;
                    EX_mem_wr <= `READ;
                    EX_pc <= `ZERO_PC;
                    EX_instr <= `NONE_INST;
                    EX_csr_ena  <= `N_ENA;
                    EX_csr_addr <= `ZERO_CSR;
                    EX_except <= `NO_EXCEPT;
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
                    EX_csr_ena  <= ID_csr_ena;
                    EX_csr_addr <= ID_csr_addr;
                    EX_except <= ID_except;
                end
            end
        end
    end

endmodule
