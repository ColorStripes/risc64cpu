//2022.6.23 xuxin
`include "defines.v"

module ysyx_22040931_MEM(
    input wire reset,
    input wire clock,

    //woshou
    input wire ex_gi_valid,
    input wire mem_gi_ready,
    output wire to_mem_valid,
    output wire to_ex_ready,
    //arb woshou
    input wire arbiter_mem_valid,
    input wire arbiter_ex_ready,

    input wire w_ena_i,
    input wire [`ysyx_22040931_REG_BUS] w_addr_i,
    input wire [`ysyx_22040931_DATA_BUS] w_data_i,
    //csr
    input wire csr_w_ena_i,
    input wire [`ysyx_22040931_CSR_BUS] csr_w_addr_i,
    input wire [`ysyx_22040931_DATA_BUS] csr_w_data_i,
    //mem
    input wire [2 : 0]   memwop,
    input wire [2 : 0]   memrop,
    input wire           mem_ena_i,
    input wire           mem_wr_i,
    input wire [`ysyx_22040931_MEM_BUS] mem_addr_i,
    input wire [`ysyx_22040931_DATA_BUS] mem_stor_data_i,
    input wire [`ysyx_22040931_DATA_BUS] mem_return_data,   //
    //except
    input wire [`ysyx_22040931_EXCEPT_BUS] except_i,
    input wire now_except,
    //inter    
    input wire mie,
    input wire mip,
    input wire mstatus,

    
    //liushuixian
    input wire [`ysyx_22040931_PC_BUS] pc_i,
    input wire [`ysyx_22040931_INST_BUS] instr,


    output wire w_ena,
    output wire [`ysyx_22040931_REG_BUS] w_addr,
    output wire [`ysyx_22040931_DATA_BUS] w_data,
    //csr
    output wire csr_w_ena,
    output wire [`ysyx_22040931_CSR_BUS] csr_w_addr,
    output wire [`ysyx_22040931_DATA_BUS] csr_w_data,
    //mem
    output wire [1 : 0]       memop,//
    output wire             mem_ena,
    output wire              mem_wr,
    output wire [`ysyx_22040931_MEM_BUS] mem_addr,
    output wire [`ysyx_22040931_DATA_BUS] mem_stor_data,//
    //except
    output wire [`ysyx_22040931_EXCEPT_BUS] except,
    //liushuixian
    output wire clint_ena_o,
    output wire [`ysyx_22040931_INST_BUS] instr_o,
    output wire [`ysyx_22040931_PC_BUS] pc_o

);

assign to_mem_valid = mem_ena ? (ex_gi_valid & arbiter_mem_valid) : ex_gi_valid;
assign to_ex_ready  = mem_ena ? (mem_gi_ready & arbiter_ex_ready) : mem_gi_ready;
//liushui
assign pc_o = pc_i;
assign instr_o = instr;
assign clint_ena_o = clint_ena;

    assign w_ena = w_ena_i & ex_gi_valid & !now_clint;  //ena & valid
    assign w_addr = w_addr_i;
    
    assign csr_w_ena = csr_w_ena_i & ex_gi_valid & !now_clint;
    assign csr_w_addr = csr_w_addr_i;
    assign csr_w_data = csr_w_data_i;

    wire ena = mem_ena_i & !now_except & ex_gi_valid & !now_clint;
    assign mem_ena = ena & !clint_ena ; //ena & valid
    assign mem_wr = mem_wr_i;
    assign mem_addr = mem_addr_i;

    wire [`ysyx_22040931_DATA_BUS] mem_r_data;
    assign w_data = (mem_ena & ~mem_wr) | clint_ena ? mem_r_data : w_data_i;

    wire [2 : 0] memwrop;
    assign memwrop = mem_wr_i ? memwop : memrop;
    ysyx_22040931_MuxD #(7, 3, 2)  memop_mux (
        memop,
        memwrop,
        `ysyx_22040931_SIZE_B,
        {   
            `ysyx_22040931_R_ONE,  `ysyx_22040931_SIZE_B, 
            `ysyx_22040931_R_ONEU, `ysyx_22040931_SIZE_B,
            `ysyx_22040931_R_DOU,  `ysyx_22040931_SIZE_H,
            `ysyx_22040931_R_DOUU, `ysyx_22040931_SIZE_H,
            `ysyx_22040931_R_FOR,  `ysyx_22040931_SIZE_W,
            `ysyx_22040931_R_FORU, `ysyx_22040931_SIZE_W,
            `ysyx_22040931_R_EIG,  `ysyx_22040931_SIZE_D
        }
    );

    wire [`ysyx_22040931_DATA_BUS] mem_data = clint_ena ? clint_data : mem_return_data; 
    ysyx_22040931_MuxD #(7, 3, 64)  mem_r_data_mux (
        mem_r_data,
        memrop,
        `ysyx_22040931_ZERO_NUM,
        {   
            `ysyx_22040931_R_ONE,    {{56{mem_data[7]}} , mem_data[7 : 0]}, 
            `ysyx_22040931_R_ONEU,   {{56{1'b0}} , mem_data[7 : 0]}, 
            `ysyx_22040931_R_DOU,    {{48{mem_data[15]}} , mem_data[15 : 0]}, 
            `ysyx_22040931_R_DOUU,   {{48{1'b0}} , mem_data[15 : 0]},
            `ysyx_22040931_R_FOR,    {{32{mem_data[31]}} , mem_data[31 : 0]},
            `ysyx_22040931_R_FORU,   {{32{1'b0}} , mem_data[31 : 0]},
            `ysyx_22040931_R_EIG,    mem_data
        }
    );


    wire [`ysyx_22040931_DATA_BUS] stor_data_one;
    wire [`ysyx_22040931_DATA_BUS] stor_data_two;
    wire [`ysyx_22040931_DATA_BUS] stor_data_for;
    ysyx_22040931_MuxD #(4, 3, 64)  mem_stor_data_mux (
        mem_stor_data,
        memwop,
        `ysyx_22040931_ZERO_NUM,
        {   
            `ysyx_22040931_W_ONE,   stor_data_one, 
            `ysyx_22040931_W_DOU,   stor_data_two, 
            `ysyx_22040931_W_FOR,   stor_data_for, 
            `ysyx_22040931_W_EIG,   mem_stor_data_i
        }
    );

    ysyx_22040931_MuxD #(8, 6, 64)  mem_stor_data1_mux (
        stor_data_one,
        {memwop, mem_addr[2 : 0]},
        `ysyx_22040931_ZERO_NUM,
        {   
            {`ysyx_22040931_W_ONE, 3'b000},  {56'b0, mem_stor_data_i[7 : 0]}, 
            {`ysyx_22040931_W_ONE, 3'b001},  {48'b0, mem_stor_data_i[7 : 0], 8'b0},
            {`ysyx_22040931_W_ONE, 3'b010},  {40'b0, mem_stor_data_i[7 : 0], 16'b0},
            {`ysyx_22040931_W_ONE, 3'b011},  {32'b0, mem_stor_data_i[7 : 0], 24'b0},
            {`ysyx_22040931_W_ONE, 3'b100},  {24'b0, mem_stor_data_i[7 : 0], 32'b0},
            {`ysyx_22040931_W_ONE, 3'b101},  {16'b0, mem_stor_data_i[7 : 0], 40'b0},
            {`ysyx_22040931_W_ONE, 3'b110},  {8'b0, mem_stor_data_i[7 : 0], 48'b0},
            {`ysyx_22040931_W_ONE, 3'b111},  {mem_stor_data_i[7 : 0], 56'b0}
        }
    );

    ysyx_22040931_MuxD #(4, 5, 64)  mem_stor_data2_mux (
        stor_data_two,
        {memwop, mem_addr[2 : 1]},
        `ysyx_22040931_ZERO_NUM,
        {   
            {`ysyx_22040931_W_DOU, 2'b00},  {48'b0, mem_stor_data_i[15 : 0]}, 
            {`ysyx_22040931_W_DOU, 2'b01},  {32'b0, mem_stor_data_i[15 : 0], 16'b0},
            {`ysyx_22040931_W_DOU, 2'b10},  {16'b0, mem_stor_data_i[15 : 0], 32'b0},
            {`ysyx_22040931_W_DOU, 2'b11},  {mem_stor_data_i[15 : 0], 48'b0}
        }
    );


    ysyx_22040931_MuxD #(2, 4, 64)  mem_stor_data3_mux (
        stor_data_for,
        {memwop, mem_addr[2]},
        `ysyx_22040931_ZERO_NUM,
        {   
            {`ysyx_22040931_W_FOR, 1'b0},  {32'b0, mem_stor_data_i[31 : 0]}, 
            {`ysyx_22040931_W_FOR, 1'b1},  {mem_stor_data_i[31 : 0], 32'b0}
        }
    );


wire [`ysyx_22040931_DATA_BUS] clint_data;
wire clint_ena = (mem_addr_i == 64'h2000000) | (mem_addr_i == 64'h2004000) | (mem_addr_i == 64'h200bff8) ? ena : 1'b0;
CLINT  CLINT(
    .reset(reset),
    .clock(clock),
    .mem_wr(mem_wr_i),
    .clint_ena(clint_ena),
    .mem_addr(mem_addr_i),
    .stor_data(mem_stor_data_i),


    .time_inter(clint),
    .clint_data(clint_data)

);

wire clint;
wire now_clint = (mie & mstatus) & (clint | mip) ? old_handshake & !is_nop : 1'b0;
assign except = now_clint ? `ysyx_22040931_INTER : except_i;
                                              //& to_mem_valid

reg old_handshake;                    //next load/store can clint
always @(posedge clock) begin
    if(reset) begin
        old_handshake <= 0;
    end
    else begin
        old_handshake <= to_mem_valid & to_ex_ready;
    end
end

wire is_nop = (instr == 32'h0) ? 1'b1 : 1'b0;

endmodule
