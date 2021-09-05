//2021.8.3
//xu xin


`include "defines.v"

module PC(
  input wire clk,
  input wire rst,
  input wire [`PC_BUS] pc_i,
  input wire pc_con,

  output reg I_M_e,
  output reg [`PC_BUS] pc 
);
parameter PC_START_RESET = `PC_START-4;

always@( posedge clk )
begin
  if( rst == 1'b1 )
  begin
    I_M_e <= 1'b0;
  end
  else
  begin
    I_M_e <= 1'b1;
  end
end

always@( posedge clk )
begin
  if( I_M_e == 1'b0 )
  begin
    pc <= PC_START_RESET ;
  end
  else
  begin
    if (pc_con == 1'b0) begin
      pc <= pc_i;
    end
  end
end
endmodule