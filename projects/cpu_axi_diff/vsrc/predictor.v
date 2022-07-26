//2022.7.19 xuxin
`include "defines.v"

module predictor(
    input wire reset,
    input wire clock,
    input wire pc_ready,
    input wire nop,
    input wire [`ysyx_22040931_PC_BUS] id_branch,
    input wire [1 : 0] id_jumptype,
    input wire id_jump,
    input wire [`ysyx_22040931_PC_BUS] id_pc,
    input wire [`ysyx_22040931_PC_BUS] pc,

    
    output wire jump,
    output wire [`ysyx_22040931_PC_BUS] branch
);

    wire valid_pre, dir_jump, tar_hit;
    assign valid_pre = pc_ready & ~nop;
    assign jump = dir_jump & tar_hit;

    direction_predictor direction_predictor(
    .reset(reset),
    .clock(clock),
    .valid_pre(valid_pre),

    .id_pc(id_pc),
    .id_jump(id_jump),          //jump?
    .id_jumptype(id_jumptype),
    .pc(pc),


    .jump(dir_jump)
    );


    target_predictor target_predictor(
    .reset(reset),
    .clock(clock),
    .valid_pre(valid_pre),
    
    .id_pc(id_pc),
    .id_branch(id_branch), 
    .id_jumptype(id_jumptype),  //10call 11ret
    .pc(pc),

    .branch(branch),
    .hit(tar_hit)
    );

endmodule
