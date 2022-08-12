//2022.6.24 xuxin
`include "defines.v"

module ysyx_22040931_ID(
    input wire reset,
    input wire clock,
    //regfile
    input wire w_ena_i,
    input wire [`ysyx_22040931_REG_BUS] w_addr_i,
    input wire [`ysyx_22040931_DATA_BUS] w_data_i,
    //liushuixian
    input wire [`ysyx_22040931_PC_BUS] pc_i,
    input wire [`ysyx_22040931_INST_BUS] instr,
    //bypass
    input wire ex_w_ena,
    input wire [`ysyx_22040931_REG_BUS] ex_w_addr,
    input wire [`ysyx_22040931_DATA_BUS] ex_w_data,

    input wire mem_w_ena,
    input wire [`ysyx_22040931_REG_BUS] mem_w_addr,
    input wire [`ysyx_22040931_DATA_BUS] mem_w_data,
    //load hazard
    input wire ex_mem_ena,
    input wire ex_mem_wr,
    //pre
    input wire pre_jump,
    input wire [`ysyx_22040931_PC_BUS] pre_branch,


    //load hazard 
    //output wire nop,
    output wire load_stall,
    //liushuixian
    output wire [`ysyx_22040931_PC_BUS] pc_o,
    output wire [`ysyx_22040931_INST_BUS] instr_o,   
    //branch
    input wire if_valid,
    output wire [`ysyx_22040931_PC_BUS] branch,      //////////////////////////////////
    output wire mux_pc,
    output wire [1 : 0] jumptype,
    output wire error_pre,
    //regfile
    output wire 		   w_ena,
    output wire [`ysyx_22040931_REG_BUS] w_addr,
    output wire [`ysyx_22040931_DATA_BUS] data1,
    output wire [`ysyx_22040931_DATA_BUS] data2,
    //CSR
    output wire csr_ena,
    output wire [`ysyx_22040931_CSR_BUS] csr_addr,

    //ex
    output wire mem_ena,
    output wire mem_wr,
    output wire [`ysyx_22040931_DATA_BUS] imm,
    output wire [2 : 0]     exop,
    output wire [`ysyx_22040931_ALU_BUS]  aluop,    
    output wire [2 : 0]   memwop,
    output wire [2 : 0]   memrop,

    //except
    output wire [`ysyx_22040931_EXCEPT_BUS] except,

    //difftest
    output wire [`ysyx_22040931_DATA_BUS] regs[0 : 31]

);

assign pc_o = pc_i;
assign instr_o = instr;

assign jumptype = (ztype == `ysyx_22040931_Bt) ? 2'b01 : (ztype == `ysyx_22040931_Jt) ? 2'b10 : ((ztype == `ysyx_22040931_It) && mux_pc) ? 2'b11 : 2'b00;
assign error_pre = (pre_jump != mux_pc) ? 1'b1 : (pre_branch != branch) ? mux_pc : 1'b0;

// //assign nop = mux_pc;
// reg [31 : 0] r_count;
// reg [31 : 0] count;
// always @(posedge clock) begin
//     if(reset == 1'b1) begin
//         count <= 0;
//         r_count <= 0;
//     end
//     else begin
//         if(~error_pre && (jumptype != 0)) begin
//             r_count <= r_count + 1;
//         end
//         if(jumptype != 0) begin
//             count <= count + 1;
//         end
//     end
// end
//     initial begin
//         $monitor("%d/%d 正确率:%d  \n",r_count, count,  r_count*100 / count );
//     end

    wire [2 : 0]     ztype;
    wire 		    r_ena1;
    wire [4 : 0]   r_addr1;
    wire [`ysyx_22040931_DATA_BUS] r_data1;
    wire 		    r_ena2;
    wire [4 : 0]   r_addr2;
    wire [`ysyx_22040931_DATA_BUS] r_data2;

    wire [`ysyx_22040931_PC_BUS] ibranch;
    wire [`ysyx_22040931_PC_BUS] bbranch;
    wire [`ysyx_22040931_PC_BUS] jbranch;
    assign ibranch = data1 + imm;
    assign bbranch = pc_i + imm;
    assign jbranch = bbranch;

    reg [`ysyx_22040931_PC_BUS] branch_reg;
    always @(posedge clock) begin
        if(reset) begin
            branch_reg <= `ysyx_22040931_ZERO_PC;
        end
        else if(if_valid) begin
            branch_reg <= branch_now;
        end
    end
    assign branch = if_valid ? branch_now : branch_reg;    //AXI

    wire [`ysyx_22040931_PC_BUS] branch_now;
    ysyx_22040931_MuxD #(3, 3, 64)  branch_mux (
        branch_now,
        ztype,
        `ysyx_22040931_ZERO_PC,
        {
           `ysyx_22040931_It, ibranch,
           `ysyx_22040931_Bt, bbranch,
           `ysyx_22040931_Jt, jbranch
        }
    );

    ysyx_22040931_Decoder ysyx_22040931_Decoder(

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
    .jump(mux_pc)

    );

    ysyx_22040931_IMM ysyx_22040931_IMM(
    .instr(instr[31 : 7]),
    .opt(ztype),

    .imm(imm)
    );


    ysyx_22040931_Regfile ysyx_22040931_Regfile(
	.reset(reset),
    .clock(clock),
	.w_ena(w_ena_i),
	.w_addr(w_addr_i),
	.w_data(w_data_i),
	
	.r_ena1(r_ena1),
	.r_addr1(r_addr1),
	.r_data1(r_data1),     //OUT1
	
	.r_ena2(r_ena2),
	.r_addr2(r_addr2),
	.r_data2(r_data2),     //OUT2

    //difftest
    .regs_o(regs)

    );
    




    //load hazard
    assign load_stall = (ex_w_addr == r_addr1) ? ((ex_w_addr == 5'b00000) ? 1'b0 : (ex_w_ena & !ex_mem_wr & ex_mem_ena)) : 
                        (ex_w_addr == r_addr2) ? ((ex_w_addr == 5'b00000) ? 1'b0 : (ex_w_ena & !ex_mem_wr & ex_mem_ena)) : 1'b0;

    //read bypass
    wire need_ex1, need_ex2, need_mem1, need_mem2;
    assign need_ex1 = (ex_w_addr == r_addr1) ? ((ex_w_addr == 5'b00000) ? 1'b0 : ex_w_ena & r_ena1) : 1'b0;
    assign need_ex2 = (ex_w_addr == r_addr2) ? ((ex_w_addr == 5'b00000) ? 1'b0 : ex_w_ena & r_ena2) : 1'b0;
    assign need_mem1 = (mem_w_addr == r_addr1) ? ((mem_w_addr == 5'b00000) ? 1'b0 : mem_w_ena & r_ena1) : 1'b0;
    assign need_mem2 = (mem_w_addr == r_addr2) ? ((mem_w_addr == 5'b00000) ? 1'b0 : mem_w_ena & r_ena2) : 1'b0;

    ysyx_22040931_MuxD #(5, 4, 64) reg_data1 (data1, {r_ena1, ~r_ena1, need_ex1, need_mem1}, `ysyx_22040931_ZERO_NUM, {
        4'b1000,  r_data1,
        4'b0100,  {59'b0, r_addr1},     ////
        4'b1010,  ex_w_data,
        4'b1011,  ex_w_data,
        4'b1001,  mem_w_data
    });

    ysyx_22040931_MuxD #(5, 4, 64) reg_data2 (data2, {r_ena2, ~r_ena2, need_ex2, need_mem2}, `ysyx_22040931_ZERO_NUM, {
        4'b1000,  r_data2,
        4'b0100,  imm,
        4'b1010,  ex_w_data,
        4'b1011,  ex_w_data,
        4'b1001,  mem_w_data
    });




endmodule
