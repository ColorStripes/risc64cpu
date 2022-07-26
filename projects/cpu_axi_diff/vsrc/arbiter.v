//2022.7.24 xuxin
`include "defines.v"


module arbiter (
    input reset,
    input clock,
    input flush,
    //woshou
    input wire pc_valid,          //zhitong
    output wire arbiter_pc_ready, //to cpu
    output reg arbiter_if_valid,
    input wire if_ready,

    input wire ex_valid,          //zhitong
    output wire arbiter_ex_ready, //to cpu
    output reg arbiter_mem_valid,
    input wire mem_ready,



    output reg [`ysyx_22040931_INST_BUS] if_data,
    input wire [`ysyx_22040931_PC_BUS] if_addr,
    input wire [1 : 0] if_size,
    input wire if_req,

    output reg [`ysyx_22040931_DATA_BUS] mem_data,
    input wire [`ysyx_22040931_DATA_BUS] mem_stor_data,
    input wire [`ysyx_22040931_PC_BUS] mem_addr,
    input wire [1 : 0] mem_size,
    input wire mem_req,



    //AXI
    input wire [3 : 0] AXI_ret_id,
    input wire [`ysyx_22040931_DATA_BUS] AXI_r_data,
    output reg [`ysyx_22040931_PC_BUS]   AXI_addr,
    output reg [`ysyx_22040931_DATA_BUS] AXI_w_data,
    output reg [1 : 0] AXI_size,
    output reg [3 : 0] AXI_id,    
    output reg AXI_vaild,
    input wire AXI_ready,
    output reg AXI_req


    
);



wire axi_fetch_ready = (AXI_ret_id == 1) ? AXI_ready : 1'b0;
wire pc_to_axi_valid = pc_valid & !arbiter_if_valid;
assign arbiter_pc_ready = arbiter_if_valid & if_ready;
always @(posedge clock) begin
    if(reset) begin
        arbiter_if_valid <= 0;
    end
    else begin
        if(axi_fetch_ready) begin           //
            arbiter_if_valid <= 1;
        end
        if(arbiter_pc_ready) begin
            arbiter_if_valid <= 0;
        end
    end
end


wire axi_mem_ready = (AXI_ret_id == 11) ? AXI_ready : 1'b0;
wire ex_to_axi_valid = ex_valid & !arbiter_mem_valid;
assign arbiter_ex_ready = arbiter_mem_valid & mem_ready;
always @(posedge clock) begin
    if(reset) begin
        arbiter_mem_valid <= 0;
    end
    else begin
        if(axi_mem_ready) begin              //
            arbiter_mem_valid <= 1;
        end
        if(arbiter_ex_ready) begin
            arbiter_mem_valid <= 0;
        end
    end
end

//READ
always @(posedge clock) begin
    if(reset) begin
        if_data <= 0;
        mem_data <= 0;
    end
    else begin
        if(axi_mem_ready) begin
            mem_data <= AXI_r_data;
        end
        if(axi_fetch_ready) begin
            if_data <= AXI_r_data[31 : 0];
        end
    end
end


assign AXI_size = ex_to_axi_valid ? mem_size : if_size;
assign AXI_addr = ex_to_axi_valid ? mem_addr : if_addr;
assign AXI_id = ex_to_axi_valid ? 4'b0011 : 4'b0001;
assign AXI_req = ex_to_axi_valid ? mem_req : if_req;
assign AXI_vaild = ex_to_axi_valid | pc_to_axi_valid;
assign AXI_w_data = mem_stor_data;






// reg flush_reg;
// always @(posedge clock) begin
//     if(reset == 1'b1) begin
//         flush_reg <= 1'b0;
//     end
//     else begin
//         if(flush) begin
//             flush_reg <= 1'b1;
//         end
//         if(~AXI_stall) begin
//             flush_reg <= 1'b0;
//         end
//     end
// end


// always @(*) begin
//     if(reset == 1'b1) begin
//         AXI_addr = ZERO_ADDR;
//         AXI_w_data = ZERO_WORD;
//         AXI_vaild = 1'b0;
//         AXI_req = 1'b0;
//         AXI_size = 2'b0;
//         AXI_id = 4'b0000;
//     end
//     else begin
//         AXI_addr = ZERO_ADDR;
//         AXI_w_data = ZERO_WORD;
//         AXI_vaild = 1'b0;
//         AXI_req = 1'b0;
//         AXI_size = 2'b0;
//         AXI_id = 4'b0000;
//         if(mem_valid) begin
//             AXI_addr = mem_addr;
//             AXI_w_data = mem_stor_data;
//             AXI_vaild = mem_valid;
//             AXI_req = mem_req;
//             AXI_size = mem_sel;
//             AXI_id = 4'b0001;
//         end
//         else if(if_valid) begin
//             AXI_addr = if_addr;
//             AXI_w_data = ZERO_WORD;
//             AXI_vaild = if_valid;
//             AXI_req = if_req;
//             AXI_size = if_size;
//             AXI_id = 4'b0011;
//         end
//     end
// end




// always @(*) begin
//     if(reset == 1'b1) begin
//         mem_data = ZERO_WORD;
//         if_data_read = ZERO_INST;
//     end
//     else begin

//             if(AXI_out_id == 4'b1) begin
//                 mem_data = AXI_r_data;
//                 if_data_read = ZERO_INST;
//             end
//             else if(AXI_out_id == 4'b11) begin
//                 if_data_read = AXI_r_data[31 : 0];
//                 mem_data = ZERO_WORD;
//             end
//             else begin
//                 mem_data = ZERO_WORD;
//                 if_data_read = ZERO_INST;
//             end
//     end
// end

// always @(*) begin
//     if(reset == 1'b1) begin
//         stall = 6'b000000;
//     end
//     else begin
//         stall = 6'b000000;
//         if(mem_valid & if_valid & ~flush_reg) begin
//             if(mem_req) begin
//                 stall = {3'b111, AXI_stall, AXI_stall, 1'b0};
//             end
//             else begin
//                 stall = {5'b11111, 1'b0};
//                 if(AXI_out_id == 4'b1) begin
//                     stall = {3'b111, AXI_stall, AXI_stall, 1'b0};
//                 end
//             end
//         end
//         else if(mem_valid & ~if_valid & ~flush_reg) begin
//             stall = {{5{AXI_stall}}, 1'b0};
//         end
//         else if(if_valid & ~flush_reg) begin
//             stall = {AXI_stall, AXI_stall, AXI_stall, 3'b0};
//         end
//         if(flush) begin
//             stall = 6'b000000;
//         end
//         else if(flush_reg) begin
//             stall = 6'b111110;
//         end
//     end
// end

endmodule
