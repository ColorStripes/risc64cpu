//2021.8.5
//xu xin
`include "defines.v"

module rvcpu (
    input wire clk,
    input wire rst,
    input wire [`INST_BUS] instr,
    
    output wire [`PC_BUS] pc,
    output wire IN_MEM_ENA
);

//IF_stage -> if_id
wire wash;

//if_id -> ID_stage
wire [`INST_BUS] id_instr;
//if_id -> IF_stage too
wire [`PC_BUS] id_pc;

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

//ID_stage -> id_ex
wire [`PC_BUS] ID_pc; 
wire [6 : 0] aluop;
wire [2 : 0] alusel;
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
wire [2 : 0] ex_alusel;
wire [`PC_BUS] ex_pc;
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
wire [4 : 0] EX_memop;
wire [`REG_BUS] ex_mem_addr;
wire [`REG_BUS] ex_stor_data;
wire EX_mem_wr;
wire EX_mem_ena;

//ex_men -> MEM_stage
wire [`REG_BUS] mem_w_data;
wire mem_w_ena;
wire [4 : 0] mem_w_addr;
wire [`PC_BUS] men_pc;
wire [`REG_BUS] mem_mem_addr;
wire [4 : 0] mem_memop;
wire [`REG_BUS] mem_stor_data;
wire mem_mem_wr;
wire mem_mem_ena;

//MEM_stage -> mem_wb
wire [`REG_BUS] MEM_w_data;
wire MEM_w_ena;
wire [4 : 0] MEM_w_addr;

//MEM_stage -> DATA_MEM
wire [`REG_BUS] MEM_mem_addr;
wire [7 : 0] mem_sel;
wire [`REG_BUS] MEM_stor_data;
wire mem_wr;
wire MEM_mem_ena;

//DATA_MEM -> MEM_stage
wire [63 : 0] data;

//mem_wb -> WB_stage
wire [`REG_BUS] wb_w_data;
wire wb_w_ena;
wire [4 : 0] wb_w_addr;

//WB_stage -> regfile
wire WB_w_ena;
wire [`REG_BUS] WB_w_data;
wire [4 : 0] WB_w_addr;



    IF_stage IF_stage (
    .rst(rst),
    .clk(clk),
    .branch(branch),
    .mux_pc(mux_pc),
    .pc_con(pc_con),
    .pc_id(id_pc),

    .wash(wash),
    .IF_pc(pc),
    .I_M_e(IN_MEM_ENA)
);


    if_id if_id (
    .rst(rst),
    .clk(clk),
    .if_pc(pc),
    .if_instr(instr),
    .pc_con(pc_con),
    .wash(wash),

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
	.r_data2(r_data2)  //OUT2

);

    ID_stage ID_stage (
    .rst(rst),
    .IF_pc(id_pc), 
    .IF_instr(id_instr),

    .reg_data1(r_data1), //
    .reg_data2(r_data2), //

    .reg1_r_ena(reg1_r_ena),
    .reg2_r_ena(reg2_r_ena),

    .reg1_addr(reg1_addr),
    .reg2_addr(reg2_addr),

    .ex_w_data(ex_w_data),    //ex_stage for data
    .ex_w_ena(ex_w_ena),
    .ex_w_addr(ex_w_addr),

    .idex_mem_ena(ex_mem_ena),          //id_ex memory enable
    .idex_mem_wr(ex_mem_wr),


    .mem_w_data(MEM_w_data),   //men_stage for data
    .mem_w_ena(MEM_w_ena),
    .mem_w_addr(MEM_w_addr),

    .aluop(aluop),          //ALUoptions
    .alusel(alusel),

    .reg1_data(reg1_data),  //
    .reg2_data(reg2_data),  //

    .w_addr(w_addr),       
    .w_ena(w_ena),                  //write enable

    .ID_pc(ID_pc),       //pc now
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

    .id_pc(ID_pc),

    .id_aluop(aluop),
    .id_alusel(alusel),
    .id_imm(imm),

    .id_reg1_data(reg1_data),
    .id_reg2_data(reg2_data),

    .id_w_ena(w_ena),
    .id_w_addr(w_addr),

    .id_memop(memop),
    .id_mem_wr(id_mem_wr),
    .id_mem_ena(id_mem_ena),

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

    .ex_pc(ex_pc)
    
); 

    EX_stage EX_stage (
    .rst(rst),

    .ID_pc(ex_pc),//未写

    .id_w_addr(ex_w_addr),
    .id_w_ena(ex_w_ena),

    .id_reg1_data(ex_reg1_data),
    .id_reg2_data(ex_reg2_data),

    .id_aluop(ex_aluop),
    .id_alusel(ex_alusel),
    .id_memop(ex_memop),
    .id_imm(ex_imm),
    .id_mem_wr(ex_mem_wr),
    .id_mem_ena(ex_mem_ena),

    .ex_w_data(ex_w_data),
    .ex_w_ena(EX_w_ena),
    .ex_w_addr(EX_w_addr),

    .ex_memop(EX_memop),
    .ex_mem_addr(ex_mem_addr),
    .ex_stor_data(ex_stor_data),
    .ex_mem_wr(EX_mem_wr),
    .ex_mem_ena(EX_mem_ena),

    .EX_pc(EX_pc) //未写
);

    ex_mem ex_mem (
    .rst(rst),
    .clk(clk),
    .ex_pc(EX_pc),
    .ex_w_data(ex_w_data),
    .ex_w_ena(EX_w_ena),
    .ex_w_addr(EX_w_addr),
    .ex_mem_addr(ex_mem_addr),
    .ex_memop(EX_memop),
    .ex_stor_data(ex_stor_data),
    .ex_mem_wr(EX_mem_wr),
    .ex_mem_ena(EX_mem_ena),

    .mem_w_data(mem_w_data),
    .mem_w_ena(mem_w_ena),
    .mem_w_addr(mem_w_addr),

    .mem_mem_addr(mem_mem_addr),
    .mem_memop(mem_memop),
    .mem_stor_data(mem_stor_data),
    .mem_mem_wr(mem_mem_wr),
    .mem_mem_ena(mem_mem_ena),

    .men_pc() //未连
);

    MEM_stage MEM_stage (
    .rst(rst),
    .ex_w_data(mem_w_data),
    .ex_w_ena(mem_w_ena),
    .ex_w_addr(mem_w_addr),
    .ex_mem_addr(mem_mem_addr),
    .ex_memop(mem_memop),
    .mem_data(data),
    .ex_stor_data(mem_stor_data),
    .ex_mem_wr(mem_mem_wr),
    .ex_mem_ena(mem_mem_ena),

    .mem_w_data(MEM_w_data),
    .mem_w_ena(MEM_w_ena),
    .mem_w_addr(MEM_w_addr),

    .mem_mem_addr(MEM_mem_addr),
    .mem_sel(mem_sel),
    .mem_stor_data(MEM_stor_data),
    .mem_wr(mem_wr),
    .mem_mem_ena(MEM_mem_ena)
);

    DATA_MEN DATA_MEN (
    .clk(clk),
    .addr(MEM_mem_addr),
    .w_data(MEM_stor_data),
    .sel(mem_sel),
    .ena(MEM_mem_ena),
    .w_r(mem_wr),

    .data(data)
);

    mem_wb mem_wb (
    .clk(clk),
    .rst(rst),
    .mem_w_data(MEM_w_data),
    .mem_w_ena(MEM_w_ena),
    .mem_w_addr(MEM_w_addr),

    .wb_w_data(wb_w_data),
    .wb_w_ena(wb_w_ena),
    .wb_w_addr(wb_w_addr)
);

WB_stage WB_stage (
    .rst(rst),
    .mem_w_ena(wb_w_ena),
    .mem_w_data(wb_w_data),
    .mem_w_addr(wb_w_addr),

    .wb_w_ena(WB_w_ena),
    .wb_w_data(WB_w_data),
    .wb_w_addr(WB_w_addr)
);


endmodule