
//2021.8.3
//xu xin

`include "defines.v"

module ysyx_210457_PC(
  input wire clock,
  input wire reset,
  input wire [`PC_BUS] pc_i,
  input wire pc_con,
  input wire [`PC_BUS] new_pc,
  input wire flush,	
  input wire stall,                

  output reg I_M_e,
  output reg [`PC_BUS] pc
                           
);

always@( posedge clock ) begin
    if( reset == 1'b1 ) begin
      I_M_e <= 1'b0;
    end
    else begin
      I_M_e <= 1'b1;
    end
end


always@( posedge clock ) begin
    if(reset == 1'b1) begin
       pc <= `PC_START ;
    end
    else begin
        if( I_M_e == 1'b0 ) begin
            pc <= `PC_START ;
        end
        else begin  
            if(flush == 1'b1) begin
               pc <= new_pc;
            end  
            else if(~stall) begin
                if (pc_con == 1'b0) begin
                    pc <= pc_i;
                end
            end 
        end
    end
end


endmodule
