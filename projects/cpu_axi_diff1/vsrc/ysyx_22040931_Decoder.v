//2022.6.23 xuxin
`include "defines.v"

module ysyx_22040931_Decoder(

    input wire [`ysyx_22040931_INST_BUS] instr,
    input wire [`ysyx_22040931_DATA_BUS] r_data1,
    input wire [`ysyx_22040931_DATA_BUS] r_data2,

	output wire 		   w_ena,
	output wire [4 : 0]   w_addr,//
    output wire 		  r_ena1,
    output wire [4 : 0]  r_addr1,//
    output wire 		  r_ena2,
    output wire [4 : 0]  r_addr2,//

    output wire mem_ena,
    output wire mem_wr,

    output wire [2 : 0]    ztype,
    output wire [2 : 0]     exop,
    output wire [`ysyx_22040931_ALU_BUS]    aluop,    
    output wire [2 : 0]   memwop,
    output wire [2 : 0]   memrop,
    output wire             jump

);

    wire itype;
    wire stype;
    wire utype;
    wire rtype;
    wire jtype;
    wire btype;

    wire [2 : 0] r_exop,  i_exop, s_exop, u_exop, j_exop, b_exop;
    wire [`ysyx_22040931_ALU_BUS] r_aluop,i_aluop,s_aluop,u_aluop,j_aluop, b_aluop;    
    wire ijump,bjump,jjump;

    assign w_addr = instr[11 : 7];
    assign r_addr1 = instr[19 : 15];
    assign r_addr2 = instr[24 : 20];

    assign mem_ena = (memrop != 3'b000) ?  1'b1 : (memwop == 3'b000) ? 1'b0 : 1'b1 ;
    assign mem_wr  = (memwop == 3'b000) ?  1'b0 : 1'b1 ;

    assign ztype[2] = itype | stype | btype | jtype;
    assign ztype[1] = itype | stype | utype | rtype;
    assign ztype[0] = itype | btype | utype;

    
    ysyx_22040931_MuxD #(6, 3, 12) opt_mux ({w_ena, r_ena1, r_ena2, exop, aluop}, 
                                        ztype, 
                             12'b0000_0000_00, 
    {

        `ysyx_22040931_Rt,    {1'b1, 1'b1, 1'b1, r_exop, r_aluop}, 
        `ysyx_22040931_It,    {1'b1, 1'b1, 1'b0, i_exop, i_aluop},
        `ysyx_22040931_St,    {1'b0, 1'b1, 1'b1, s_exop, s_aluop},
        `ysyx_22040931_Bt,    {1'b0, 1'b1, 1'b1, b_exop, b_aluop},
        `ysyx_22040931_Jt,    {1'b1, 1'b0, 1'b0, j_exop, j_aluop},
        `ysyx_22040931_Ut,    {1'b1, 1'b1, 1'b0, u_exop, u_aluop}
            
    });


    ysyx_22040931_MuxD #(3, 3, 1) jump_mux (         jump, 
                                         ztype, 
                                         1'b0, 
    {

        `ysyx_22040931_It,    ijump, 
        `ysyx_22040931_Bt,    bjump,
        `ysyx_22040931_Jt,    jjump
            
    });

    ysyx_22040931_Rtype ysyx_22040931_Rtype (instr[6 : 0], instr[14 : 12], instr[31 : 25], r_aluop, r_exop, rtype);
    ysyx_22040931_Itype ysyx_22040931_Itype (instr[6 : 0], instr[14 : 12], instr[20], instr[31 : 25], ijump, memrop, i_aluop, i_exop, itype);
    ysyx_22040931_Stype ysyx_22040931_Stype (instr[6 : 0], instr[14 : 12], memwop, s_aluop, s_exop, stype);
    ysyx_22040931_Btype ysyx_22040931_Btype (instr[6 : 0], instr[14 : 12], r_data1, r_data2, bjump, b_aluop, b_exop, btype);
    ysyx_22040931_Jtype ysyx_22040931_Jtype (instr[6 : 0], jjump, j_aluop, j_exop, jtype);
    ysyx_22040931_Utype ysyx_22040931_Utype (instr[6 : 0], u_aluop, u_exop, utype);

endmodule
