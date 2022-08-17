//2022.8.14 xuxin
`include "defines.v"

module Decode_Rename(
    input wire reset,
    input wire clock,

    //ONE
    input wire instr_0,
    input wire [`DATA_BUS] data1_0,
    input wire [`DATA_BUS] data2_0,
    //regfile
    output wire 		        w_ena_0,
    output wire [`REG_BUS]      w_addr_0,
    output wire 		        r_ena1_0,
    output wire [`REG_BUS]      r_addr1_0,
    output wire 		        r_ena2_0,
    output wire [`REG_BUS]      r_addr2_0,
    //csr
    output wire                 csr_ena_0,
    output wire [`CSR_BUS]      csr_addr_0,
    //ex
    output wire [`DATA_BUS]     imm_0,
    output wire [`EX_BUS]       exop_0,
    output wire [`ALU_BUS]      aluop_0, 
    //mem
    output wire                 mem_ena_0,
    output wire                 mem_wr_0,   
    output wire [2 : 0]         memop_0,
    //except
    output wire [`EXCEPT_BUS]   except_0,
    //jump
    output wire                 jump_0,
    //----------------------TWO----------------------
    input wire instr_1,
    input wire [`DATA_BUS] data1_1,
    input wire [`DATA_BUS] data2_1,
    //regfile
    output wire 		        w_ena_1,
    output wire [`REG_BUS]      w_addr_1,
    output wire 		        r_ena1_1,
    output wire [`REG_BUS]      r_addr1_1,
    output wire 		        r_ena2_1,
    output wire [`REG_BUS]      r_addr2_1,
    //csr
    output wire                 csr_ena_1,
    output wire [`CSR_BUS]      csr_addr_1,
    //ex
    output wire [`DATA_BUS]     imm_1,
    output wire [`EX_BUS]       exop_1,
    output wire [`ALU_BUS]      aluop_1, 
    //mem
    output wire                 mem_ena_1,
    output wire                 mem_wr_1,   
    output wire [2 : 0]         memop_1,
    //except
    output wire [`EXCEPT_BUS]   except_1,
    //jump
    output wire                 jump_1

);



Decoder Decoder_0(
    .reset(reset),
    .clock(clock),
    .instr(instr_0),
    .data1(data1_0),
    .data2(data2_0),


    //regfile
    .w_ena(w_ena_0),
    .w_addr(w_addr_0),
    .r_ena1(r_ena1_0),
    .r_addr1(r_addr1_0),
    .r_ena2(r_ena2_0),
    .r_addr2(r_addr2_0),
    //csr
    .csr_ena(csr_ena_0),
    .csr_addr(csr_addr_0),
    //ex
    .imm(imm_0),
    .exop(exop_0),
    .aluop(aluop_0), 
    //mem
    .mem_ena(mem_ena_0),
    .mem_wr(mem_wr_0),   
    .memop(memop_0),
    //except
    .except(except_0),
    //jump
    .jump(except_0)
);

//----------------------TWO----------------------
Decoder Decoder_1(
    .reset(reset),
    .clock(clock),
    .instr(instr_1),
    .data1(data1_1),
    .data2(data2_1),


    //regfile
    .w_ena(w_ena_1),
    .w_addr(w_addr_1),
    .r_ena1(r_ena1_1),
    .r_addr1(r_addr1_1),
    .r_ena2(r_ena2_1),
    .r_addr2(r_addr2_1),
    //csr
    .csr_ena(csr_ena_1),
    .csr_addr(csr_addr_1),
    //ex
    .imm(imm_1),
    .exop(exop_1),
    .aluop(aluop_1), 
    //mem
    .mem_ena(mem_ena_1),
    .mem_wr(mem_wr_1),   
    .memop(memop_1),
    //except
    .except(except_1),
    //jump
    .jump(except_1)
);

endmodule
