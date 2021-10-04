//2021.10.3
//xu xin
`include "defines.v"

module arbitrate (
    input clk,
    input rst,

    output wire if_ready,
    output wire [63 : 0] if_data_read,

    input wire if_valid,
    input wire [63 : 0] IF_pc,
    input wire [1 : 0] if_size,
    input wire [1 : 0] if_req,

    output wire mem_ready,
    output wire [63 : 0] mem_data,
    
    input wire [`REG_BUS] mem_stor_data,
    input wire mem_valid,
    input wire [63 : 0] mem_addr,
    input wire [1 : 0] mem_sel,
    input wire [1 : 0] mem_req,


    output reg [63 : 0] AXI_addr,
    output reg [`REG_BUS] AXI_w_data,
    output reg AXI_vaild,
    output reg [1 : 0] AXI_req,
    output reg [1 : 0] AXI_size,
    output reg [63:0] AXI_id,

    input wire AXI_ready,
    input wire [63:0] AXI_out_id,
    input wire [`REG_BUS] AXI_r_data
    
);


always @(*) begin
    AXI_addr = `ZERO_WORD;
    AXI_w_data = `ZERO_WORD;
    AXI_vaild = 1'b0;
    AXI_req = 2'b0;
    AXI_size = 2'b0;
    AXI_id = {{63{1'b0}}, 1'b0};
    if(mem_valid) begin
        AXI_addr = mem_addr;
        AXI_w_data = mem_stor_data;
        AXI_vaild = mem_valid;
        AXI_req = mem_req;
        AXI_size = mem_sel;
        AXI_id = {{63{1'b0}}, 1'b1};
    end
    else if(if_valid) begin
        AXI_addr = IF_pc;
        AXI_w_data = `ZERO_WORD;
        AXI_vaild = if_valid;
        AXI_req = if_req;
        AXI_size = if_size;
        AXI_id = {{62{1'b0}}, 2'b11};
    end
end







assign if_ready = (AXI_out_id == 64'b11) ? AXI_ready : 1'b0;


    
endmodule