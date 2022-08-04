//2022.6.28 xuxin
`include "defines.v"

module cputop(
    input wire reset,
    input wire clock,
    //if
    input wire [`ysyx_22040931_INST_BUS] instr,
    //mem
    input wire [`ysyx_22040931_DATA_BUS] momory_data,
    input wire hhhh,
    

    //if
    output wire [`ysyx_22040931_PC_BUS] pc,
    //woshou
    input wire arbiter_pc_ready,
    output wire fetch_enb,
    input wire arbiter_if_valid,
    output wire if_ready,
    
    //mem
    output wire [1 : 0]       memop,
    output wire              mem_wr,
    output wire [`ysyx_22040931_MEM_BUS] mem_addr,
    output wire [`ysyx_22040931_DATA_BUS] mem_stor_data,
    //woshou
    input wire arbiter_ex_ready,
    output wire mem_ena,  //ena & valid
    input wire arbiter_mem_valid,
    output wire mem_ready

);




wire mux_pc;
wire [`ysyx_22040931_PC_BUS] branch;

ysyx_22040931_IF ysyx_22040931_IF(
    .reset(reset),
    .clock(clock),
    .flush(),
    .stall(),
    //wo shou
    .if_ready(arbiter_pc_ready),
    .pc_valid(fetch_enb),
    .pc_ready(),

    .error_pre(error_pre),
    .id_jump(mux_pc),
    .id_jumptype(jumptype),
    .id_pc(id_pc),
    .id_branch(branch),
    
    .pre_jump(pre_jump),
    .pre_branch(pre_branch),
    .if_pc(pc)
);

//forecase
wire pre_jump;
wire [`ysyx_22040931_PC_BUS] pre_branch;

//pc valid <-> ready
wire pc_ready;
//wire pc_valid;

//if valid <-> ready
wire if_valid;
////wire if_ready;


if_id if_id(
    .reset(reset),
    .clock(clock),
    .flush(),
    .stall(load_stall),         ////////////////
    .nop(error_pre),            ////////////////
    //wo shou
    .pc_valid(arbiter_if_valid),
    .id_ready(id_ready),
    .if_ready(if_ready),
    .if_valid(if_valid),

    .IF_pre_jump(pre_jump),
    .IF_pre_branch(pre_branch),
    .IF_pc(pc),
    .IF_instr(instr),

    .ID_pre_jump(ID_pre_jump),
    .ID_pre_branch(ID_pre_branch),
    .ID_pc(ID_pc),
    .ID_instr(ID_instr)
);

wire ID_pre_jump;
wire [`ysyx_22040931_PC_BUS] ID_pre_branch;
wire [`ysyx_22040931_PC_BUS]   ID_pc;
wire [`ysyx_22040931_INST_BUS] ID_instr;

ysyx_22040931_ID ysyx_22040931_ID(

    //regfile
    .reset(reset),
    .clock(clock),
    .w_ena_i(wb_w_ena),
    .w_addr_i(wb_w_addr),
    .w_data_i(wb_w_data),
    //liushuixian
    .pc_i(ID_pc),
    .instr(ID_instr),
    //bypass
    .ex_w_ena(ex_w_ena),
    .ex_w_addr(ex_w_addr),
    .ex_w_data(ex_w_data),
    .mem_w_ena(mem_w_ena),
    .mem_w_addr(mem_w_addr),
    .mem_w_data(mem_w_data),
    //load hazard
    .ex_mem_ena(EX_mem_ena),
    .ex_mem_wr(EX_mem_wr),
    //pre
    .pre_jump(ID_pre_jump),
    .pre_branch(ID_pre_branch),


    //load hazard and mux_pc
    //.nop(nop),
    .load_stall(load_stall),
    //liushuixian
    .instr_o(id_instr),
    .pc_o(id_pc),    
    //branch
    .if_valid(if_valid),
    .branch(branch),
    .mux_pc(mux_pc),
    .jumptype(jumptype),
    .error_pre(error_pre),
    //regfile
    .w_ena(id_w_ena),
    .w_addr(id_w_addr),
    .data1(id_data1),
    .data2(id_data2),
    //ex
    .mem_ena(id_mem_ena),
    .mem_wr(id_mem_wr),
    .imm(id_imm),
    .exop(id_exop),
    .aluop(id_aluop),    
    .memwop(id_memwop),
    .memrop(id_memrop),

    .regs(regs)

);
//difftest
wire [`ysyx_22040931_DATA_BUS] regs[0 : 31];


//load hazard 
wire nop;
wire load_stall;
//liushuixian
wire [`ysyx_22040931_PC_BUS] id_pc;
wire [`ysyx_22040931_INST_BUS] id_instr;   
//branch
wire [1 : 0] jumptype;
wire [`ysyx_22040931_PC_BUS] branch;
wire mux_pc;
wire error_pre;
//regfile
wire 		   id_w_ena;
wire [`ysyx_22040931_REG_BUS] id_w_addr;
wire [`ysyx_22040931_DATA_BUS] id_data1;
wire [`ysyx_22040931_DATA_BUS] id_data2;
//ex
wire id_mem_ena;
wire id_mem_wr;
wire [`ysyx_22040931_DATA_BUS] id_imm;
wire [2 : 0]     id_exop;
wire [`ysyx_22040931_ALU_BUS]    id_aluop;    
wire [2 : 0]   id_memwop;
wire [2 : 0]   id_memrop;

//id valid <-> ready
wire id_ready;
wire id_valid;

id_ex id_ex(
    .reset(reset),
    .clock(clock),
    .flush(),     //记得flush与各级使能相与 p71
    .stall(),
    .nop(load_stall),
    //wo shou
    .if_valid(if_valid),
    .ex_ready(to_id_ready),
    .id_ready(id_ready),
    .id_valid(id_valid),
    //liushui
    .ID_pc(id_pc),
    .ID_instr(ID_instr),
    //regfile
    .ID_w_ena(id_w_ena),
    .ID_w_addr(id_w_addr),
    .ID_data1(id_data1),
    .ID_data2(id_data2),
    .ID_imm(id_imm),
    
    //ex
    .ID_exop(id_exop),
    .ID_aluop(id_aluop),
    //mem    
    .ID_memwop(id_memwop),
    .ID_memrop(id_memrop),
    .ID_mem_ena(id_mem_ena),
    .ID_mem_wr(id_mem_wr),


    .EX_w_ena(EX_w_ena),
    .EX_w_addr(EX_w_addr),
    .EX_data1(EX_data1),
    .EX_data2(EX_data2),
    .EX_imm(EX_imm),

    .EX_exop(EX_exop),
    .EX_aluop(EX_aluop),
    //mem    
    .EX_memwop(EX_memwop),
    .EX_memrop(EX_memrop),
    .EX_mem_ena(EX_mem_ena),
    .EX_mem_wr(EX_mem_wr),

    .EX_instr(EX_instr),
    .EX_pc(EX_pc)
);

wire          EX_w_ena;
wire [`ysyx_22040931_REG_BUS]  EX_w_addr;
wire [`ysyx_22040931_DATA_BUS] EX_data1;
wire [`ysyx_22040931_DATA_BUS] EX_data2;
wire [`ysyx_22040931_DATA_BUS] EX_imm;

wire [2 : 0]     EX_exop;
wire [`ysyx_22040931_ALU_BUS]    EX_aluop;
//mem    
wire [2 : 0]   EX_memwop;
wire [2 : 0]   EX_memrop;
wire          EX_mem_ena;
wire           EX_mem_wr;
wire [`ysyx_22040931_INST_BUS] EX_instr;
wire [`ysyx_22040931_PC_BUS] EX_pc;

ysyx_22040931_EX ysyx_22040931_EX(
    .reset(reset),
    .clock(clock),
    .id_gi_valid(id_valid),
    .ex_gi_ready(ex_ready),
    .to_ex_valid(to_ex_valid),
    .to_id_ready(to_id_ready),
    
    .w_ena_i(EX_w_ena),
    .w_addr_i(EX_w_addr),
    .pc_i(EX_pc),
    .instr(EX_instr),
    
    .data1(EX_data1),
    .data2(EX_data2),
    .imm(EX_imm),

    .exop(EX_exop),
    .aluop(EX_aluop),
    //mem    
    .memwop_i(EX_memwop),
    .memrop_i(EX_memrop),
    .mem_ena_i(EX_mem_ena),
    .mem_wr_i(EX_mem_wr),
    

    //regfile
    .w_ena(ex_w_ena),
    .w_addr(ex_w_addr),
    .w_data(ex_w_data),
    //mem
    .memwop(ex_memwop),
    .memrop(ex_memrop),
    .mem_ena(ex_mem_ena),
    .mem_wr(ex_mem_wr),    
    .mem_addr(ex_mem_addr),
    .mem_data(ex_mem_data),
    //liushuixian
    .instr_o(ex_instr),
    .pc_o(ex_pc)

);
//ex woshou
wire to_ex_valid;
wire to_id_ready;


//regfile
wire ex_w_ena;
wire [`ysyx_22040931_REG_BUS] ex_w_addr;
wire [`ysyx_22040931_DATA_BUS] ex_w_data;
//mem
wire [2 : 0]   ex_memwop;
wire [2 : 0]   ex_memrop;
wire          ex_mem_ena;
wire           ex_mem_wr;    
wire [`ysyx_22040931_MEM_BUS] ex_mem_addr;
wire [`ysyx_22040931_DATA_BUS] ex_mem_data;
//liushuixian
wire [`ysyx_22040931_INST_BUS] ex_instr;
wire [`ysyx_22040931_PC_BUS] ex_pc;


//ex valid <-> ready
wire ex_ready;
wire ex_valid;

ex_mem ex_mem(
    .reset(reset),
    .clock(clock),
    .flush(),
    .stall(),
    //wo shou
    .id_valid(to_ex_valid),
    .mem_ready(to_ex_ready),
    .ex_ready(ex_ready),
    .ex_valid(ex_valid),
    //liushuixian
    .EX_pc(ex_pc),
    .EX_instr(ex_instr),
    //regfile
    .EX_w_ena(ex_w_ena),
    .EX_w_addr(ex_w_addr),
    .EX_w_data(ex_w_data),
    //mem
    .EX_memwop(ex_memwop),
    .EX_memrop(ex_memrop),
    .EX_mem_ena(ex_mem_ena),
    .EX_mem_wr(ex_mem_wr),    
    .EX_mem_addr(ex_mem_addr),
    .EX_mem_data(ex_mem_data),


    .MEM_w_ena(MEM_w_ena),
    .MEM_w_addr(MEM_w_addr),
    .MEM_w_data(MEM_w_data),
    //mem
    .MEM_memwop(MEM_memwop),
    .MEM_memrop(MEM_memrop),
    .MEM_mem_ena(MEM_mem_ena),
    .MEM_mem_wr(MEM_mem_wr),
    .MEM_mem_addr(MEM_mem_addr),
    .MEM_mem_stor_data(MEM_mem_stor_data),
    //liushuixian
    .MEM_instr(MEM_instr),
    .MEM_pc(MEM_pc)

);


wire          MEM_w_ena;
wire [`ysyx_22040931_REG_BUS] MEM_w_addr;
wire [`ysyx_22040931_DATA_BUS] MEM_w_data;
//mem
wire [2 : 0]   MEM_memwop;
wire [2 : 0]   MEM_memrop;
wire           MEM_mem_ena;
wire           MEM_mem_wr;
wire [`ysyx_22040931_MEM_BUS]  MEM_mem_addr;
wire [`ysyx_22040931_DATA_BUS] MEM_mem_stor_data;
//liushuixian
wire [`ysyx_22040931_INST_BUS] MEM_instr;
wire [`ysyx_22040931_PC_BUS]  MEM_pc;


ysyx_22040931_MEM ysyx_22040931_MEM(

    //woshou
    .ex_gi_valid(ex_valid),
    .mem_gi_ready(mem_ready),
    .to_mem_valid(to_mem_valid),
    .to_ex_ready(to_ex_ready),
    //arb woshou
    .arbiter_mem_valid(arbiter_mem_valid),
    .arbiter_ex_ready(arbiter_ex_ready),
    //regfile
    .w_ena_i(MEM_w_ena),
    .w_addr_i(MEM_w_addr),
    .w_data_i(MEM_w_data),
    //mem
    .memwop(MEM_memwop),
    .memrop(MEM_memrop),
    .mem_ena_i(MEM_mem_ena & ex_valid),  // ENA & VALID
    .mem_wr_i(MEM_mem_wr),
    .mem_addr_i(MEM_mem_addr),
    .mem_stor_data_i(MEM_mem_stor_data),
    .mem_data(momory_data),               
    //liushuixian
    .pc_i(MEM_pc),
    .instr(MEM_instr),


    .w_ena(mem_w_ena),
    .w_addr(mem_w_addr),
    .w_data(mem_w_data),
    //mem
    .memop(memop),//
    .mem_ena(mem_ena),
    .mem_wr(mem_wr),
    .mem_addr(mem_addr),
    .mem_stor_data(mem_stor_data),//
    //liushuixian
    .instr_o(mem_instr),
    .pc_o(mem_pc)

);
//mem woshou
wire to_mem_valid;
wire to_ex_ready;


wire mem_w_ena;
wire [`ysyx_22040931_REG_BUS] mem_w_addr;
wire [`ysyx_22040931_DATA_BUS] mem_w_data;
//liushuixian
wire [`ysyx_22040931_PC_BUS] mem_pc;
wire [`ysyx_22040931_INST_BUS] mem_instr;


//mem valid <-> ready
//wire mem_ready;
wire mem_valid;

mem_wb mem_wb(
    .reset(reset),
    .clock(clock),
    .flush(),
    .stall(),
    //wo shou
    .ex_valid(to_mem_valid),
    //input wire wb_ready,
    .mem_ready(mem_ready),
    .mem_valid(mem_valid),
    //liushuixian
    .MEM_pc(mem_pc),
    .MEM_instr(mem_instr),
    //regfile 
    .MEM_w_ena(mem_w_ena),
    .MEM_w_addr(mem_w_addr),
    .MEM_w_data(mem_w_data),


    .WB_w_ena(WB_w_ena),
    .WB_w_addr(WB_w_addr),
    .WB_w_data(WB_w_data),
    //liushuixian
    .WB_instr(WB_instr),
    .WB_pc(WB_pc)
);


wire          WB_w_ena;
wire [`ysyx_22040931_REG_BUS]  WB_w_addr;
wire [`ysyx_22040931_DATA_BUS] WB_w_data;
//liushuixian
wire [`ysyx_22040931_PC_BUS] WB_pc;
wire [`ysyx_22040931_INST_BUS] WB_instr;
// //difftest
// assign difftest_pc = WB_pc;
// assign difftest_instr = WB_instr;

ysyx_22040931_WB ysyx_22040931_WB(

    .w_ena_i(WB_w_ena),
    .w_addr_i(WB_w_addr),
    .w_data_i(WB_w_data),
    //liushuixian
    .pc_i(WB_pc),
    

    .w_ena(wb_w_ena),
    .w_addr(wb_w_addr),
    .w_data(wb_w_data)
);

wire wb_w_ena;
wire [4 : 0] wb_w_addr;
wire [`ysyx_22040931_DATA_BUS] wb_w_data;





// Difftest
reg cmt_wen;
reg [7:0] cmt_wdest;
reg [`ysyx_22040931_DATA_BUS] cmt_wdata;
reg [`ysyx_22040931_PC_BUS] cmt_pc;
reg [`ysyx_22040931_INST_BUS] cmt_inst;
reg cmt_valid;
reg trap;
reg [7:0] trap_code;
reg [63:0] cycleCnt;
reg [63:0] instrCnt;
reg [`ysyx_22040931_DATA_BUS] regs_diff [0 : 31];
reg [31 : 0] inter;
reg [63 : 0] MEM_except_type_f;


wire inst_valid = ((WB_pc != `ysyx_22040931_ZERO_PC) | (WB_instr != 0));// && (inter != 32'h7b) ;
//wire skip = (wb_instr == 32'h7b) | (wb_csr_addr == 12'hb00) | (MEM_except_type == 64'h2) | (wb_instr == 32'h00063783) | (wb_instr == 32'h00f63023);
//wire skip = (wb_instr == 32'h7b) | (wb_csr_addr == 12'hb00) | (MEM_except_type == 64'h2) | (wb_instr == 32'h0007b483) | (wb_instr == 32'h00f73023);
////wire skip = (wb_instr == 32'h7b) | (wb_csr_addr == 12'hb00) | (MEM_except_type == 64'h2) | (clint) ;
////wire cause = (MEM_except_type == 64'h4);
wire skip = (WB_instr == 32'h7b);

always @(negedge clock) begin
  if (reset) begin
    {cmt_wen, cmt_wdest, cmt_wdata, cmt_pc, cmt_inst, cmt_valid, trap, trap_code, cycleCnt, instrCnt} <= 0;
  end
  else if (~trap) begin
    cmt_wen <= WB_w_ena;//
    cmt_wdest <= {3'd0, WB_w_addr};//
    cmt_wdata <= WB_w_data;//
    cmt_pc <= WB_pc;//
    cmt_inst <= WB_instr;//
    cmt_valid <= inst_valid;
	  regs_diff <= regs;


    trap <= (WB_instr[6:0] == 7'h6b);      /////////////////////duo  xie  le   wb_instr
    trap_code <= regs[10][7:0];
    cycleCnt <= cycleCnt + 1;
    instrCnt <= instrCnt + {63'h0, inst_valid};
  end
end
// always @(posedge clock) begin
//        MEM_except_type_f <= MEM_except_type;
// end

// always @(*) begin
//   inter = 32'b0;
//   if((mcause[2 : 0] == 3'h7) && (MEM_except_type_f == 64'h1)) begin
//       inter = 32'd7;
//   end
// end

always @(posedge clock) begin
if(hhhh) begin
  $display("pc:%lh,,cyc:%ld\n",MEM_pc,cycleCnt);
end
  
end


DifftestArchEvent DifftestArchEvent (
    .clock(clock),	    // 时钟
    .coreid(0),		    // cpu id，单核时固定为0
    .intrNO(0),		   // 中断号，非0时产生中断。产生中断的时钟周期中，DifftestInstrCommit提交的valid需为0
    .cause(0),			// 异常号，ecall时不需要考虑
    .exceptionPC(cmt_pc),	// 产生异常时的PC
    .exceptionInst(cmt_inst)	// 产生异常时的指令
);


DifftestInstrCommit DifftestInstrCommit(
  .clock              (clock),
  .coreid             (0),
  .index              (0),
  .valid              (cmt_valid),
  .pc                 (cmt_pc),
  .instr              (cmt_inst),
  .skip               (skip),                       //fffffffffffffffffffffffffffffff
  .special            (0),
  .isRVC              (0),
  .scFailed           (0),
  .wen                (cmt_wen),
  .wdest              (cmt_wdest),
  .wdata              (cmt_wdata)
);

DifftestArchIntRegState DifftestArchIntRegState (
  .clock              (clock),
  .coreid             (0),
  .gpr_0              (regs_diff[0]),
  .gpr_1              (regs_diff[1]),
  .gpr_2              (regs_diff[2]),
  .gpr_3              (regs_diff[3]),
  .gpr_4              (regs_diff[4]),
  .gpr_5              (regs_diff[5]),
  .gpr_6              (regs_diff[6]),
  .gpr_7              (regs_diff[7]),
  .gpr_8              (regs_diff[8]),
  .gpr_9              (regs_diff[9]),
  .gpr_10             (regs_diff[10]),
  .gpr_11             (regs_diff[11]),
  .gpr_12             (regs_diff[12]),
  .gpr_13             (regs_diff[13]),
  .gpr_14             (regs_diff[14]),
  .gpr_15             (regs_diff[15]),
  .gpr_16             (regs_diff[16]),
  .gpr_17             (regs_diff[17]),
  .gpr_18             (regs_diff[18]),
  .gpr_19             (regs_diff[19]),
  .gpr_20             (regs_diff[20]),
  .gpr_21             (regs_diff[21]),
  .gpr_22             (regs_diff[22]),
  .gpr_23             (regs_diff[23]),
  .gpr_24             (regs_diff[24]),
  .gpr_25             (regs_diff[25]),
  .gpr_26             (regs_diff[26]),
  .gpr_27             (regs_diff[27]),
  .gpr_28             (regs_diff[28]),
  .gpr_29             (regs_diff[29]),
  .gpr_30             (regs_diff[30]),
  .gpr_31             (regs_diff[31])
);

DifftestTrapEvent DifftestTrapEvent(
  .clock              (clock),
  .coreid             (0),
  .valid              (trap),
  .code               (trap_code),
  .pc                 (cmt_pc),
  .cycleCnt           (cycleCnt),   //
  .instrCnt           (instrCnt)
);

DifftestCSRState DifftestCSRState(
  .clock              (clock),
  .coreid             (0),
  .priviledgeMode     (3),  //M
  .mstatus            (0),
  .sstatus            (0),
  .mepc               (0),
  .sepc               (0),
  .mtval              (0),
  .stval              (0),
  .mtvec              (0),
  .stvec              (0),
  .mcause             (0),
  .scause             (0),
  .satp               (0),
  .mip                (0),
  .mie                (0),
  .mscratch           (0),
  .sscratch           (0),
  .mideleg            (0),
  .medeleg            (0)
);

DifftestArchFpRegState DifftestArchFpRegState(
  .clock              (clock),
  .coreid             (0),
  .fpr_0              (0),
  .fpr_1              (0),
  .fpr_2              (0),
  .fpr_3              (0),
  .fpr_4              (0),
  .fpr_5              (0),
  .fpr_6              (0),
  .fpr_7              (0),
  .fpr_8              (0),
  .fpr_9              (0),
  .fpr_10             (0),
  .fpr_11             (0),
  .fpr_12             (0),
  .fpr_13             (0),
  .fpr_14             (0),
  .fpr_15             (0),
  .fpr_16             (0),
  .fpr_17             (0),
  .fpr_18             (0),
  .fpr_19             (0),
  .fpr_20             (0),
  .fpr_21             (0),
  .fpr_22             (0),
  .fpr_23             (0),
  .fpr_24             (0),
  .fpr_25             (0),
  .fpr_26             (0),
  .fpr_27             (0),
  .fpr_28             (0),
  .fpr_29             (0),
  .fpr_30             (0),
  .fpr_31             (0)
);




endmodule
