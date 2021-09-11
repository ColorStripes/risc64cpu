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
    input wire [2 : 0] id_alusel,

    output reg [`REG_BUS] ex_w_data,
    output reg ex_w_ena,
    output reg [4 : 0] ex_w_addr,

    output reg [`REG_BUS] ex_mem_raddr,
    output reg [`REG_BUS] ex_mem_waddr,
    output reg [`REG_BUS] ex_stor_data,
    output reg [4 : 0] ex_memop,
    output reg ex_mem_wr,
    output reg ex_mem_ena,

    output wire [`INST_BUS] EX_instr,
    output wire [`PC_BUS] EX_pc
);
    wire [`REG_BUS] result;
    assign EX_pc = ID_pc;
    assign EX_instr = ID_instr;

ALU ALU(
    .num1(id_reg1_data),
    .num2(id_reg2_data),
    .op(id_aluop),
    
    .out(result)
);
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
        end
        else begin
            ex_w_ena = id_w_ena;
            ex_w_addr = id_w_addr;
            ex_w_data = `ZERO_WORD;
            ex_mem_raddr = `ZERO_WORD;
            ex_mem_waddr = `ZERO_WORD;
            ex_stor_data = `ZERO_WORD;
            ex_mem_wr = 1'b0;
            ex_mem_ena = 1'b0;
            ex_memop = id_memop;
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
                      ex_mem_ena = id_mem_ena;
                  end
                  `Store:begin
                      ex_mem_waddr = id_reg1_data + id_imm;
                      ex_stor_data = id_reg2_data;
                      ex_mem_wr = id_mem_wr;
                      ex_mem_ena = id_mem_ena;
                  end
                  `Long:begin
                      ex_w_data = ID_pc + result;
                  end
                  `Short:begin
                      ex_w_data = {{32{result[31]}}, result[31 : 0]};
                  end
                  `No:begin
                      $fwrite("%c",result);
                  end
                  default: begin
                      ex_w_data = `ZERO_WORD;
                      ex_mem_waddr = `ZERO_WORD;
                      ex_mem_raddr = `ZERO_WORD;
                      ex_stor_data = `ZERO_WORD;
                  end
            endcase
        end
    end
endmodule