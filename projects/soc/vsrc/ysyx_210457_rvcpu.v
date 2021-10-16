
//2021.10.10
//xu xin


`timescale 1ns / 1ps

`define ZERO_WORD  64'h00000000_00000000
`define ZERO_PC    64'h00000000_00000000
`define ZERO_ADDR  32'h00000000
`define ZERO_INST  32'h00000000    
`define REG_BUS    63 : 0 
`define PC_BUS     63 : 0 
`define ADDR_BUS   31 : 0  
`define INST_BUS   31 : 0 
`define ZERO_ENA   1'b0
`define ZERO_REG_ADDR   5'b00000
`define PC_START   64'h00000000_30000000 

module ysyx_210457_rvcpu(
    input                 clock,
    input                 reset,
    input [5 : 0]         stall,

    input  wire [31 : 0] if_data_read,
    output wire if_valid,
    output wire [`ADDR_BUS] IF_addr,
    output wire [1 : 0] if_size,
    output wire if_req,

    input  wire [63 : 0] mem_data,
    output wire [63 : 0] MEM_stor_data,
    output wire mem_valid,
    output wire [`ADDR_BUS] mem_addr,
    output wire [1 : 0] mem_sel,
    output wire mem_req,

    output wire flush

);
assign IF_addr = IF_pc[`ADDR_BUS];

//IF_stage -> if_id
wire wash;
wire [`PC_BUS] IF_pc;
wire [31 : 0] instr;
wire if_forecase;
wire [`PC_BUS] if_branch;



//if_id -> ID_stage
wire [`INST_BUS] id_instr;
wire [`PC_BUS] id_branch;
//if_id -> IF_stage too
wire [`PC_BUS] id_pc;

//if_id -> IF_stage
wire id_forecase;

//regfile -> ID_stage
wire [`REG_BUS] r_data1;
wire [`REG_BUS] r_data2;


//ID_stage -> regfile
wire reg1_r_ena;
wire reg2_r_ena;
wire [4 : 0] reg1_addr;
wire [4 : 0] reg2_addr;

//ID_stage -> IF_stage
wire [`PC_BUS] branch;
wire pc_con;
wire mux_pc;
wire error_branch;

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
wire id_csr_ena;


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
wire ex_csr_ena;
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
wire [`ADDR_BUS] ex_mem_waddr;
wire [`ADDR_BUS] ex_mem_raddr;
wire [`REG_BUS] ex_stor_data;
wire EX_mem_wr;
wire EX_mem_ena;
wire [11 : 0] ex_csr_addr;    //csr read     ///csr o
wire [`REG_BUS] ex_w_csr_data;
wire EX_csr_ena;
wire [`REG_BUS] except_type;

//ex_men -> MEM_stage
wire [`REG_BUS] mem_w_data;
wire mem_w_ena;
wire [4 : 0] mem_w_addr;
wire [`PC_BUS] men_pc;
wire [`INST_BUS] men_instr;
wire [`ADDR_BUS] mem_mem_waddr;
wire [`ADDR_BUS] mem_mem_raddr;
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
wire [11 : 0] MEM_csr_addr;         ///csr o
wire [`REG_BUS] MEM_w_csr_data;
wire MEM_csr_ena;
wire [`REG_BUS] MEM_except_type;
//MEM_stage -> IF_stage
wire [`PC_BUS] new_pc;

//mem_wb -> WB_stage
wire [`REG_BUS] wb_w_data;
wire wb_w_ena;
wire [4 : 0] wb_w_addr;
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

//CSR_reg -> EX_stage
wire [`REG_BUS] csr_reg_data;
//CSR_reg -> MEM_stage
wire [`REG_BUS] mtvec;
wire [`REG_BUS] mepc;
wire mie;
wire mip;
wire mstatus;


//Clint -> CSR_reg
wire time_inter;
//Clint -> MEM_reg
wire [`REG_BUS] clint_data;




    ysyx_210457_IF_stage IF_stage (
    .reset(reset),
    .clock(clock),
    .branch(branch),
    .mux_pc(mux_pc),
    .pc_con(pc_con),
    .pc_id(id_pc),
    .new_pc(new_pc),
    .flush(flush),
    .id_forecase(id_forecase),
    .error_branch(error_branch),
    .stall(stall[5]),

    .if_branch(if_branch),
    .if_forecase(if_forecase),
    .wash(wash),
    .instr(instr),

    .if_valid(if_valid),
    .if_data_read(if_data_read),
    .IF_pc(IF_pc),
    .if_size(if_size),
    .if_req(if_req)
);

    ysyx_210457_if_id if_id (
    .reset(reset),
    .clock(clock),
    .if_pc(IF_pc),
    .if_instr(instr),
    .pc_con(pc_con),
    .wash(wash),
    .flush(flush),
    .if_forecase(if_forecase),
    .if_branch(if_branch),
    .stall(stall[4:3]),

    .id_branch(id_branch),
    .id_forecase(id_forecase),
    .id_pc(id_pc),
    .id_instr(id_instr)
);

    ysyx_210457_regfile regfile(
    .clock(clock),
	.reset(reset),
	
	.w_addr(WB_w_addr),
	.w_data(WB_w_data),
	.w_ena(WB_w_ena),
	
  	.r_addr1(reg1_addr),
	.r_ena1(reg1_r_ena),
  	.r_data1(r_data1),  //OUT1

	.r_addr2(reg2_addr),
	.r_ena2(reg2_r_ena),
	.r_data2(r_data2)  //OUT2
  

);

    ysyx_210457_ID_stage ID_stage (
    .reset(reset),
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

    .if_branch(id_branch),

    .error_branch(error_branch),

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
    .id_mem_ena(id_mem_ena),

    .id_csr_ena(id_csr_ena) 

);

    ysyx_210457_id_ex id_ex (
    .reset(reset),
    .clock(clock),
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
    .stall(stall[3 : 2]),

    .id_csr_ena(id_csr_ena),


    .ex_csr_ena(ex_csr_ena),

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

    ysyx_210457_EX_stage EX_stage (
    .reset(reset),

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
    .id_csr_ena(ex_csr_ena),

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
    .ex_csr_ena(EX_csr_ena), 

    .EX_instr(EX_instr),
    .EX_pc(EX_pc),

    .except_type(except_type)
);

    ysyx_210457_ex_mem ex_mem (
    .reset(reset),
    .clock(clock),
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

    .ex_csr_ena(EX_csr_ena),               ///csr
    .ex_csr_addr(ex_csr_addr),         
    .ex_w_csr_data(ex_w_csr_data),
    .ex_except_type(except_type),
    .flush(flush),
    .stall(stall[2 : 1]),

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

    ysyx_210457_MEM_stage MEM_stage (
    .reset(reset),
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
    //.mem_data(data),              //delete for AXI

    .ex_pc(men_pc),
    .ex_instr(men_instr),

    .ex_csr_addr(mem_csr_addr),         ///csr
    .ex_w_csr_data(mem_w_csr_data),
    .ex_csr_ena(mem_csr_ena),
    .ex_except_type(mem_except_type),

    
    .mepc(mepc),        //csr_read
    .mip(mip),
    .mie(mie),
    .mtvec(mtvec),
    .mstatus(mstatus),

    .clint_data(clint_data),      //clint

    .mem_csr_addr(MEM_csr_addr),         ///csr o
    .mem_w_csr_data(MEM_w_csr_data),
    .mem_csr_ena(MEM_csr_ena),
    .mem_except_type(MEM_except_type),
    .new_pc(new_pc),

    .mem_pc(MEM_pc),

    .mem_w_data(MEM_w_data),
    .mem_w_ena(MEM_w_ena),
    .mem_w_addr(MEM_w_addr),

    .mem_valid(mem_valid),
    .mem_data(mem_data),
    .mem_stor_data(MEM_stor_data),
    .mem_addr(mem_addr),
    .mem_sel(mem_sel),
    .mem_req(mem_req)
);


    ysyx_210457_mem_wb mem_wb (
    .clock(clock),
    .reset(reset),
    .mem_w_data(MEM_w_data),
    .mem_w_ena(MEM_w_ena),
    .mem_w_addr(MEM_w_addr),
    
    .mem_csr_addr(MEM_csr_addr),         //csr
    .mem_w_csr_data(MEM_w_csr_data),
    .mem_csr_ena(MEM_csr_ena),
    .flush(flush),
    .stall(stall[1:0]),
    

    .wb_csr_addr(wb_csr_addr),         ///csr o
    .wb_w_csr_data(wb_w_csr_data),
    .wb_csr_ena(wb_csr_ena),
    
    .wb_w_data(wb_w_data),
    .wb_w_ena(wb_w_ena),
    .wb_w_addr(wb_w_addr)
);

   ysyx_210457_WB_stage WB_stage (
    .reset(reset),
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

   ysyx_210457_CSR_reg CSR_reg (
    .reset(reset),
    .clock(clock),
    .csr_r_addr(ex_csr_addr),

    .csr_w_ena(WB_csr_ena),
    .csr_w_addr(WB_csr_addr),
    .csr_w_data(WB_w_csr_data),
   
    .except_type(MEM_except_type),
    .except_pc(MEM_pc),             //mem_pc
    .time_inter(time_inter),
    .stall(stall[1]),

    .csr_reg_data(csr_reg_data),
    .mtvec(mtvec),
    .mepc(mepc),
    .mie(mie),
    .mip(mip),
    .mstatus(mstatus),


    .flush(flush)


);

    ysyx_210457_Clint Clint (
    .clock(clock),
    .reset(reset),
    .ex_mem_waddr(mem_mem_waddr),
    .ex_mem_raddr(mem_mem_raddr),
    .ex_stor_data(mem_stor_data),
    .ex_mem_wr(mem_mem_wr),
    .ex_mem_ena(mem_mem_ena),


    .time_inter(time_inter),
    .clint_data(clint_data)
);

endmodule
