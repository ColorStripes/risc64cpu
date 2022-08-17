//2022.7.24 xuxin
`include "defines.v"


module arbiter (
    input reset,
    input clock,
    //handshake
    input wire pc_valid,          //zhitong
    output wire arbiter_pc_ready, //to cpu
    output reg arbiter_if_valid,
    input wire if_ready,

    input wire ex_valid,          //zhitong
    output wire arbiter_ex_ready, //to cpu
    output reg arbiter_mem_valid,
    input wire mem_ready,



    
    input wire [`PC_BUS] if_addr,
    input wire if_req,

    
    input wire [`CACHE_LINE] mem_stor_data,
    input wire [`PC_BUS] mem_addr,
    input wire mem_req,

    output wire [`CACHE_LINE] arbiter_data,


    //AXI
    input wire [3 : 0] AXI_ret_id,
    input wire [`CACHE_LINE] AXI_r_data,
    output reg [`PC_BUS]   AXI_addr,
    output reg [`CACHE_LINE] AXI_w_data,
    output reg [3 : 0] AXI_id,    
    output reg AXI_vaild,
    input wire AXI_ready,
    output reg AXI_req


);


//IF
wire axi_fetch_ready = (AXI_ret_id == 1) ? AXI_ready : 1'b0;
wire pc_to_axi_valid = pc_valid & !arbiter_if_valid;
assign arbiter_if_valid = axi_fetch_ready;
assign arbiter_pc_ready = arbiter_if_valid & if_ready;

//MEM
wire axi_mem_ready = (AXI_ret_id == 3) ? AXI_ready : 1'b0;
wire ex_to_axi_valid = ex_valid & !arbiter_mem_valid;
assign arbiter_mem_valid = axi_mem_ready;
assign arbiter_ex_ready = arbiter_mem_valid & mem_ready;

//AXI
assign AXI_addr = mem_control ? mem_addr : if_addr;
assign AXI_id = mem_control ? 4'b0011 : 4'b0001;
assign AXI_req = mem_control ? mem_req : if_req;
assign AXI_vaild = mem_control ? ex_to_axi_valid : pc_to_axi_valid;
assign AXI_w_data = mem_stor_data;
assign arbiter_data = AXI_r_data;


//control_arb
reg mem_control;
always @(posedge clock) begin
    if(AXI_ready | (ex_to_axi_valid & !pc_to_axi_valid)) begin   //pc is not valid but ex valid: control to ex
        mem_control <= ex_to_axi_valid;
    end
end


endmodule
