//2021.8.5
//xu xin
`include "defines.v"

module MEM_stage (
    input wire rst,
    input wire [`REG_BUS] ex_w_data,
    input wire ex_w_ena,
    input wire [4 : 0] ex_w_addr,
    
    input wire [`REG_BUS] ex_mem_waddr,
    input wire [`REG_BUS] ex_mem_raddr,
    input wire [`REG_BUS] ex_stor_data,
    input wire [4 : 0] ex_memop,

    input wire ex_mem_wr,
    input wire ex_mem_ena,
    input wire [`REG_BUS] mem_data,

    input wire [`PC_BUS] ex_pc,
    input wire [`INST_BUS] ex_instr,

    output wire [`INST_BUS] mem_instr,
    output wire [`PC_BUS] mem_pc,

    output reg [`REG_BUS] mem_w_data,
    output reg mem_w_ena,
    output reg [4 : 0] mem_w_addr,

    output reg [`REG_BUS] mem_mem_waddr,
    output reg [`REG_BUS] mem_mem_raddr,
    output reg [`REG_BUS] mem_sel,
    output reg [`REG_BUS] mem_stor_data,
    output reg mem_wr,
    output reg mem_mem_ena
);
    assign mem_pc = ex_pc;
    assign mem_instr = ex_instr;

    always @(*) begin
        if(rst == 1'b1) begin
            mem_w_data = `ZERO_WORD;
            mem_w_ena = 1'b0;
            mem_w_addr = `ZERO_REG_ADDR;
            mem_mem_waddr = `ZERO_WORD;
            mem_mem_raddr = `ZERO_WORD;
            mem_sel = 64'h0000_0000_0000_0000;
            mem_stor_data = `ZERO_WORD;
            mem_wr = 1'b0;
            mem_mem_ena = 1'b0;
        end
        else begin
            mem_w_data = ex_w_data;
            mem_w_ena = ex_w_ena;
            mem_w_addr = ex_w_addr;
            mem_mem_waddr = ex_mem_waddr;
            mem_mem_raddr = ex_mem_raddr;
            mem_stor_data = `ZERO_WORD;
            mem_sel = 64'h0000_0000_0000_0000;
            mem_wr = ex_mem_wr;
            mem_mem_ena = ex_mem_ena;
            case(ex_memop)
                 `R_ONE:begin
                     case(ex_mem_raddr[2 : 0])
                         3'b000:begin
                             mem_sel = 64'h0000_0000_0000_00ff;
                             mem_w_data = {{56{mem_data[7]}} , mem_data[7 : 0]};
                         end
                         3'b001:begin
                             mem_sel = 64'h0000_0000_0000_ff00;
                             mem_w_data = {{56{mem_data[15]}} , mem_data[15 : 8]};
                         end
                         3'b010:begin
                             mem_sel = 64'h0000_0000_00ff_0000;
                             mem_w_data = {{56{mem_data[23]}} , mem_data[23 : 16]};
                         end
                         3'b011:begin
                             mem_sel = 64'h0000_0000_ff00_0000;
                             mem_w_data = {{56{mem_data[31]}} , mem_data[31 : 24]};
                         end
                         3'b100:begin
                             mem_sel = 64'h0000_00ff_0000_0000;
                             mem_w_data = {{56{mem_data[39]}} , mem_data[39 : 32]};
                         end
                         3'b101:begin
                             mem_sel = 64'h0000_ff00_0000_0000;
                             mem_w_data = {{56{mem_data[48]}} , mem_data[47 : 40]};
                         end
                         3'b110:begin
                             mem_sel = 64'h00ff_0000_0000_0000;
                             mem_w_data = {{56{mem_data[55]}} , mem_data[55 : 48]};
                         end
                         3'b111:begin
                             mem_sel = 64'hff00_0000_0000_0000;
                             mem_w_data = {{56{mem_data[63]}} , mem_data[63 : 56]};
                         end
                     endcase 
                 end
                 `R_ONEu:begin                    
                     case(ex_mem_raddr[2 : 0])
                         3'b000:begin
                             mem_sel = 64'h0000_0000_0000_00ff;
                             mem_w_data = {{56{1'b0}} , mem_data[7 : 0]};
                         end
                         3'b001:begin
                             mem_sel = 64'h0000_0000_0000_ff00;
                             mem_w_data = {{56{1'b0}} , mem_data[15 : 8]};
                         end
                         3'b010:begin
                             mem_sel = 64'h0000_0000_00ff_0000;
                             mem_w_data = {{56{1'b0}} , mem_data[23 : 16]};
                         end
                         3'b011:begin
                             mem_sel = 64'h0000_0000_ff00_0000;
                             mem_w_data = {{56{1'b0}} , mem_data[31 : 24]};
                         end
                         3'b100:begin
                             mem_sel = 64'h0000_00ff_0000_0000;
                             mem_w_data = {{56{1'b0}} , mem_data[39 : 32]};
                         end
                         3'b101:begin
                             mem_sel = 64'h0000_ff00_0000_0000;
                             mem_w_data = {{56{1'b0}} , mem_data[47 : 40]};
                         end
                         3'b110:begin
                             mem_sel = 64'h00ff_0000_0000_0000;
                             mem_w_data = {{56{1'b0}} , mem_data[55 : 48]};
                         end
                         3'b111:begin
                             mem_sel = 64'hff00_0000_0000_0000;
                             mem_w_data = {{56{1'b0}} , mem_data[63 : 56]};
                         end
                     endcase  
                 end
                 `R_DOU:begin
                     case(ex_mem_raddr[2 : 1])
                         2'b00:begin
                             mem_sel = 64'h0000_0000_0000_ffff;
                             mem_w_data = {{48{mem_data[15]}} , mem_data[15 : 0]};
                         end
                         2'b01:begin
                             mem_sel = 64'h0000_0000_ffff_0000;
                             mem_w_data = {{48{mem_data[31]}} , mem_data[31 : 16]};
                         end
                         2'b10:begin
                             mem_sel = 64'h0000_ffff_0000_0000;
                             mem_w_data = {{48{mem_data[47]}} , mem_data[47 : 32]};
                         end
                         2'b11:begin
                             mem_sel = 64'hffff_0000_0000_0000;
                             mem_w_data = {{48{mem_data[63]}} , mem_data[63 : 48]};
                         end 
                     endcase  
                 end
                 `R_DOUu:begin
                     case(ex_mem_raddr[2 : 1])
                         2'b00:begin
                             mem_sel = 64'h0000_0000_0000_ffff;
                             mem_w_data = {{48{1'b0}} , mem_data[15 : 0]};
                         end
                         2'b01:begin
                             mem_sel = 64'h0000_0000_ffff_0000;
                             mem_w_data = {{48{1'b0}} , mem_data[31 : 16]};
                         end
                         2'b10:begin
                             mem_sel = 64'h0000_ffff_0000_0000;
                             mem_w_data = {{48{1'b0}} , mem_data[47 : 32]};
                         end
                         2'b11:begin
                             mem_sel = 64'hffff_0000_0000_0000;
                             mem_w_data = {{48{1'b0}} , mem_data[63 : 48]};
                         end 
                     endcase
                 end
                 `R_FOR:begin
                     case(ex_mem_raddr[2])
                         1'b0:begin
                             mem_sel = 64'h0000_0000_ffff_ffff;
                             mem_w_data = {{32{mem_data[31]}} , mem_data[31 : 0]};
                         end
                         1'b1:begin
                             mem_sel = 64'hffff_ffff_0000_0000;
                             mem_w_data = {{32{mem_data[63]}} , mem_data[63 : 32]};
                         end
                     endcase
                 end
                 `R_FORu:begin
                     case(ex_mem_raddr[2])
                         1'b0:begin
                             mem_sel = 64'h0000_0000_ffff_ffff;
                             mem_w_data = {{32{1'b0}} , mem_data[31 : 0]};
                         end
                         1'b1:begin
                             mem_sel = 64'hffff_ffff_0000_0000;
                             mem_w_data = {{32{1'b0}} , mem_data[63 : 32]};
                         end
                     endcase
                 end
                 `R_EIG:begin
                     mem_sel = 64'hffff_ffff_ffff_ffff;
                     mem_w_data = mem_data;
                 end

                 //write
                 `W_ONE:begin
                     mem_mem_ena = 1'b1;
                     case(ex_mem_waddr[2 : 0])
                         3'b000:begin
                             mem_sel = 64'h0000_0000_0000_00ff;
                             mem_stor_data = {56'b0, ex_stor_data[7 : 0]};
                         end
                         3'b001:begin
                             mem_sel = 64'h0000_0000_0000_ff00;
                             mem_stor_data = {48'b0, ex_stor_data[7 : 0], 8'b0};
                         end
                         3'b010:begin
                             mem_sel = 64'h0000_0000_00ff_0000;
                             mem_stor_data = {40'b0, ex_stor_data[7 : 0], 16'b0};
                         end
                         3'b011:begin
                             mem_sel = 64'h0000_0000_ff00_0000;
                             mem_stor_data = {32'b0, ex_stor_data[7 : 0], 24'b0};
                         end
                         3'b100:begin
                             mem_sel = 64'h0000_00ff_0000_0000;
                             mem_stor_data = {24'b0, ex_stor_data[7 : 0], 24'b0};
                         end
                         3'b101:begin
                             mem_sel = 64'h0000_ff00_0000_0000;
                             mem_stor_data = {16'b0, ex_stor_data[7 : 0], 32'b0};
                         end
                         3'b110:begin
                             mem_sel = 64'h00ff_0000_0000_0000;
                             mem_stor_data = {8'b0, ex_stor_data[7 : 0], 40'b0};
                         end
                         3'b111:begin
                             mem_sel = 64'hff00_0000_0000_0000;
                             mem_stor_data = {ex_stor_data[7 : 0], 56'b0};
                         end
                     endcase  
                 end
                 `W_DOU:begin
                     mem_mem_ena = 1'b1;
                     case(ex_mem_waddr[2 : 1])
                         2'b00:begin
                             mem_sel = 64'h0000_0000_0000_ffff;
                             mem_stor_data = {48'b0, ex_stor_data[15 : 0]};
                         end
                         2'b01:begin
                             mem_sel = 64'h0000_0000_ffff_0000;
                             mem_stor_data = {32'b0, ex_stor_data[15 : 0], 16'b0};
                         end
                         2'b10:begin
                             mem_sel = 64'h0000_ffff_0000_0000;
                             mem_stor_data = {16'b0, ex_stor_data[15 : 0], 32'b0};
                         end
                         2'b11:begin
                             mem_sel = 64'hffff_0000_0000_0000;
                             mem_stor_data = {ex_stor_data[15 : 0], 48'b0};
                         end 
                     endcase
                 end
                 `W_FOR:begin
                     mem_mem_ena = 1'b1;
                     case(ex_mem_waddr[2])
                         1'b0:begin
                             mem_sel = 64'h0000_0000_ffff_ffff;
                             mem_stor_data = {32'b0, ex_stor_data[31 : 0]};
                         end
                         1'b1:begin
                             mem_sel = 64'hffff_ffff_0000_0000;
                             mem_stor_data = {ex_stor_data[31 : 0], 32'b0};
                         end
                     endcase
                 end
                 `W_EIG:begin
                     mem_sel = 64'hffff_ffff_ffff_ffff;
                     mem_mem_ena = 1'b1;
                 end
                 default:begin
                     mem_w_data = ex_w_data;
                     mem_sel = 64'h0000_0000_0000_0000;
                     mem_wr = 1'b0;
                     mem_mem_ena = 1'b0;
                 end
            endcase
        end
    end
endmodule