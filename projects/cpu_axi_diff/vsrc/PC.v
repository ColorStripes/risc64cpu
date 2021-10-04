//2021.8.3
//xu xin


`include "defines.v"

module PC(
  input wire clk,
  input wire rst,
  input wire [`PC_BUS] pc_i,
  input wire pc_con,
  input wire [`PC_BUS] new_pc,
  input wire flush,	
  input wire if_ready,                //AXI

  output wire I_M_e,
  output reg [`PC_BUS] pc
                           
);



wire handshake_done = I_M_e & if_ready;
reg [63:0] addr;
reg fetched;

// fetch an instruction
always @( posedge clk ) begin
  if (rst) begin
    //pc <= `PC_START;
    pc <= `PC_START;
    fetched <= 0;
  end
  else if ( handshake_done ) begin
    //pc <= pc;
    pc <= pc + 4;
    fetched <= 1;
    //inst <= if_data_read[31:0];
  end
  else begin
    fetched <= 0;
  end
end

assign I_M_e = 1'b1;

endmodule