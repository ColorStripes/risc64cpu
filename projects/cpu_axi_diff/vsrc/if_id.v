//2022.7.15 xuxin
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
    input wire [`ysyx_22040931_PC_BUS] IF_pre_branch,
    input wire [`ysyx_22040931_PC_BUS]   IF_pc,
    input wire [`ysyx_22040931_INST_BUS] IF_instr,


    output reg ID_pre_jump,
    output reg [`ysyx_22040931_PC_BUS] ID_pre_branch,
    output reg [`ysyx_22040931_PC_BUS]   ID_pc,
    output reg [`ysyx_22040931_INST_BUS] ID_instr
);

//assign id_valid =  ~stall;
/////assign if_ready = id_valid & id_ready;
reg if_now_valid;
wire if_go;
assign if_go = ~stall;
assign if_ready = if_go & id_ready;   //当前时钟不是有效数据，或者当前已经处理完这个周期的活
assign if_valid = if_now_valid;

    always@(posedge clock) begin
        if(reset == 1'b1) begin
            if_now_valid <= 0;
        end
        else if(if_ready) begin
            if_now_valid <= pc_valid;
        end
    end

    always @(posedge clock) begin
        if(reset == 1'b1) begin
            ID_pc <= `ysyx_22040931_ZERO_PC;
            ID_instr <= `ysyx_22040931_NONE_INST;
            ID_pre_jump <= 1'b0;
            ID_pre_branch <= `ysyx_22040931_ZERO_PC;
        end
        else begin
            if(pc_valid & if_ready) begin
                if(nop) begin
                    ID_pc <= `ysyx_22040931_ZERO_PC;
                    ID_instr <= `ysyx_22040931_NONE_INST;
                    ID_pre_jump <= 1'b0;
                    ID_pre_branch <= `ysyx_22040931_ZERO_PC;
                end    
                else begin
                    ID_pc <= IF_pc;
                    ID_instr <= IF_instr;
                    ID_pre_jump <= IF_pre_jump;
                    ID_pre_branch <= IF_pre_branch;
                end 
            end
            // else if(if_go) begin
            //     ID_pc <= `ysyx_22040931_ZERO_PC;
            //     ID_instr <= `ysyx_22040931_NONE_INST;
            //     ID_pre_jump <= 1'b0;
            //     ID_pre_branch <= `ysyx_22040931_ZERO_PC;
            // end
        end
    end

endmodule
