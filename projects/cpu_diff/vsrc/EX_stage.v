//2021.8.4
//xu xin
`include "defines.v"

module EX_stage (
    input wire rst,

    input wire [`PC_BUS] ID_pc,//未写
    input wire [`INST_BUS] ID_instr,

    input wire [4 : 0] id_w_addr,
    input wire id_w_ena,

    input wire [`REG_BUS] id_reg1_data,
    input wire [`REG_BUS] id_reg2_data,
    input wire [`REG_BUS] id_imm,

    input wire [4 : 0] id_memop,
    input wire id_mem_wr,
    input wire id_mem_ena,
    input wire [6 : 0] id_aluop,
    input wire [3 : 0] id_alusel,

    input wire [`REG_BUS] csr_reg_data,     //csr
    input wire id_csr_ena,
    
    input wire[11 : 0] mem_csr_addr,        //qian di
    input wire [`REG_BUS] mem_w_csr_data,
    input wire mem_csr_ena,
    input wire [11 : 0] wb_csr_addr,
    input wire [`REG_BUS] wb_w_csr_data,
    input wire wb_csr_ena,

    output reg [`REG_BUS] ex_w_data,
    output reg ex_w_ena,
    output reg [4 : 0] ex_w_addr,

    output reg [`REG_BUS] ex_mem_raddr,
    output reg [`REG_BUS] ex_mem_waddr,
    output reg [`REG_BUS] ex_stor_data,
    output reg [4 : 0] ex_memop,
    output reg ex_mem_wr,
    output reg ex_mem_ena,

    output reg [11 : 0] ex_csr_addr,         ///csr o
    output reg [`REG_BUS] ex_w_csr_data,
    output reg ex_csr_ena, 

    output wire [`INST_BUS] EX_instr,
    output wire [`PC_BUS] EX_pc,

    output wire [`REG_BUS] except_type
);
    wire [`REG_BUS] result;
    assign EX_pc = ID_pc;
    assign EX_instr = ID_instr;

    reg mret;
    reg ebreak;
    reg ecall;
    assign except_type = {45'b0, mret, ebreak, ecall, 16'b0};

ALU ALU(
    .num1(id_reg1_data),
    .num2(id_reg2_data),
    .op(id_aluop),
    
    .out(result)
);
    reg [`REG_BUS] csr_data;
    always @(*) begin
        if(rst == 1'b1) begin
            csr_data =`ZERO_WORD;
        end
        else begin
            csr_data =`ZERO_WORD;
            if(ex_csr_ena == 1'b1) begin
                if((mem_csr_ena == 1'b1) && (ex_csr_addr == mem_csr_addr)) begin
                    csr_data = mem_w_csr_data;
                end
                else if((wb_csr_ena == 1'b1) && (ex_csr_addr == wb_csr_addr)) begin
                    csr_data = wb_w_csr_data;
                end
                else begin
                    csr_data = csr_reg_data;
                end
            end
        end
    end

 
    always @(*) begin
        if(rst == 1'b1) begin
            ex_w_data = `ZERO_WORD;
            ex_w_ena = 1'b0;
            ex_w_addr = `ZERO_REG_ADDR;
            ex_stor_data = `ZERO_WORD;
            ex_mem_wr = 1'b0;
            ex_mem_ena = 1'b0;
            ex_mem_raddr = `ZERO_WORD;
            ex_mem_waddr = `ZERO_WORD;
            ex_memop = 5'h00;
            ex_csr_ena = 1'b0;
            ex_csr_addr = 12'h000;
            ex_w_csr_data = `ZERO_WORD;
            mret = 1'b0;
            ebreak = 1'b0;
            ecall = 1'b0;

        end
        else begin
            ex_w_ena = id_w_ena;
            ex_w_addr = id_w_addr;
            ex_w_data = `ZERO_WORD;
            ex_mem_raddr = `ZERO_WORD;
            ex_mem_waddr = `ZERO_WORD;
            ex_stor_data = `ZERO_WORD;
            ex_mem_wr = 1'b0;
            ex_mem_ena = id_mem_ena;
            ex_memop = id_memop;
            ex_csr_ena = id_csr_ena;
            ex_csr_addr = 12'h000;
            ex_w_csr_data = `ZERO_WORD;
            mret = 1'b0;
            ebreak = 1'b0;
            ecall = 1'b0;

            case (id_alusel)
                  `Logic:begin
                      if(result == 64'h0000_0000_0000_0001) begin  
                           ex_w_data = 64'h0000_0000_0000_0001;
                      end
                      else begin
                           ex_w_data = 64'h00000000_00000000;
                      end           
                  end 
                  `Arith:begin
                      ex_w_data = result;
                  end
                  `Jump:begin
                      ex_w_data = ID_pc + 4;
                  end
                  `Load:begin
                      ex_mem_raddr = result;
                      ex_mem_wr = id_mem_wr;
                  end
                  `Store:begin
                      ex_mem_waddr = id_reg1_data + id_imm;
                      ex_stor_data = id_reg2_data;
                      ex_mem_wr = id_mem_wr;
                  end
                  `Long:begin
                      ex_w_data = ID_pc + result;
                  end
                  `Short:begin
                      ex_w_data = {{32{result[31]}}, result[31 : 0]};
                  end
                  `CSRRC:begin
                      ex_w_data = csr_data;
                      ex_w_csr_data = csr_data & (~id_reg1_data);
                      ex_csr_addr = id_imm[11 : 0];

                  end
                  `CSRRCI:begin
                      ex_w_data = csr_data;
                      ex_w_csr_data = csr_data & (~{59'b0, ID_instr[19 : 15]});
                      ex_csr_addr = id_imm[11 : 0];

                  end
                  `CSRRS:begin
                      ex_w_data = csr_data;
                      ex_w_csr_data = csr_data | id_reg1_data;
                      ex_csr_addr = id_imm[11 : 0];

                  end
                  `CSRRSI:begin
                      ex_w_data = csr_data;
                      ex_w_csr_data = csr_data | {59'b0, ID_instr[19 : 15]};
                      ex_csr_addr = id_imm[11 : 0];

                  end
                  `CSRRW:begin
                      ex_w_data = csr_data;
                      ex_w_csr_data = id_reg1_data;
                      ex_csr_addr = id_imm[11 : 0];

                  end
                  `CSRRWI:begin
                      ex_w_data = csr_data;
                      ex_w_csr_data = {59'b0, ID_instr[19 : 15]};
                      ex_csr_addr = id_imm[11 : 0];

                  end
                  `SYSTEM:begin
                      ex_w_data = `ZERO_WORD;
                      ex_w_csr_data = `ZERO_WORD;
                      ex_csr_addr = id_imm[11 : 0];
                      ex_csr_ena = 1'b0;
                      mret =  ~id_imm[0] & id_imm[1] & id_imm[8] & id_imm[9];
                      ebreak = id_imm[0] & ~id_imm[1] & ~id_imm[8] & ~id_imm[9];
                      ecall = ~id_imm[0] & ~id_imm[1] & ~id_imm[8] & ~id_imm[9];
                  end
                  default: begin
                      ex_w_data = `ZERO_WORD;
                      ex_mem_waddr = `ZERO_WORD;
                      ex_mem_raddr = `ZERO_WORD;
                      ex_stor_data = `ZERO_WORD;
                      ex_w_csr_data = `ZERO_WORD;
                      ex_csr_addr = 12'h000;
                      ex_csr_ena = 1'b0;
            
                  end
            endcase
        end
    end
endmodule