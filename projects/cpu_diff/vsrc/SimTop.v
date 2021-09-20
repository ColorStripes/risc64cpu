
//--xuezhen--

`include "defines.v"

module SimTop(
    input         clock,
    input         reset,

    input  [63:0] io_logCtrl_log_begin,
    input  [63:0] io_logCtrl_log_end,
    input  [63:0] io_logCtrl_log_level,
    input         io_perfInfo_clean,
    input         io_perfInfo_dump,

    output        io_uart_out_valid,
    output [7:0]  io_uart_out_ch,
    output        io_uart_in_valid,
    input  [7:0]  io_uart_in_ch
);

//SIMTOP -> rvcpu
wire clk;
wire rst;

//IF_stage -> if_id
wire wash;
wire [`PC_BUS] pc;
wire [31 : 0] instr;

//if_id -> ID_stage
wire [`INST_BUS] id_instr;
//if_id -> IF_stage too
wire [`PC_BUS] id_pc;

//regfile -> ID_stage
wire [`REG_BUS] r_data1;
wire [`REG_BUS] r_data2;

// regfile -> difftest
wire [`REG_BUS] regs[0 : 31];

//ID_stage -> regfile
wire reg1_r_ena;
wire reg2_r_ena;
wire [4 : 0] reg1_addr;
wire [4 : 0] reg2_addr;

//ID_stage -> IF_stage
wire [`PC_BUS] branch;
wire pc_con;
wire mux_pc;

//ID_stage -> id_ex
wire [`PC_BUS] ID_pc; 
wire [`INST_BUS] ID_instr; 
wire [6 : 0] aluop;
wire [3 : 0] alusel;
wire [`REG_BUS] reg1_data;
wire [`REG_BUS] reg2_data;
wire [4 : 0] w_addr;
wire w_ena;
wire [4 : 0] memop;
wire [63 : 0] imm;
wire id_mem_wr;
wire id_mem_ena;


//id_ex -> EX_stage
wire [4 : 0] ex_w_addr;
wire ex_w_ena;
wire [`REG_BUS] ex_reg1_data;
wire [`REG_BUS] ex_reg2_data;
wire [6 : 0] ex_aluop;
wire [3 : 0] ex_alusel;
wire [`PC_BUS] ex_pc;
wire [`INST_BUS] ex_instr;
wire [4 : 0] ex_memop;
wire [63 : 0] ex_imm;
//id_ex -> ID_stage too
wire ex_mem_wr;
wire ex_mem_ena;


//EX_stage -> ex_mem
wire [`REG_BUS] ex_w_data;
wire EX_w_ena;
wire [4 : 0] EX_w_addr;
wire [`PC_BUS] EX_pc;
wire [`INST_BUS] EX_instr;
wire [4 : 0] EX_memop;
wire [`REG_BUS] ex_mem_waddr;
wire [`REG_BUS] ex_mem_raddr;
wire [`REG_BUS] ex_stor_data;
wire EX_mem_wr;
wire EX_mem_ena;
wire [11 : 0] ex_csr_addr;    //csr read     ///csr o
wire [`REG_BUS] ex_w_csr_data;
wire ex_csr_ena;
wire [`REG_BUS] except_type;

//ex_men -> MEM_stage
wire [`REG_BUS] mem_w_data;
wire mem_w_ena;
wire [4 : 0] mem_w_addr;
wire [`PC_BUS] men_pc;
wire [`INST_BUS] men_instr;
wire [`REG_BUS] mem_mem_waddr;
wire [`REG_BUS] mem_mem_raddr;
wire [4 : 0] mem_memop;
wire [`REG_BUS] mem_stor_data;
wire mem_mem_wr;
wire mem_mem_ena;
wire mem_csr_ena;                 ///csr o
wire [11 : 0] mem_csr_addr;         
wire [`REG_BUS] mem_w_csr_data;
wire [`REG_BUS] mem_except_type;

//MEM_stage -> mem_wb
wire [`REG_BUS] MEM_w_data;
wire MEM_w_ena;
wire [4 : 0] MEM_w_addr;
wire [`PC_BUS] MEM_pc;
wire [`INST_BUS] MEM_instr;
wire [11 : 0] MEM_csr_addr;         ///csr o
wire [`REG_BUS] MEM_w_csr_data;
wire MEM_csr_ena;
wire [`REG_BUS] MEM_except_type;
//MEM_stage -> IF_stage
wire [`PC_BUS] new_pc;

//MEM_stage -> DATA_MEM
wire [`REG_BUS] MEM_mem_waddr;
wire [`REG_BUS] MEM_mem_raddr;
wire [`REG_BUS] mem_sel;
wire [`REG_BUS] MEM_stor_data;
wire mem_wr;
wire MEM_mem_ena;

//DATA_MEM -> MEM_stage
wire [63 : 0] data;

//mem_wb -> WB_stage
wire [`REG_BUS] wb_w_data;
wire wb_w_ena;
wire [4 : 0] wb_w_addr;
wire [`PC_BUS] wb_pc;
wire [`INST_BUS] wb_instr;
wire [11 : 0] wb_csr_addr;        ///csr_o
wire [`REG_BUS] wb_w_csr_data;
wire wb_csr_ena;

//WB_stage -> regfile
wire WB_w_ena;
wire [`REG_BUS] WB_w_data;
wire [4 : 0] WB_w_addr;

//WB_stage -> CSR_reg
wire [11 : 0] WB_csr_addr;
wire [`REG_BUS] WB_w_csr_data;
wire WB_csr_ena;
wire [`REG_BUS] WB_except_type;

//CSR_reg -> EX_stage
wire [`REG_BUS] csr_reg_data;
//CSR_reg -> MEM_stage
wire [`REG_BUS] mtvec;
wire [`REG_BUS] mepc;
wire [`REG_BUS] mie;
wire [`REG_BUS] mip;
//CSR_reg -> difftest
wire [`REG_BUS] mcause;
wire [`REG_BUS] mcycle;
wire [`REG_BUS] mstatus;
//CSR_reg -> ALL_stage
wire flush;
//Clint -> CSR_reg
wire time_inter;
//Clint -> MEM_reg
wire [`REG_BUS] clint_data;


assign clk = clock;
assign rst = reset;

    IF_stage IF_stage (
    .rst(rst),
    .clk(clk),
    .branch(branch),
    .mux_pc(mux_pc),
    .pc_con(pc_con),
    .pc_id(id_pc),
    .new_pc(new_pc),
    .flush(flush),

    .wash(wash),
    .IF_pc(pc),
    .instr(instr)
);

    if_id if_id (
    .rst(rst),
    .clk(clk),
    .if_pc(pc),
    .if_instr(instr),
    .pc_con(pc_con),
    .wash(wash),
    .flush(flush),

    .id_pc(id_pc),
    .id_instr(id_instr)
);

    regfile regfile(
    .clk(clk),
	  .rst(rst),
	
	  .w_addr(WB_w_addr),
	  .w_data(WB_w_data),
	  .w_ena(WB_w_ena),
	
  	.r_addr1(reg1_addr),
	  .r_ena1(reg1_r_ena),
  	.r_data1(r_data1),  //OUT1

	  .r_addr2(reg2_addr),
	  .r_ena2(reg2_r_ena),
	  .r_data2(r_data2),  //OUT2
    .regs_o(regs)
  

);

    ID_stage ID_stage (
    .rst(rst),
    .IF_pc(id_pc), 
    .IF_instr(id_instr),

    .reg_data1(r_data1), //
    .reg_data2(r_data2), //

    .ex_w_data(ex_w_data),    //ex_stage for data
    .ex_w_ena(ex_w_ena),
    .ex_w_addr(ex_w_addr),

    .mem_w_data(MEM_w_data),   //men_stage for data
    .mem_w_ena(MEM_w_ena),
    .mem_w_addr(MEM_w_addr),

    .idex_mem_ena(ex_mem_ena),          //id_ex memory enable
    .idex_mem_wr(ex_mem_wr),


    .reg1_r_ena(reg1_r_ena),
    .reg2_r_ena(reg2_r_ena),

    .reg1_addr(reg1_addr),
    .reg2_addr(reg2_addr),

    .aluop(aluop),          //ALUoptions
    .alusel(alusel),

    .reg1_data(reg1_data),  //
    .reg2_data(reg2_data),  //

    .w_addr(w_addr),       
    .w_ena(w_ena),                  //write enable

    .ID_pc(ID_pc),       //pc now
    .ID_instr(ID_instr), 
    .branch(branch),    //pc next
    .mux_pc(mux_pc),
    .pc_con(pc_con),
    .imm(imm),

    .memop(memop),
    .id_mem_wr(id_mem_wr),
    .id_mem_ena(id_mem_ena)

);

    id_ex id_ex (
    .rst(rst),
    .clk(clk),
    .id_imm(imm),

    .id_pc(ID_pc),
    .id_instr(ID_instr),

    .id_memop(memop),
    .id_aluop(aluop),
    .id_alusel(alusel),
    .id_mem_wr(id_mem_wr),
    .id_mem_ena(id_mem_ena),

    .id_reg1_data(reg1_data),
    .id_reg2_data(reg2_data),

    .id_w_ena(w_ena),
    .id_w_addr(w_addr),
    .flush(flush),


    .ex_w_addr(ex_w_addr),
    .ex_w_ena(ex_w_ena),

    .ex_reg1_data(ex_reg1_data),
    .ex_reg2_data(ex_reg2_data),

    .ex_memop(ex_memop),
    .ex_aluop(ex_aluop),
    .ex_alusel(ex_alusel),
    .ex_imm(ex_imm),
    .ex_mem_wr(ex_mem_wr),
    .ex_mem_ena(ex_mem_ena),

    .ex_instr(ex_instr),
    .ex_pc(ex_pc)
    
); 

    EX_stage EX_stage (
    .rst(rst),

    .ID_pc(ex_pc),
    .ID_instr(ex_instr),

    .id_w_addr(ex_w_addr),
    .id_w_ena(ex_w_ena),

    .id_reg1_data(ex_reg1_data),
    .id_reg2_data(ex_reg2_data),
    .id_imm(ex_imm),

    .id_memop(ex_memop),
    .id_mem_wr(ex_mem_wr),
    .id_mem_ena(ex_mem_ena),
    .id_aluop(ex_aluop),
    .id_alusel(ex_alusel),

    .csr_reg_data(csr_reg_data),               //csr
    .mem_csr_addr(mem_csr_addr),
    .mem_w_csr_data(mem_w_csr_data),
    .mem_csr_ena(mem_csr_ena),
    .wb_csr_addr(wb_csr_addr),
    .wb_w_csr_data(wb_w_csr_data),
    .wb_csr_ena(wb_csr_ena),


    .ex_w_data(ex_w_data),
    .ex_w_ena(EX_w_ena),
    .ex_w_addr(EX_w_addr),

    .ex_mem_raddr(ex_mem_raddr),
    .ex_mem_waddr(ex_mem_waddr),
    .ex_stor_data(ex_stor_data),
    .ex_memop(EX_memop),
    .ex_mem_wr(EX_mem_wr),
    .ex_mem_ena(EX_mem_ena),

    .ex_csr_addr(ex_csr_addr),         ///csr o
    .ex_w_csr_data(ex_w_csr_data),
    .ex_csr_ena(ex_csr_ena), 

    .EX_instr(EX_instr),
    .EX_pc(EX_pc),

    .except_type(except_type)
);

    ex_mem ex_mem (
    .rst(rst),
    .clk(clk),
    .ex_pc(EX_pc),
    .ex_instr(EX_instr),
    .ex_w_data(ex_w_data),
    .ex_w_ena(EX_w_ena),
    .ex_w_addr(EX_w_addr),
    .ex_mem_waddr(ex_mem_waddr),
    .ex_mem_raddr(ex_mem_raddr),
    .ex_memop(EX_memop),
    .ex_stor_data(ex_stor_data),
    .ex_mem_wr(EX_mem_wr),
    .ex_mem_ena(EX_mem_ena),

    .ex_csr_ena(ex_csr_ena),               ///csr
    .ex_csr_addr(ex_csr_addr),         
    .ex_w_csr_data(ex_w_csr_data),
    .ex_except_type(except_type),
    .flush(flush),

    .mem_w_data(mem_w_data),
    .mem_w_ena(mem_w_ena),
    .mem_w_addr(mem_w_addr),

    .mem_mem_waddr(mem_mem_waddr),
    .mem_mem_raddr(mem_mem_raddr),
    .mem_memop(mem_memop),
    .mem_stor_data(mem_stor_data),
    .mem_mem_wr(mem_mem_wr),
    .mem_mem_ena(mem_mem_ena),

    .mem_csr_ena(mem_csr_ena),             ///csr o
    .mem_csr_addr(mem_csr_addr),         
    .mem_w_csr_data(mem_w_csr_data),
    .mem_except_type(mem_except_type),

    .men_instr(men_instr),
    .men_pc(men_pc)
);

    MEM_stage MEM_stage (
    .rst(rst),
    .time_inter(time_inter),
    .ex_w_data(mem_w_data),
    .ex_w_ena(mem_w_ena),
    .ex_w_addr(mem_w_addr),
    .ex_mem_waddr(mem_mem_waddr),
    .ex_mem_raddr(mem_mem_raddr),
    .ex_stor_data(mem_stor_data),
    .ex_memop(mem_memop),
    
    .ex_mem_wr(mem_mem_wr),
    .ex_mem_ena(mem_mem_ena),
    .mem_data(data),

    .ex_pc(men_pc),
    .ex_instr(men_instr),

    .ex_csr_addr(mem_csr_addr),         ///csr
    .ex_w_csr_data(mem_w_csr_data),
    .ex_csr_ena(mem_csr_ena),
    .ex_except_type(mem_except_type),

    .wb_csr_addr(wb_csr_addr),         //wb_csr
    .wb_w_csr_data(wb_w_csr_data),
    .wb_csr_ena(wb_csr_ena),
    
    .csr_mepc(mepc),        //csr_read
    .csr_mip(mip),
    .csr_mie(mie),
    .csr_mtvec(mtvec),
    .csr_mstatus(mstatus),

    .clint_data(clint_data),      //clint

    .mem_csr_addr(MEM_csr_addr),         ///csr o
    .mem_w_csr_data(MEM_w_csr_data),
    .mem_csr_ena(MEM_csr_ena),
    .mem_except_type(MEM_except_type),
    .new_pc(new_pc),

    .mem_instr(MEM_instr),
    .mem_pc(MEM_pc),

    .mem_w_data(MEM_w_data),
    .mem_w_ena(MEM_w_ena),
    .mem_w_addr(MEM_w_addr),

    .mem_mem_waddr(MEM_mem_waddr),
    .mem_mem_raddr(MEM_mem_raddr),
    .mem_sel(mem_sel),
    .mem_stor_data(MEM_stor_data),
    .mem_wr(mem_wr),
    .mem_mem_ena(MEM_mem_ena)

);


    RAMHelper RAMHelper(
    .clk(clk),
    .en(MEM_mem_ena),
    .rIdx({3'b000,(MEM_mem_raddr-64'h0000_0000_8000_0000)>>3}),
    .rdata(data),
    .wIdx({3'b000,(MEM_mem_waddr-64'h0000_0000_8000_0000)>>3}),
    .wdata(MEM_stor_data),
    .wmask(mem_sel),          //!!!!!!!!!!!
    .wen(mem_wr)
);

    mem_wb mem_wb (
    .clk(clk),
    .rst(rst),
    .mem_w_data(MEM_w_data),
    .mem_w_ena(MEM_w_ena),
    .mem_w_addr(MEM_w_addr),
    .mem_pc(MEM_pc),
    .mem_instr(MEM_instr),
    
    .mem_csr_addr(MEM_csr_addr),         //csr
    .mem_w_csr_data(MEM_w_csr_data),
    .mem_csr_ena(MEM_csr_ena),
    .flush(flush),

    .wb_csr_addr(wb_csr_addr),         ///csr o
    .wb_w_csr_data(wb_w_csr_data),
    .wb_csr_ena(wb_csr_ena),
    
    .wb_instr(wb_instr),
    .wb_pc(wb_pc),
    .wb_w_data(wb_w_data),
    .wb_w_ena(wb_w_ena),
    .wb_w_addr(wb_w_addr)
);

   WB_stage WB_stage (
    .rst(rst),
    .mem_w_ena(wb_w_ena),
    .mem_w_data(wb_w_data),
    .mem_w_addr(wb_w_addr),
    .mem_csr_ena(wb_csr_ena),           //csr
    .mem_csr_addr(wb_csr_addr),         
    .mem_w_csr_data(wb_w_csr_data),

    
    .wb_csr_ena(WB_csr_ena),                 ///csr o
    .wb_csr_addr(WB_csr_addr),         
    .wb_w_csr_data(WB_w_csr_data),
    .wb_w_ena(WB_w_ena),
    .wb_w_data(WB_w_data),
    .wb_w_addr(WB_w_addr)
);

   CSR_reg CSR_reg (
    .rst(rst),
    .clk(clk),
    .csr_r_addr(ex_csr_addr),

    .csr_w_ena(WB_csr_ena),
    .csr_w_addr(WB_csr_addr),
    .csr_w_data(WB_w_csr_data),
   
    .except_type(MEM_except_type),
    .except_pc(MEM_pc),             //mem_pc
    .time_inter(time_inter),

    .csr_reg_data(csr_reg_data),
    .mtvec(mtvec),
    .mepc(mepc),
    .mie(mie),
    .mip(mip),
    .mstatus(mstatus),

    .mcause(mcause),
    .mcycle(mcycle),

    .flush(flush)


);

    Clint Clint (
    .clk(clk),
    .rst(rst),
    .ex_mem_waddr(mem_mem_waddr),
    .ex_mem_raddr(mem_mem_raddr),
    .ex_stor_data(mem_stor_data),
    .ex_mem_wr(mem_mem_wr),
    .ex_mem_ena(mem_mem_ena),

    .time_inter(time_inter),
    .clint_data(clint_data)

);













// Difftest
reg cmt_wen;
reg [7:0] cmt_wdest;
reg [`REG_BUS] cmt_wdata;
reg [`REG_BUS] cmt_pc;
reg [31:0] cmt_inst;
reg cmt_valid;
reg trap;
reg [7:0] trap_code;
reg [63:0] cycleCnt;
reg [63:0] instrCnt;
reg [`REG_BUS] regs_diff [0 : 31];
reg [31 : 0] inter;
reg [31 : 0] inr;

wire inst_valid = ((wb_pc != `PC_START) | (wb_instr != 0));
wire skip = (wb_instr == 32'h7b) | (MEM_except_type == 64'h2) ;
wire cause = (MEM_except_type == 64'h4);

always @(negedge clock) begin
  if (reset) begin
    {cmt_wen, cmt_wdest, cmt_wdata, cmt_pc, cmt_inst, cmt_valid, trap, trap_code, cycleCnt, instrCnt,inr,inter} <= 0;
  end
  else if (~trap) begin
    cmt_wen <= WB_w_ena;//
    cmt_wdest <= {3'd0, WB_w_addr};//
    cmt_wdata <= WB_w_data;//
    cmt_pc <= wb_pc;//
    cmt_inst <= wb_instr;//
    cmt_valid <= inst_valid;
		regs_diff <= regs;
    inr <= mcause[31 : 0];
    inter <= inr;


    trap <= (wb_instr[6:0] == 7'h6b);      /////////////////////duo  xie  le   wb_instr
    trap_code <= regs[10][7:0];
    cycleCnt <= cycleCnt + 1;
    instrCnt <= instrCnt + inst_valid;
  end
end

DifftestArchEvent DifftestArchEvent (
    .clock(clock),			// 时钟
    .coreid(0),		// cpu id，单核时固定为0
    .intrNO(mcause[31 : 0]),		// 中断号，非0时产生中断。产生中断的时钟周期中，DifftestInstrCommit提交的valid需为0
    .cause(0),			// 异常号，ecall时不需要考虑
    .exceptionPC(wb_pc),	// 产生异常时的PC
    .exceptionInst(wb_instr)	// 产生异常时的指令
);


DifftestInstrCommit DifftestInstrCommit(
  .clock              (clock),
  .coreid             (0),
  .index              (0),
  .valid              (cmt_valid),
  .pc                 (cmt_pc),
  .instr              (cmt_inst),
  .skip               (skip),                       //fffffffffffffffffffffffffffffff
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
  .cycleCnt           (mcycle),   //
  .instrCnt           (instrCnt)
);

DifftestCSRState DifftestCSRState(
  .clock              (clock),
  .coreid             (0),
  .priviledgeMode     (`RISCV_PRIV_MODE_M),
  .mstatus            (mstatus),
  .sstatus            (0),
  .mepc               (mepc),
  .sepc               (0),
  .mtval              (0),
  .stval              (0),
  .mtvec              (mtvec),
  .stvec              (0),
  .mcause             (mcause),
  .scause             (0),
  .satp               (0),
  .mip                (mip),
  .mie                (mie),
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