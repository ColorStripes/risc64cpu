//2021.8.4
//xu xin
`include "defines.v"


module IF_stage (
    input wire rst,
    input wire clk,
    input wire [63 : 0] branch,
    input wire mux_pc,
    input wire pc_con,
    input wire [63 : 0] pc_id,
    input wire [`PC_BUS] new_pc,
    input wire flush,

    output wire wash,
    output wire [`INST_BUS] instr,

    output wire if_valid,                  //AXI
    input  wire if_ready,//
    input  wire [63 : 0] if_data_read,//
    output wire [63 : 0] IF_pc,//
    output wire [1 : 0] if_size,//
    output wire [1 : 0] if_req//

);

wire [63 : 0] sum;
wire [63 : 0] pc_i;
wire I_M_e;

assign if_size = `SIZE_W;
assign instr = if_data_read[`INST_BUS];
assign if_req = `REQ_READ;


PC PC(
  .clk(clk),
  .rst(rst),
  .pc_i(pc_i),
  .pc_con(pc_con),
  .new_pc(new_pc),
  .flush(flush),
  .if_ready(if_ready),

  .I_M_e(if_valid),
  .pc(IF_pc)
  
);

ADD ADD (
    .num1(64'd4),
    .num2(IF_pc),

    .sum(sum)
);

forecase forecase (
    .rst(rst),
    .clk(clk),
    .mux_pc(mux_pc),
    .pc_id(pc_id),
    .add_pc(sum),
    .branch(branch),
    .pc_con(pc_con),


    .wash(wash),
    .pc(pc_i)
);

endmodule