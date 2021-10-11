
//2021.8.5
//xu xin

`include "defines.v"

module ysyx_210457_MEM_stage (
    input wire reset,
    input wire time_inter,
    input wire [`REG_BUS] ex_w_data,
    input wire ex_w_ena,
    input wire [4 : 0] ex_w_addr,
    
    input wire [`REG_BUS] ex_mem_waddr,
    input wire [`REG_BUS] ex_mem_raddr,
    input wire [`REG_BUS] ex_stor_data,
    input wire [4 : 0] ex_memop,

    input wire ex_mem_wr,
    input wire ex_mem_ena,
    //input wire [`REG_BUS] mem_data,                   //delete for AXI

    input wire [`PC_BUS] ex_pc,
    input wire [`INST_BUS] ex_instr,

    input wire [11 : 0] ex_csr_addr,         ///csr
    input wire [`REG_BUS] ex_w_csr_data,
    input wire ex_csr_ena,
    input wire [`REG_BUS] ex_except_type,

    input wire [`REG_BUS] mepc,        //csr_read
    input wire [`REG_BUS] mip,
    input wire [`REG_BUS] mie,
    input wire [`REG_BUS] mtvec,
    input wire [`REG_BUS] mstatus,

    input wire [`REG_BUS] clint_data,      //clint

    
    output reg [11 : 0] mem_csr_addr,         ///csr o
    output reg [`REG_BUS] mem_w_csr_data,
    output reg mem_csr_ena,
    output reg [`REG_BUS] mem_except_type,
    output reg [`PC_BUS] new_pc,

    output wire [`PC_BUS] mem_pc,

    output reg [`REG_BUS] mem_w_data,
    output reg mem_w_ena,
    output reg [4 : 0] mem_w_addr,


    output wire mem_valid,  //                //AXI
    input  wire [63 : 0] mem_data,//
    output reg [`REG_BUS] mem_stor_data,
    output wire [63 : 0] mem_addr,//
    output reg [1 : 0] mem_sel,//
    output wire mem_req//

);

assign mem_valid = mem_mem_ena;
assign mem_req = mem_wr;
assign mem_addr = mem_wr ? mem_mem_waddr : mem_mem_raddr;

    reg [`REG_BUS] mem_mem_waddr;
    reg [`REG_BUS] mem_mem_raddr;
    reg mem_wr;
    reg mem_mem_ena;


    assign mem_pc = ex_pc;
    always @(*) begin
        if(reset == 1'b1) begin
            mem_w_data = `ZERO_WORD;
            mem_w_ena = 1'b0;
            mem_w_addr = `ZERO_REG_ADDR;
            mem_mem_waddr = `ZERO_WORD;
            mem_mem_raddr = `ZERO_WORD;
            mem_sel = `SIZE_B;
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
            mem_sel = `SIZE_B;
            mem_wr = ex_mem_wr;
            mem_mem_ena = (ex_mem_ena && (mem_except_type == 64'h0));////////////////////////
            case(ex_memop)
                 `R_ONE:begin
                     mem_sel = `SIZE_B;
                     mem_w_data = {{56{mem_data[7]}} , mem_data[7 : 0]}; 
                 end
                 `R_ONEu:begin   
                     mem_sel = `SIZE_B;
                     mem_w_data = {{56{1'b0}} , mem_data[7 : 0]};                   
                 end
                 `R_DOU:begin
                     mem_sel = `SIZE_H;
                     mem_w_data = {{48{mem_data[15]}} , mem_data[15 : 0]};
                 end
                 `R_DOUu:begin
                     mem_sel = `SIZE_H;
                     mem_w_data = {{48{1'b0}} , mem_data[15 : 0]};
                 end
                 `R_FOR:begin
                     mem_sel = `SIZE_W;
                     mem_w_data = {{32{mem_data[31]}} , mem_data[31 : 0]};
                 end
                 `R_FORu:begin
                     mem_sel = `SIZE_W;
                     mem_w_data = {{32{1'b0}} , mem_data[31 : 0]};
                 end
                 `R_EIG:begin
                     mem_sel = `SIZE_D;
                     mem_w_data = mem_data;
                     if((ex_mem_raddr == `msip) || (ex_mem_raddr == `mtimecmp) || (ex_mem_raddr == `mtime)) begin  ////////////
                         mem_mem_ena = 1'b0;
                         mem_w_data = clint_data;
                     end
                 end

                 //write
                 `W_ONE:begin
                     case(ex_mem_waddr[2 : 0])
                         3'b000:begin
                             mem_sel = `SIZE_B;
                             mem_stor_data = {56'b0, ex_stor_data[7 : 0]};
                         end
                         3'b001:begin
                             mem_sel = `SIZE_B;
                             mem_stor_data = {48'b0, ex_stor_data[7 : 0], 8'b0};
                         end
                         3'b010:begin
                             mem_sel = `SIZE_B;
                             mem_stor_data = {40'b0, ex_stor_data[7 : 0], 16'b0};
                         end
                         3'b011:begin
                             mem_sel = `SIZE_B;
                             mem_stor_data = {32'b0, ex_stor_data[7 : 0], 24'b0};
                         end
                         3'b100:begin
                             mem_sel = `SIZE_B;
                             mem_stor_data = {24'b0, ex_stor_data[7 : 0], 32'b0};
                         end
                         3'b101:begin
                             mem_sel = `SIZE_B;
                             mem_stor_data = {16'b0, ex_stor_data[7 : 0], 40'b0};
                         end
                         3'b110:begin
                             mem_sel = `SIZE_B;
                             mem_stor_data = {8'b0, ex_stor_data[7 : 0], 48'b0};
                         end
                         3'b111:begin
                             mem_sel = `SIZE_B;
                             mem_stor_data = {ex_stor_data[7 : 0], 56'b0};
                         end
                     endcase  
                 end
                 `W_DOU:begin
                     case(ex_mem_waddr[2 : 1])
                         2'b00:begin
                             mem_sel = `SIZE_H;
                             mem_stor_data = {48'b0, ex_stor_data[15 : 0]};
                         end
                         2'b01:begin
                             mem_sel = `SIZE_H;
                             mem_stor_data = {32'b0, ex_stor_data[15 : 0], 16'b0};
                         end
                         2'b10:begin
                             mem_sel = `SIZE_H;
                             mem_stor_data = {16'b0, ex_stor_data[15 : 0], 32'b0};
                         end
                         2'b11:begin
                             mem_sel = `SIZE_H;
                             mem_stor_data = {ex_stor_data[15 : 0], 48'b0};
                         end 
                     endcase
                 end
                 `W_FOR:begin
                     case(ex_mem_waddr[2])
                         1'b0:begin
                             mem_sel = `SIZE_W;
                             mem_stor_data = {32'b0, ex_stor_data[31 : 0]};
                         end
                         1'b1:begin
                             mem_sel = `SIZE_W;
                             mem_stor_data = {ex_stor_data[31 : 0], 32'b0};
                         end
                     endcase
                 end
                 `W_EIG:begin
                     mem_sel = `SIZE_D;
                     mem_stor_data = ex_stor_data;
                     if((ex_mem_waddr == `msip) || (ex_mem_waddr == `mtimecmp) || (ex_mem_waddr == `mtime)) begin  ////////////
                         mem_mem_ena = 1'b0;
                     end
                 end
                 default:begin
                     mem_w_data = ex_w_data;
                     mem_sel = `SIZE_B;
                     mem_wr = 1'b0;
                     mem_mem_ena = 1'b0;
                 end
            endcase
        end
    end

    always @(*) begin                    //csr
        if(reset == 1'b1) begin
            mem_csr_addr = 12'h000;
            mem_w_csr_data = `ZERO_WORD;
            mem_csr_ena = 1'b0;
        end
        else begin
            mem_csr_addr = ex_csr_addr;
            mem_w_csr_data = ex_w_csr_data;
            mem_csr_ena = ex_csr_ena;
        end
    end
        

    always @(*) begin
        if(reset == 1'b1) begin
            mem_except_type = `ZERO_WORD;
            new_pc = `ZERO_WORD;
        end
        else begin
            mem_except_type = `ZERO_WORD;
            new_pc = `ZERO_WORD;
            if(mem_pc != `ZERO_WORD) begin
                if(((mstatus[3] & mie[7] & time_inter) || (mstatus[3] & mie[7] & mip[7])) && (ex_instr != 32'h0) && ~ex_mem_wr) begin                             //time_interrupt
                    mem_except_type = 64'h1;
                    new_pc = mtvec;
                end
                else if(ex_except_type[16] == 1'b1) begin                          //syscall
                    mem_except_type = 64'h2;
                    new_pc = mtvec;
                end
                else if(ex_except_type[17] == 1'b1) begin                          //ebreak
                    mem_except_type = 64'h3;
                    new_pc = mtvec;
                end  
                else if(ex_except_type[18] == 1'b1) begin                          //mret
                    mem_except_type = 64'h4;
                    new_pc = mepc;
                end 

            end
        end
    end





endmodule