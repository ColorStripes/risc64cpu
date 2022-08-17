//2022.6.23 xuxin
`include "defines.v"

module PC(
  input wire reset,
  input wire clock,
  input wire pc_ready,
  input wire [`PC_BUS] pc_i,

  output reg fetch_enb,
  output reg [`PC_BUS] pc_o
);

    always @ (posedge clock) begin
      if(reset == 1'b1) begin
        fetch_enb <= 1'b0;
      end
      else begin
        fetch_enb <= 1'b1;
      end
    end

    always @ (posedge clock) begin
      if(fetch_enb == 1'b0) begin
        pc_o <= `ZERO_PC;
      end
      else begin
          if(pc_ready) begin
            pc_o <= pc_i;
          end
      end
    end

endmodule
