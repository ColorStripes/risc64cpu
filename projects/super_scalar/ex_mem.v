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
    input wire [`PC_BUS] EX_pc,
    input wire [`INST_BUS] EX_instr,
    //regfile
    input wire         EX_w_ena,
    input wire [`REG_BUS] EX_w_addr,
    input wire [`DATA_BUS] EX_w_data,
    //csr
    input wire EX_csr_w_ena,
    input wire [`CSR_BUS] EX_csr_w_addr,
    input wire [`DATA_BUS] EX_csr_w_data,
    //mem
    input wire [2 : 0]   EX_memwop,
    input wire [2 : 0]   EX_memrop,
    input wire          EX_mem_ena,
    input wire           EX_mem_wr,    
    input wire [`MEM_BUS] EX_mem_addr,
    input wire [`DATA_BUS] EX_mem_data,
    //except
    input wire [`EXCEPT_BUS] EX_except,

    //regfile
    output reg          MEM_w_ena,
    output reg [`REG_BUS] MEM_w_addr,
    output reg [`DATA_BUS] MEM_w_data,
    //csr
    output wire MEM_csr_w_ena,
    output wire [`CSR_BUS] MEM_csr_w_addr,
    output wire [`DATA_BUS] MEM_csr_w_data,
    //mem
    output reg [2 : 0]   MEM_memwop,
    output reg [2 : 0]   MEM_memrop,
    output reg           MEM_mem_ena,
    output reg           MEM_mem_wr,
    output reg [`MEM_BUS]  MEM_mem_addr,
    output reg [`DATA_BUS] MEM_mem_stor_data,
    //except
    output wire [`EXCEPT_BUS] MEM_except,
    //liushuixian
    output reg [`INST_BUS] MEM_instr,
    output reg [`PC_BUS]  MEM_pc

);




reg ex_now_valid;
wire ex_go;
assign ex_go = ~stall;

assign ex_ready = ex_go & mem_ready;   //当前时钟不是有效数据，或者当前已经处理完这个周期的活
assign ex_valid = ex_now_valid ;

    always@(posedge clock) begin
        if(reset == 1'b1) begin
            ex_now_valid <= 0;
        end
        else if(ex_ready) begin
            ex_now_valid <= id_valid & ~flush;
        end
    end


    always @(posedge clock) begin
        if(reset == 1'b1) begin
            MEM_w_ena <= `N_ENA;
            MEM_w_addr <= `ZERO_REG;
            MEM_memwop <= `MNO;
            MEM_memrop <= `MNO;
            MEM_mem_ena <= `N_ENA;
            MEM_mem_wr <= `READ;
            MEM_mem_addr <= `ZERO_NUM;
            MEM_mem_stor_data <= `ZERO_NUM;
            MEM_pc <= `ZERO_PC;
            MEM_instr <= `NONE_INST;
            MEM_csr_w_ena  <= `N_ENA;
            MEM_csr_w_addr <= `ZERO_CSR;
            MEM_csr_w_data <= `ZERO_NUM;
            MEM_except <= `NO_EXCEPT;
        end
        else if(flush) begin
            MEM_w_ena <= `N_ENA;
            MEM_w_addr <= `ZERO_REG;
            MEM_memwop <= `MNO;
            MEM_memrop <= `MNO;
            MEM_mem_ena <= `N_ENA;
            MEM_mem_wr <= `READ;
            MEM_mem_addr <= `ZERO_NUM;
            MEM_mem_stor_data <= `ZERO_NUM;
            MEM_pc <= `ZERO_PC;
            MEM_instr <= `NONE_INST;
            MEM_csr_w_ena  <= `N_ENA;
            MEM_csr_w_addr <= `ZERO_CSR;
            MEM_csr_w_data <= `ZERO_NUM;
            MEM_except <= `NO_EXCEPT;
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
                MEM_csr_w_ena  <= EX_csr_w_ena ;
                MEM_csr_w_addr <= EX_csr_w_addr;
                MEM_csr_w_data <= EX_csr_w_data;
                MEM_except <= EX_except;
            end
        end 
    end

    always @(posedge clock) begin
        if(EX_instr == 32'h7b) begin
        $write("%c",MEM_w_data);
        $fflush();
        end
    end

endmodule
