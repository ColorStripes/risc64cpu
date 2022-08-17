//2022.6.28 xuxin
`include "defines.v"


module EX(
    input wire reset,
    input wire clock,
    input wire flush,
    //handshake
    input wire id_gi_valid,
    input wire ex_gi_ready,
    output wire to_ex_valid,
    output wire to_id_ready,

    input wire w_ena_i,
    input wire [`REG_BUS] w_addr_i,
    //CSR
    input wire csr_ena,
    input wire [`CSR_BUS] csr_addr, //write
    input wire [`DATA_BUS] csr_r_data,
    //mem bypass
    input wire mem_csr_w_ena,
    input wire [`CSR_BUS] mem_csr_w_addr, 
    input wire [`DATA_BUS] mem_csr_w_data, 
    //liushui
    input wire [`PC_BUS] pc_i,
    input wire [`INST_BUS] instr,
    
    input wire [`DATA_BUS] data1,
    input wire [`DATA_BUS] data2,
    input wire [`DATA_BUS] imm,

    input wire [2 : 0]     exop,
    input wire [`ALU_BUS]  aluop,
    //mem    
    input wire [2 : 0]   memwop_i,
    input wire [2 : 0]   memrop_i,
    input wire          mem_ena_i,
    input wire           mem_wr_i,
    //except
    input wire [`EXCEPT_BUS] except_i,
    
    //regfile
    output wire w_ena,
    output wire [`REG_BUS] w_addr,
    output wire [`DATA_BUS] w_data,
    //CSR    
    output wire csr_w_ena,
    output wire [`CSR_BUS] csr_w_addr,
    output wire [`DATA_BUS] csr_w_data,
    //mem
    output wire [2 : 0]   memwop,
    output wire [2 : 0]   memrop,
    output wire          mem_ena,
    output wire           mem_wr,    
    output wire [`MEM_BUS] mem_addr,
    output wire [`DATA_BUS] mem_data,
    //except
    output wire [`EXCEPT_BUS] except,
    //liushuixian
    output wire [`INST_BUS] instr_o,
    output wire [`PC_BUS] pc_o

);

assign to_ex_valid = id_gi_valid & alu_valid;//id_gi_valid & alu_valid;
assign to_id_ready = ex_gi_ready & alu_ready;//ex_gi_ready & alu_ready;
assign pc_o = pc_i;
assign instr_o = instr;


    assign w_ena = w_ena_i & id_gi_valid;   //ena & valid
    assign w_addr = w_addr_i;

    assign csr_w_ena = csr_ena & id_gi_valid; //ena & valid
    assign csr_w_addr = csr_addr;
    assign csr_w_data = csr_w_ena ? result : `ZERO_NUM;

    assign mem_data = data2;
    assign memwop = memwop_i;
    assign memrop = memrop_i;
    assign mem_ena = mem_ena_i & id_gi_valid;  //ena & valid
    assign mem_wr = mem_wr_i;

    assign except = except_i;

    wire alu_valid, alu_ready;
    wire [`DATA_BUS] result;
    wire [`DATA_BUS] csr_data = (csr_addr == mem_csr_w_addr) & mem_csr_w_ena & csr_ena ? mem_csr_w_data : csr_r_data;
    wire [`DATA_BUS] alu_data2 = csr_w_ena ? csr_data : data2;
    ALU ALU(
    .reset(reset),
    .clock(clock),
    .flush(flush),
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


    MuxD #(4, 3, 64)  w_data_mux (
        w_data,
        exop,
        `ZERO_NUM,
        {   
            `Arith,  result, 
            `Short,  {{32{result[31]}}, result[31 : 0]},
            `Lui,    imm,
            `Csr,    csr_r_data
        }
    );

    MuxD #(2, 3, `MEM)  mem_addr_mux (
        mem_addr,
        exop,
        `ZERO_PC,
        {   
            `Stort,   result[`MEM_BUS],
            `Load,    result[`MEM_BUS]
        }
    );
    
endmodule
