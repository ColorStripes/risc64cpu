//2022.6.23 xuxin
`include "defines.v"

module Decoder_ena(

    input wire [`INST_BUS]      instr,
    input wire [`DATA_BUS]      r_data1,
    input wire [`DATA_BUS]      r_data2,

    output wire                 csr_ena,
    output wire [`CSR_BUS]      csr_addr,

	output wire 		        w_ena,
	output wire [`REG_BUS]      w_addr,
    output wire 		        r_ena1,
    output wire [`REG_BUS]      r_addr1,
    output wire 		        r_ena2,
    output wire [`REG_BUS]      r_addr2,

    output wire                 mem_ena,
    output wire                 mem_wr,

    output wire [`EXCEPT_BUS]   except,
    output wire [2 : 0]         ztype,
    output wire [`EX_BUS]       exop,
    output wire [`ALU_BUS]      aluop,    
    output wire [2 : 0]         memwop,
    output wire [2 : 0]         memrop,
    output wire                 jump

);

    wire itype, stype, utype, rtype, jtype, btype, ctype;

    wire [`EX_BUS]   r_exop,  i_exop,  s_exop,  u_exop,  j_exop,  b_exop,  c_exop;
    wire [`ALU_BUS] r_aluop, i_aluop, s_aluop, u_aluop, j_aluop, b_aluop, c_aluop;    
    wire ijump, bjump, jjump;

    assign w_addr = instr[11 : 7];
    assign r_addr1 = instr[19 : 15];
    assign r_addr2 = instr[24 : 20];

    assign csr_ena = ctype;
    assign csr_addr = instr[31 : 20];
    
    assign mem_ena = (memrop != 3'b000) ?  1'b1 : (memwop == 3'b000) ? 1'b0 : 1'b1 ;
    assign mem_wr  = (memwop == 3'b000) ?  1'b0 : 1'b1 ;

    assign ztype[2] = itype | stype | btype | jtype;
    assign ztype[1] = itype | stype | utype | rtype;
    assign ztype[0] = itype | btype | utype | ctype;

    wire cena; //Ctype is not always read reg1;
    MuxD #(7, 3, 12) opt_mux ({w_ena, r_ena1, r_ena2, exop, aluop}, 
                                        ztype, 
                             12'b0000_0000_00, 
    {

        `Rt,    {1'b1, 1'b1, 1'b1, r_exop, r_aluop}, 
        `It,    {1'b1, 1'b1, 1'b0, i_exop, i_aluop},
        `St,    {1'b0, 1'b1, 1'b1, s_exop, s_aluop},
        `Bt,    {1'b0, 1'b1, 1'b1, b_exop, b_aluop},
        `Jt,    {1'b1, 1'b0, 1'b0, j_exop, j_aluop},
        `Ut,    {1'b1, 1'b1, 1'b0, u_exop, u_aluop},
        `Ct,    {1'b1, cena, 1'b0, c_exop, c_aluop}    
    });


    MuxD #(3, 3, 1) jump_mux (         jump, 
                                      ztype, 
                                       1'b0, 
    {

        `It,    ijump, 
        `Bt,    bjump,
        `Jt,    jjump
            
    });

    Rtype Rtype (instr[6 : 0], instr[14 : 12], instr[31 : 25], r_aluop, r_exop, rtype);
    Itype Itype (instr[6 : 0], instr[14 : 12], instr[24 : 20], instr[31 : 25], except, ijump, memrop, i_aluop, i_exop, itype);
    Stype Stype (instr[6 : 0], instr[14 : 12], memwop, s_aluop, s_exop, stype);
    Btype Btype (instr[6 : 0], instr[14 : 12], r_data1, r_data2, bjump, b_aluop, b_exop, btype);
    Jtype Jtype (instr[6 : 0], jjump, j_aluop, j_exop, jtype);
    Utype Utype (instr[6 : 0], u_aluop, u_exop, utype);
    Ctype Ctype (instr[6 : 0], instr[14 : 12], c_aluop, c_exop, cena, ctype);


endmodule
