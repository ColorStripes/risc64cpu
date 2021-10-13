
//2021.10.3
//xu xin
`include "defines.v"

module ysyx_210457_arbiter (
    input clock,
    input reset,
    input flush,

    output reg [31 : 0] if_data_read,
    input wire if_valid,
    input wire [`ADDR_BUS] if_addr,
    input wire [1 : 0] if_size,
    input wire if_req,

    output reg [63 : 0] mem_data,
    
    input wire [`REG_BUS] mem_stor_data,
    input wire mem_valid,
    input wire [`ADDR_BUS] mem_addr,
    input wire [1 : 0] mem_sel,
    input wire mem_req,


    output reg [`ADDR_BUS] AXI_addr,
    output reg [`REG_BUS] AXI_w_data,
    output reg AXI_vaild,
    output reg AXI_req,
    output reg [1 : 0] AXI_size,
    output reg [3:0] AXI_id,

    input wire [3:0] AXI_out_id,
    input wire [`REG_BUS] AXI_r_data,
    input wire AXI_stall,

    output reg [5 : 0] stall
    
);

reg flush_reg;
always @(posedge clock) begin
    if(reset == 1'b1) begin
        flush_reg <= 1'b0;
    end
    else begin
        if(flush) begin
            flush_reg <= 1'b1;
        end
        if(~AXI_stall) begin
            flush_reg <= 1'b0;
        end
    end
end


always @(*) begin
    if(reset == 1'b1) begin
        AXI_addr = `ZERO_ADDR;
        AXI_w_data = `ZERO_WORD;
        AXI_vaild = 1'b0;
        AXI_req = 1'b0;
        AXI_size = 2'b0;
        AXI_id = 4'b0000;
    end
    else begin
        AXI_addr = `ZERO_ADDR;
        AXI_w_data = `ZERO_WORD;
        AXI_vaild = 1'b0;
        AXI_req = 1'b0;
        AXI_size = 2'b0;
        AXI_id = 4'b0000;
        if(mem_valid) begin
            AXI_addr = mem_addr;
            AXI_w_data = mem_stor_data;
            AXI_vaild = mem_valid;
            AXI_req = mem_req;
            AXI_size = mem_sel;
            AXI_id = 4'b0001;
        end
        else if(if_valid) begin
            AXI_addr = if_addr;
            AXI_w_data = `ZERO_WORD;
            AXI_vaild = if_valid;
            AXI_req = if_req;
            AXI_size = if_size;
            AXI_id = 4'b0011;
        end
    end
end




always @(*) begin
    if(reset == 1'b1) begin
        mem_data = `ZERO_WORD;
        if_data_read = `ZERO_INST;
    end
    else begin

            if(AXI_out_id == 4'b1) begin
                mem_data = AXI_r_data;
                if_data_read = `ZERO_INST;
            end
            else if(AXI_out_id == 4'b11) begin
                if_data_read = AXI_r_data[31 : 0];
                mem_data = `ZERO_WORD;
            end
            else begin
                mem_data = `ZERO_WORD;
                if_data_read = `ZERO_INST;
            end
    end
end

always @(*) begin
    if(reset == 1'b1) begin
        stall = 6'b000000;
    end
    else begin
        stall = 6'b000000;
        if(mem_valid & if_valid & ~flush_reg) begin
            if(mem_req) begin
                stall = {3'b111, AXI_stall, AXI_stall, 1'b0};
            end
            else begin
                stall = {5'b11111, 1'b0};
                if(AXI_out_id == 4'b1) begin
                    stall = {3'b111, AXI_stall, AXI_stall, 1'b0};
                end
            end
        end
        else if(mem_valid & ~if_valid & ~flush_reg) begin
            stall = {{5{AXI_stall}}, 1'b0};
        end
        else if(if_valid & ~flush_reg) begin
            stall = {AXI_stall, AXI_stall, AXI_stall, 3'b0};
        end
        if(flush) begin
            stall = 6'b000000;
        end
        else if(flush_reg) begin
            stall = 6'b111110;
        end
    end
end





endmodule
