//2021.9.18
//xu xin
`include "defines.v"



module Clint (
    input wire clk,
    input wire rst,
    input wire [`REG_BUS] ex_mem_waddr,
    input wire [`REG_BUS] ex_mem_raddr,
    input wire [`REG_BUS] ex_stor_data,
    input wire ex_mem_wr,
    input wire ex_mem_ena,

    output reg clint,

    output reg time_inter,
    output reg [`REG_BUS] clint_data

);
    reg [31 : 0] msip;
    reg [`REG_BUS] mtime;
    reg [`REG_BUS] mtimecmp;


    always @(posedge clk) begin
        if(rst == 1'b1) begin
            mtime <= `ZERO_WORD;
            mtimecmp <= `TIME;
            msip <= `ZERO_WORD;
            time_inter <= 1'b0;
        end
        else begin
            if(mtime != 64'hffff_ffff_ffff_ffff) begin
                mtime <= mtime + 1;
            end
            else begin
                mtime <= 64'h0;
            end

            if((mtimecmp != 64'h00000000) && (mtime >= mtimecmp)) begin
                time_inter <= 1'b1;
            end
            else begin
                time_inter <= 1'b0;
            end

            if(ex_mem_wr & ex_mem_ena) begin
                case(ex_mem_waddr)
                 `msip:begin
                     msip <= ex_stor_data;
                 end
                 `mtimecmp:begin
                     mtimecmp <= ex_stor_data;
                 end
                 `mtime:begin
                     mtime <= ex_stor_data;
                 end
                 default:begin
                    
                 end
                endcase
            end

        end  
    end









    always @( * ) begin                      //read
        if (rst == 1'b1) begin
			clint_data = `ZERO_WORD;
		end
        else begin
            clint_data = `ZERO_WORD;
            if(~ex_mem_wr & ex_mem_ena) begin
                case(ex_mem_raddr)
                     `msip:begin
                         clint_data = msip;
                     end
                     `mtimecmp:begin
                         clint_data = mtimecmp;
                     end
                     `mtime:begin
                         clint_data = mtime;
                     end
                     default:begin
                         clint_data = `ZERO_WORD;
                     end
                endcase
            end
            else begin
                clint_data = `ZERO_WORD;
            end 
        end
    end



                                                  
always @(posedge clk) begin                                   //difftest
    if(rst == 1'b1) begin
        clint <= 1'b0;
    end
    else begin
        clint <= 1'b0;
        if(~ex_mem_wr & ex_mem_ena) begin
            if((ex_mem_raddr == `msip) || (ex_mem_raddr == `mtimecmp) || (ex_mem_raddr == `mtime)) begin
                clint <= 1'b1;
            end
        end
        if(ex_mem_wr & ex_mem_ena) begin
            if((ex_mem_waddr == `msip) || (ex_mem_waddr == `mtimecmp) || (ex_mem_waddr == `mtime)) begin
                clint <= 1'b1;
            end
        end
    end  
end




endmodule