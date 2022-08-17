//2022.8.14 xuxin
`include "defines.v"

module Decoder(
    input wire reset,
    input wire clock,
    input wire [`INST_BUS] instr,
    input wire [`DATA_BUS] data1,
    input wire [`DATA_BUS] data2,



    //regfile
    output wire 		        w_ena,
    output wire [`REG_BUS]      w_addr,
    output wire 		        r_ena1,
    output wire [`REG_BUS]      r_addr1,
    output wire 		        r_ena2,
    output wire [`REG_BUS]      r_addr2,
    //csr
    output wire                 csr_ena,
    output wire [`CSR_BUS]      csr_addr,
    //ex
    output wire [`DATA_BUS]     imm,
    output wire [`EX_BUS]       exop,
    output wire [`ALU_BUS]      aluop, 
    //mem
    output wire                 mem_ena,
    output wire                 mem_wr,   
    output wire [2 : 0]         memop,
    //except
    output wire [`EXCEPT_BUS]   except,
    //jump
    output wire                 jump

);


    //---------------------------------branch----------------------------------------
    wire [`PC_BUS] ibranch,bbranch,jbranch;
    assign ibranch = data1 + imm;
    assign bbranch = pc_i + imm;
    assign jbranch = bbranch;

    reg [`PC_BUS] branch_reg;
    always @(posedge clock) begin
        if(reset) begin
            branch_reg <= `ZERO_PC;
        end
        else if(in_valid) begin
            branch_reg <= branch_now;
        end
    end
    assign branch = in_valid ? branch_now : branch_reg;    //AXI

    wire [`PC_BUS] branch_now;
    MuxD #(3, 3, 64)  branch_mux (
        branch_now,
        ztype,
        `ZERO_PC,
        {
           `It, ibranch,
           `Bt, bbranch,
           `Jt, jbranch
        }
    );


    //------------------------------ena----------------------------
    wire [2 : 0]      ztype;
    wire [2 : 0]      memwop, memrop;
    assign memop = mem_wr ? memwop : memrop;

    Decoder_ena Decoder_ena(
    .instr(instr),
    .r_data1(data1),
    .r_data2(data2),

    .csr_ena(csr_ena),
    .csr_addr(csr_addr),
	.w_ena(w_ena),
	.w_addr(w_addr),
    .r_ena1(r_ena1),
    .r_addr1(r_addr1),
    .r_ena2(r_ena2),
    .r_addr2(r_addr2),
    .mem_ena(mem_ena),
    .mem_wr(mem_wr),

    .except(except),
    .ztype(ztype),
    .exop(exop),
    .aluop(aluop),    
    .memwop(memwop),
    .memrop(memrop),
    .jump(jump)

    );


    //-----------------------IMM-------------------------------------
    IMM IMM(
    .instr(instr[31 : 7]),
    .opt(ztype),

    .imm(imm)
    );

endmodule
