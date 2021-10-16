//2021.9.18
//xu xin
`timescale 1ns / 1ps

`define ZERO_WORD  64'h00000000_00000000
`define ZERO_PC    64'h00000000_00000000
`define ZERO_ADDR  32'h00000000
`define ZERO_INST  32'h00000000    
`define REG_BUS    63 : 0 
`define PC_BUS     63 : 0 
`define ADDR_BUS   31 : 0  
`define INST_BUS   31 : 0 
`define ZERO_ENA   1'b0
`define ZERO_REG_ADDR   5'b00000

//Clint
`define msip 32'h2000000
`define mtimecmp 32'h2004000
`define mtime 32'h200bff8
`define TIME 64'd00000



module ysyx_210457_Clint (
    input wire clock,
    input wire reset,
    input wire [`ADDR_BUS] ex_mem_waddr,
    input wire [`ADDR_BUS] ex_mem_raddr,
    input wire [`REG_BUS] ex_stor_data,
    input wire ex_mem_wr,
    input wire ex_mem_ena,


    output reg time_inter,
    output reg [`REG_BUS] clint_data

);
    reg [`REG_BUS] msip;
    reg [`REG_BUS] mtime;
    reg [`REG_BUS] mtimecmp;


    always @(posedge clock) begin
        if(reset == 1'b1) begin
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

            if(mtime >= mtimecmp) begin
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
        if (reset == 1'b1) begin
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



                                                  




endmodule
