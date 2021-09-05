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

    output wire wash,
    output wire [63 : 0] IF_pc,
    output wire [31 : 0] instr
);

wire [63 : 0] sum;
wire [63 : 0] pc_i;
wire I_M_e

PC PC(
  .clk(clk),
  .rst(rst),
  .pc_i(pc_i),
  .pc_con(pc_con),

  .I_M_e(I_M_e),
  .pc(IF_pc)
  
);


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

assign instr = pc[2] ? rdata[63 : 32] : rdata[31 : 0];



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


    .wash(wash),
    .pc(pc_i)
);

endmodule