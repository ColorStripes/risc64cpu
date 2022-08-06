//2022.6.28 xuxin
`include "defines.v"


module ysyx_22040931_EX(
    input wire reset,
    input wire clock,
    //woshou
    input wire id_gi_valid,
    input wire ex_gi_ready,
    output wire to_ex_valid,
    output wire to_id_ready,

    input wire w_ena_i,
    input wire [`ysyx_22040931_REG_BUS] w_addr_i,
    //CSR
    input wire csr_ena,
    input wire [`ysyx_22040931_CSR_BUS] csr_addr, //write
    input wire [`ysyx_22040931_DATA_BUS] csr_r_data,
    //mem bypass
    input wire mem_csr_w_ena,
    input wire [`ysyx_22040931_CSR_BUS] mem_csr_w_addr, 
    input wire [`ysyx_22040931_DATA_BUS] mem_csr_w_data, 
    //liushui
    input wire [`ysyx_22040931_PC_BUS] pc_i,
    input wire [`ysyx_22040931_INST_BUS] instr,
    
    input wire [`ysyx_22040931_DATA_BUS] data1,
    input wire [`ysyx_22040931_DATA_BUS] data2,
    input wire [`ysyx_22040931_DATA_BUS] imm,

    input wire [2 : 0]     exop,
    input wire [`ysyx_22040931_ALU_BUS]  aluop,
    //mem    
    input wire [2 : 0]   memwop_i,
    input wire [2 : 0]   memrop_i,
    input wire          mem_ena_i,
    input wire           mem_wr_i,
    //except
    input wire [`ysyx_22040931_EXCEPT_BUS] except_i,
    
    //regfile
    output wire w_ena,
    output wire [`ysyx_22040931_REG_BUS] w_addr,
    output wire [`ysyx_22040931_DATA_BUS] w_data,
    //CSR    
    output wire csr_w_ena,
    output wire [`ysyx_22040931_CSR_BUS] csr_w_addr,
    output wire [`ysyx_22040931_DATA_BUS] csr_w_data,
    //mem
    output wire [2 : 0]   memwop,
    output wire [2 : 0]   memrop,
    output wire          mem_ena,
    output wire           mem_wr,    
    output wire [`ysyx_22040931_MEM_BUS] mem_addr,
    output wire [`ysyx_22040931_DATA_BUS] mem_data,
    //except
    output wire [`ysyx_22040931_EXCEPT_BUS] except,
    //liushuixian
    output wire [`ysyx_22040931_INST_BUS] instr_o,
    output wire [`ysyx_22040931_PC_BUS] pc_o

);

assign to_ex_valid = id_gi_valid & alu_valid;//id_gi_valid & alu_valid;
assign to_id_ready = ex_gi_ready & alu_ready;//ex_gi_ready & alu_ready;
assign pc_o = pc_i;
assign instr_o = instr;


    assign w_ena = w_ena_i & id_gi_valid;   //ena & valid
    assign w_addr = w_addr_i;

    assign csr_w_ena = csr_ena & id_gi_valid; //ena & valid
    assign csr_w_addr = csr_addr;
    assign csr_w_data = csr_w_ena ? result : `ysyx_22040931_ZERO_NUM;

    assign mem_data = data2;
    assign memwop = memwop_i;
    assign memrop = memrop_i;
    assign mem_ena = mem_ena_i & id_gi_valid;  //ena & valid
    assign mem_wr = mem_wr_i;

    assign except = except_i;

    wire alu_valid, alu_ready;
    wire [`ysyx_22040931_DATA_BUS] result;
    wire [`ysyx_22040931_DATA_BUS] csr_data = (csr_addr == mem_csr_w_addr) & mem_csr_w_ena & csr_ena ? mem_csr_w_data : csr_r_data;
    wire [`ysyx_22040931_DATA_BUS] alu_data2 = csr_w_ena ? csr_data : data2;
    ysyx_22040931_ALU ysyx_22040931_ALU(
    .reset(reset),
    .clock(clock),
    .id_valid(id_gi_valid),
    .ex_ready(ex_gi_ready),
    .alu_valid(alu_valid),
    .alu_ready(alu_ready),

    .num1(data1),
    .num2(alu_data2),
    .imm(imm),
    .pc(pc_i),
    .op(aluop),


    .out(result)
    );


    ysyx_22040931_MuxD #(4, 3, 64)  w_data_mux (
        w_data,
        exop,
        `ysyx_22040931_ZERO_NUM,
        {   
            `ysyx_22040931_Arith,  result, 
            `ysyx_22040931_Short,  {{32{result[31]}}, result[31 : 0]},
            `ysyx_22040931_Lui,    imm,
            `ysyx_22040931_Csr,    csr_r_data
        }
    );

    ysyx_22040931_MuxD #(2, 3, `ysyx_22040931_MEM)  mem_addr_mux (
        mem_addr,
        exop,
        `ysyx_22040931_ZERO_PC,
        {   
            `ysyx_22040931_Stort,   result[`ysyx_22040931_MEM_BUS],
            `ysyx_22040931_Load,    result[`ysyx_22040931_MEM_BUS]
        }
    );
    
endmodule
