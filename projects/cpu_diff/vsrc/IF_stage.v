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
    output wire [63 : 0] IF_pc,
    output wire [31 : 0] instr
);

wire [63 : 0] sum;
wire [63 : 0] pc_i;
wire [63 : 0] pc_f;
wire I_M_e;




reg [63:0] rdata;
RAMHelper ROM(
  .clk              (clk),
  .en               (I_M_e),
  .rIdx             ((IF_pc - `PC_START) >> 3),
  .rdata            (rdata),
  .wIdx             (0),
  .wdata            (0),
  .wmask            (0),
  .wen              (0)
);

assign instr = IF_pc[2] ? rdata[63 : 32] : rdata[31 : 0];

MUX MUX_PC(
    .data1(pc_id),
    .data2(new_pc),
    .ch(flush),


    .data(pc_f)
);

PC PC(
  .clk(clk),
  .rst(rst),
  .pc_i(pc_i),
  .pc_con(pc_con),
  .new_pc(new_pc),
  .flush(flush),

  .I_M_e(I_M_e),
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
    .pc_id(pc_f),
    .add_pc(sum),
    .branch(branch),
    .pc_con(pc_con),


    .wash(wash),
    .pc(pc_i)
);

endmodule