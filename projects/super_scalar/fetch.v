//2022.8.13 xuxin
`include "defines.v"

module fetch(
    input wire reset,
    input wire clock,
    //wo shou
    input wire if_ready,
    output wire pc_valid,
    output wire pc_ready,//

    

    input  wire [`FETCH_BUS]  icache_data,
    output wire [`PC_BUS]     if_pc,
    output wire [`FETCH_BUS]  fetch_group

);

reg pc_now_valid;
wire pc_go;
assign pc_go = ~stall;
assign pc_ready = pc_go & if_ready;   //当前时钟不是有效数据，或者当前已经处理完这个周期的活




wire [`PC_BUS] pc_i;
assign pc_i = error_pre  ? (id_jump ? id_branch : id_pc + (16 - id_pc[3 : 0])) : (pre_jump ? pre_branch : if_pc + (16 - if_pc[3 : 0]));



PC PC(
  
  .reset(reset),
  .clock(clock),
  .pc_ready(pc_ready),
  .pc_i(pc_i),

  .pc_o(if_pc),
  .fetch_enb(pc_valid)
  
);

 icache_data


endmodule
