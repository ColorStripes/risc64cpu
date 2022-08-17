//2022.8.13 xuxin
`include "defines.v"

module if_id(
    input wire reset,
    input wire clock,
    input wire flush,
    input wire stall,
    input wire nop,
    //wo shou
    input wire pc_valid,
    input wire id_ready,
    output wire if_ready,
    output wire if_valid,
    
    input wire IF_pre_jump,
    input wire [`PC_BUS] IF_pre_branch,
    input wire [`PC_BUS]   IF_pc,
    input wire [`INST_BUS] IF_instr,


    output reg ID_pre_jump,
    output reg [`PC_BUS] ID_pre_branch,
    output reg [`PC_BUS]   ID_pc,
    output reg [`INST_BUS] ID_instr
);


reg if_now_valid;
wire if_go;
assign if_go = ~stall | flush;
assign if_ready = if_go & id_ready;   //当前时钟不是有效数据，或者当前已经处理完这个周期的活
assign if_valid = if_now_valid;

    always@(posedge clock) begin
        if(reset == 1'b1) begin
            if_now_valid <= 0;
        end
        else if(if_ready) begin
            if_now_valid <= pc_valid & ~flush;
        end
    end

    always @(posedge clock) begin
        if(reset == 1'b1) begin
            ID_pc <= `ZERO_PC;
            ID_instr <= `NONE_INST;
            ID_pre_jump <= 1'b0;
            ID_pre_branch <= `ZERO_PC;
        end
        else if(flush) begin
            ID_pc <= `ZERO_PC;
            ID_instr <= `NONE_INST;
            ID_pre_jump <= 1'b0;
            ID_pre_branch <= `ZERO_PC;
        end
        else begin
            if(pc_valid & if_ready) begin
                if(nop) begin
                    ID_pc <= `ZERO_PC;
                    ID_instr <= `NONE_INST;
                    ID_pre_jump <= 1'b0;
                    ID_pre_branch <= `ZERO_PC;
                end    
                else begin
                    ID_pc <= IF_pc;
                    ID_instr <= IF_instr;
                    ID_pre_jump <= IF_pre_jump;
                    ID_pre_branch <= IF_pre_branch;
                end 
            end
        end
    end

endmodule

