//2022.6.28 xuxin
`include "defines.v"

module ysyx_22040931_IF(
  
    input wire reset,
    input wire clock,
    input wire flush,
    input wire stall,
    //wo shou
    input wire if_ready,
    output wire pc_valid,
    output wire pc_ready,//

    //forecase
    input wire error_pre,
    input wire id_jump,
    input wire [1 : 0] id_jumptype,
    input wire [`ysyx_22040931_PC_BUS] id_pc,
    input wire [`ysyx_22040931_PC_BUS] id_branch,



    //forecase
    output wire pre_jump,
    output wire [`ysyx_22040931_PC_BUS] pre_branch,
   
    
    output wire [`ysyx_22040931_PC_BUS]   if_pc
    //output wire [`ysyx_22040931_INST_BUS] instr

);

reg pc_now_valid;
wire pc_go;
assign pc_go = ~stall;
assign pc_ready = pc_go & if_ready;   //当前时钟不是有效数据，或者当前已经处理完这个周期的活

//assign pc_valid = pc_now_valid & pc_go;
//     always@(posedge clock) begin
//         if(reset == 1'b1) begin
//             pc_now_valid <= 0;
//         end
//         else if(pc_ready) begin
//             pc_now_valid <= 1;
//         end
//     end



predictor predictor(
    .reset(reset),
    .clock(clock),
    .pc_ready(pc_ready),
    .nop(error_pre),
    .id_branch(id_branch),
    .id_jumptype(id_jumptype),
    .id_jump(id_jump),
    .id_pc(id_pc),
    .pc(if_pc),

    
    .jump(pre_jump),
    .branch(pre_branch)
);


wire [`ysyx_22040931_PC_BUS] pc_i;
//assign pc_i = error_pre ? (id_jump ? id_branch : id_pc + 4) : (pre_jump ? pre_branch : if_pc + 4);
assign pc_i = id_jump ? id_branch :  if_pc + 4;


ysyx_22040931_PC ysyx_22040931_PC(
  
  .reset(reset),
  .clock(clock),
  .pc_ready(pc_ready),
  .pc_i(pc_i),

  .pc_o(if_pc),
  .fetch_enb(pc_valid)
  
);

endmodule
