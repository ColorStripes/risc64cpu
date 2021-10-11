
//2021.8.4
//xu xin

`include "defines.v"

module ysyx_210457_IF_stage (
    input wire reset,
    input wire clock,
    input wire [`PC_BUS] branch,
    input wire mux_pc,
    input wire pc_con,
    input wire [`PC_BUS] pc_id,
    input wire [`PC_BUS] new_pc,
    input wire flush,
    input wire stall,
    input wire id_forecase,
    input wire error_branch,

    output wire [`PC_BUS] if_branch,
    output wire if_forecase,
    output wire wash,
    output wire [`INST_BUS] instr,

    output wire if_valid,                  //AXI
    input  wire [31 : 0] if_data_read,//
    output wire [`PC_BUS] IF_pc,//
    output wire [1 : 0] if_size,//
    output wire if_req//

);
assign if_branch = pc_i;

wire [`PC_BUS] sum;
wire [`PC_BUS] pc_i;

assign if_size = `SIZE_D;
assign instr = if_data_read;
assign if_req = `REQ_READ;


ysyx_210457_PC PC(
  .clock(clock),
  .reset(reset),
  .pc_i(pc_i),
  .pc_con(pc_con),
  .new_pc(new_pc),
  .flush(flush),
  .stall(stall),

  .I_M_e(if_valid),
  .pc(IF_pc)
  
);

ysyx_210457_ADD ADD (
    .num1(64'd4),
    .num2(IF_pc),

    .sum(sum)
);

ysyx_210457_forecase forecase (
    .reset(reset),
    .clock(clock),
    .mux_pc(mux_pc),
    .pc_id(pc_id),
    .add_pc(sum),
    .branch(branch),
    .stall(stall),
    .id_forecase(id_forecase),
    .error_branch(error_branch),

    .wash(wash),
    .if_forecase(if_forecase),
    .pc(pc_i)
);

endmodule