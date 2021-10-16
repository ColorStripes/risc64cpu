
//2021.8.4
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

//funct3
`define addi 3'b000
`define andi 3'b111
`define xori 3'b100
`define ori 3'b110
`define slti 3'b010
`define sltiu 3'b011
`define slli 3'b001
`define srlisrai 3'b101
`define srlsra 3'b101
`define addiw 3'b000
`define slliw 3'b001
`define sllw 3'b001
`define srliwsraiw 3'b101
`define srlwsraw 3'b101

`define lb 3'b000
`define lbu 3'b100
`define ld 3'b011
`define lh 3'b001
`define lhu 3'b101
`define lw 3'b010
`define lwu 3'b110

`define sb 3'b000
`define sh 3'b001
`define sw 3'b010
`define sd 3'b011


`define addsub 3'b000
`define addwsubw 3'b000
`define and 3'b111
`define xor 3'b100
`define or 3'b110
`define slt 3'b010
`define sltu 3'b011
`define sll 3'b001

`define beq 3'b000
`define bge 3'b101
`define bgeu 3'b111
`define blt 3'b100
`define bltu 3'b110
`define bne 3'b001

`define system 3'b000
`define csrrw 3'b001
`define csrrs 3'b010
`define csrrc 3'b011
`define csrrwi 3'b101
`define csrrsi 3'b110
`define csrrci 3'b111

`define fence 3'b000
`define fencei 3'b001

//funct7
`define add 7'b0000000
`define sub 7'b0100000
`define addw 7'b0000000
`define subw 7'b0100000
`define srl 7'b0000000
`define sra 7'b0100000
`define srlw 7'b0000000
`define sraw 7'b0100000
`define srli 6'b000000
`define srai 6'b010000
`define srliw 6'b000000
`define sraiw 6'b010000
`define mret 12'b001100000010
`define ebreak 12'b000000000001
`define ecall 12'b000000000000

//ALUOP
`define NO 7'b0000_000
`define ADD 7'b0000_001
`define SUB 7'b0000_010
`define AND 7'b0000_100
`define XOR 7'b0010_000
`define OR 7'b0001_000
`define COMu 7'b0000_011
`define COM 7'b0000_110
`define SHIL 7'b0001_100
`define SHIR 7'b0011_000
`define SRA 7'b0110_000
`define LEFT12 7'b1100_000
`define SHILw 7'b0001_101
`define SRAw 7'b0110_001
`define SHIRw 7'b0011_001

//ALUSEL
`define No 4'b0000
`define Logic  4'b0001
`define Arith  4'b0010
`define Jump  4'b0100
`define Load  4'b0011
`define Store  4'b0101
`define Long  4'b0110
`define Short  4'b0111
`define CSRRC  4'b1001
`define CSRRCI 4'b1010
`define CSRRS  4'b1011
`define CSRRSI  4'b1100
`define CSRRW  4'b1101
`define CSRRWI  4'b1110
`define SYSTEM  4'b1111

//MEMOP
`define R_ONE  5'b00001
`define R_ONEu  5'b00010
`define R_DOU  5'b00011
`define R_DOUu  5'b00100
`define R_FOR  5'b00101
`define R_FORu  5'b00110
`define R_EIG  5'b00111

`define W_ONE  5'b01000
`define W_DOU  5'b01001
`define W_FOR 5'b01010
`define W_EIG 5'b01011


module ysyx_210457_ID_stage (
    input wire reset,
    input wire [`PC_BUS] IF_pc, 
    input wire [`INST_BUS] IF_instr,

    input wire [`REG_BUS] reg_data1, //
    input wire [`REG_BUS] reg_data2, //

    input wire [`REG_BUS] ex_w_data,    //ex_stage for data
    input wire ex_w_ena,
    input wire [4 : 0] ex_w_addr,

    input wire [`REG_BUS] mem_w_data,   //men_stage for data
    input wire mem_w_ena,
    input wire [4 : 0] mem_w_addr,

    input wire idex_mem_ena,          //id_ex memory enable
    input wire idex_mem_wr,

    
    input wire [`PC_BUS] if_branch,

    output reg error_branch,

    output reg reg1_r_ena,
    output reg reg2_r_ena,
    output reg [4 : 0] reg1_addr,
    output reg [4 : 0] reg2_addr,

    output reg [6 : 0] aluop,          //ALUoptions
    output reg [3 : 0] alusel,

    output reg [`REG_BUS] reg1_data,  //
    output reg [`REG_BUS] reg2_data,  //

    output reg [4 : 0] w_addr,       
    output reg w_ena,                  //write enable

    output wire [`PC_BUS] ID_pc,    //pc now
    output wire [`INST_BUS] ID_instr,
    output reg [`PC_BUS] branch,    //pc next
    output reg mux_pc,
    output reg pc_con,
    output wire [63 : 0] imm,

    output reg [4 : 0] memop,
    output reg id_mem_wr,
    output reg id_mem_ena,

    output reg id_csr_ena           //csr_ena

);
    wire [6 : 0] opcode;
    wire [2 : 0] funct3;
    wire [6 : 0] funct7;
    
    
    assign ID_pc = IF_pc;
    assign ID_instr = IF_instr;
    assign opcode = IF_instr[6:0];
    assign funct3 = IF_instr[14 : 12];
    assign funct7 = IF_instr[31 : 25];


    ysyx_210457_IMGN IMGN (
    .instr(IF_instr),

    .imm(imm)
);

    always @(*) begin                 //ID
        if(reset == 1) begin
            reg1_r_ena = `ZERO_ENA;
            reg2_r_ena = `ZERO_ENA;
            reg1_addr = `ZERO_REG_ADDR;
            reg2_addr = `ZERO_REG_ADDR;
            w_addr = `ZERO_REG_ADDR;
            w_ena = 1'b0;

            aluop = 7'b0000_000;          //ALUoptions
            alusel = 4'b0000;

            mux_pc = 1'b0;
            branch = `ZERO_WORD;
            memop = 5'b00000;
            id_mem_wr = 1'b0;
            id_mem_ena = 1'b0;
            pc_con = 1'b0;
            id_csr_ena = 1'b0;

        end
        else begin
            reg1_r_ena = `ZERO_ENA;
            reg2_r_ena = `ZERO_ENA;
            reg1_addr = IF_instr[19 : 15];
            reg2_addr = IF_instr[24 : 20];
            w_addr = IF_instr[11 : 7];
            w_ena = 1'b0;

            aluop = 7'b0000_000;          //ALUoptions
            alusel = 4'b0000;

            mux_pc = 1'b0;
            branch = IF_pc;

            memop = 5'b00000;
            id_mem_wr = 1'b0;
            id_mem_ena = 1'b0;
            pc_con = 1'b0;
            id_csr_ena = 1'b0;

            error_branch = 1'b0;

        case (opcode)
            //I
            7'b0010011:begin
                    w_ena = 1'b1;
                    reg1_r_ena = 1'b1;
                    reg2_r_ena = 1'b0;
                    
                    case (funct3) 
                          `addi:begin
                                aluop = `ADD;
                                alusel = `Arith;
                           end
                          `andi:begin
                                aluop = `AND;
                                alusel = `Arith;
                           end
                           `xori:begin
                                aluop = `XOR;
                                alusel = `Arith;
                           end
                           `ori:begin
                                aluop = `OR;
                                alusel = `Arith;
                           end
                           `slti:begin
                                aluop = `COM;
                                alusel = `Logic;
                           end
                           `sltiu:begin
                                aluop = `COMu;
                                alusel = `Logic;
                           end
                           `slli:begin
                                aluop = `SHIL;
                                alusel = `Arith;
                           end
                           `srlisrai:begin
                                alusel = `Arith;
                            case (funct7[6 : 1])
                                `srli:begin
                                 aluop = `SHIR;
                                end
                                `srai:begin
                                 aluop = `SRA;
                                end
                                default:begin
                                 reg1_r_ena = `ZERO_ENA;
                                 reg2_r_ena = `ZERO_ENA;
                                 id_mem_ena = 1'b0;
                                 w_ena = 1'b0;
                                 id_mem_wr = 1'b0;
                                end
                            endcase        
                           end
                    endcase
              end
              //addiw
              7'b0011011:begin
                  case(funct3)
                       `addiw:begin
                           w_ena = 1'b1;
                           reg1_r_ena = 1'b1;
                           reg2_r_ena = 1'b0;
                           aluop = `ADD;
                           alusel = `Short; 
                        end
                        `slliw:begin
                            if(IF_instr[25] == 0) begin
                                 w_ena = 1'b1;
                                 reg1_r_ena = 1'b1;
                                 reg2_r_ena = 1'b0;
                                 aluop = `SHIL;
                                 alusel = `Short;
                            end  
                        end
                        `srliwsraiw:begin
                            case(funct7[6 : 1])
                                 `sraiw:begin
                                     if(IF_instr[25] == 0) begin
                                         w_ena = 1'b1;
                                         reg1_r_ena = 1'b1;
                                         reg2_r_ena = 1'b0;
                                         aluop = `SRAw;
                                         alusel = `Short;
                                     end  
                                 end
                                 `srliw:begin
                                      if(IF_instr[25] == 0) begin
                                        w_ena = 1'b1;
                                        reg1_r_ena = 1'b1;
                                        reg2_r_ena = 1'b0;
                                        aluop = `SHIRw;
                                        alusel = `Short;
                                      end  
                                 end
                                 default:begin
                                      reg1_r_ena = `ZERO_ENA;
                                      reg2_r_ena = `ZERO_ENA;
                                      id_mem_ena = 1'b0;
                                      w_ena = 1'b0;
                                 end
                            endcase
                        end
                        default:begin
                            reg1_r_ena = `ZERO_ENA;
                            reg2_r_ena = `ZERO_ENA;
                            id_mem_ena = 1'b0;
                            w_ena = 1'b0;
                        end
                  endcase
              end
              //addw
              7'b0111011:begin
                  case (funct3)
                        `addwsubw:begin
                            case (funct7)
                                  `addw:begin
                                         w_ena = 1'b1;
                                         reg1_r_ena = 1'b1;
                                         reg2_r_ena = 1'b1;
                                         aluop = `ADD;
                                         alusel = `Short;
                                  end 
                                  `subw:begin
                                         w_ena = 1'b1;
                                         reg1_r_ena = 1'b1;
                                         reg2_r_ena = 1'b1;
                                         aluop = `SUB;
                                         alusel = `Short;
                                  end
                                  default:begin
                                         w_ena = 1'b0;
                                         reg1_r_ena = 1'b0;
                                         reg2_r_ena = 1'b0;
                                         aluop = `NO;
                                         alusel = `No;
                                  end  
                            endcase
                        end
                        
                        `srlwsraw:begin
                            case(funct7)
                                 `sraw:begin
                                       w_ena = 1'b1;
                                       reg1_r_ena = 1'b1;
                                       reg2_r_ena = 1'b1;
                                       aluop = `SRAw;
                                       alusel = `Short; 
                                 end
                                 `srlw:begin
                                       w_ena = 1'b1;
                                       reg1_r_ena = 1'b1;
                                       reg2_r_ena = 1'b1;
                                       aluop = `SHIRw;
                                       alusel = `Short;  
                                 end
                                 default:begin
                                    w_ena = 1'b0;
                                    reg1_r_ena = 1'b0;
                                    reg2_r_ena = 1'b0;
                                    aluop = `NO;
                                    alusel = `No; 
                                 end
                            endcase
                        end

                        `sllw:begin
                              w_ena = 1'b1;
                              reg1_r_ena = 1'b1;
                              reg2_r_ena = 1'b1;
                              aluop = `SHILw;
                              alusel = `Short;
                        end

                        default:begin
                                 reg1_r_ena = `ZERO_ENA;
                                 reg2_r_ena = `ZERO_ENA;
                                 id_mem_ena = 1'b0;
                                 w_ena = 1'b0;
                        end
                  endcase
              end

              //I-L
              7'b0000011:begin
                    w_ena = 1'b1;
                    reg1_r_ena = 1'b1;
                    reg2_r_ena = 1'b0;
                    id_mem_wr = 1'b0;
                    id_mem_ena = 1'b1;
                    case(funct3)
                         `lb:begin
                             alusel = `Load;
                             aluop = `ADD;
                             memop = `R_ONE;
                         end
                         `lbu:begin
                             alusel = `Load;
                             aluop = `ADD;
                             memop = `R_ONEu;
                         end
                         `ld:begin
                             alusel = `Load;
                             aluop = `ADD;
                             memop = `R_EIG;
                         end
                         `lh:begin
                             alusel = `Load;
                             aluop = `ADD;
                             memop = `R_DOU;
                         end
                         `lhu:begin
                             alusel = `Load;
                             aluop = `ADD;
                             memop = `R_DOUu;
                         end
                         `lw:begin
                             alusel = `Load;
                             aluop = `ADD;
                             memop = `R_FOR;
                         end
                         `lwu:begin
                             alusel = `Load;
                             aluop = `ADD;
                             memop = `R_FORu;
                         end
                         default:begin
                             w_ena = 1'b0;
                             reg1_r_ena = 1'b0;
                             reg2_r_ena = 1'b0;
                             id_mem_wr = 1'b0;
                             id_mem_ena = 1'b0;
                             alusel = `No;
                             aluop = `NO;
                         end
                    endcase
              end


              //R
              7'b0110011:begin
                    w_ena = 1'b1;
                    reg1_r_ena = 1'b1;
                    reg2_r_ena = 1'b1;

                    case(funct3)
                         `addsub:begin
                             alusel = `Arith;
                             case(funct7)
                                  `add:begin
                                      aluop = `ADD;
                                  end
                                  `sub:begin
                                      aluop = `SUB;
                                  end
                                  default:begin
                                      reg1_r_ena = `ZERO_ENA;
                                      reg2_r_ena = `ZERO_ENA;
                                      id_mem_ena = 1'b0;
                                      w_ena = 1'b0;
                                  end
                             endcase
                         end
                         `or:begin
                             aluop = `OR;
                             alusel = `Arith;
                         end
                         `xor:begin
                             aluop = `XOR;
                             alusel = `Arith;
                         end
                         `and:begin
                             aluop = `AND;
                             alusel = `Arith;
                         end
                         `slt:begin
                             aluop = `COM;
                             alusel = `Logic;
                         end
                         `sltu:begin
                             aluop = `COMu;
                             alusel = `Logic;
                         end
                         `sll:begin
                             aluop = `SHIL;
                             alusel = `Arith;  
                         end
                         `srlsra:begin
                            alusel = `Arith;
                            case (funct7)
                                `srl:begin
                                 aluop = `SHIR;
                                end
                                `sra:begin
                                 aluop = `SRA;
                                end
                                default:begin
                                 reg1_r_ena = `ZERO_ENA;
                                 reg2_r_ena = `ZERO_ENA;
                                 id_mem_ena = 1'b0;
                                 w_ena = 1'b0;
                                end
                            endcase        
                         end
                         default:begin
                                 reg1_r_ena = `ZERO_ENA;
                                 reg2_r_ena = `ZERO_ENA;
                                 id_mem_ena = 1'b0;
                                 w_ena = 1'b0;
                         end
                    endcase
              end

              //B
              7'b1100011:begin
                    w_ena = 1'b0;
                    reg1_r_ena = 1'b1;
                    reg2_r_ena = 1'b1;
                    branch = IF_pc + imm ;
                    case(funct3)
                         `beq:begin
                             aluop = `SUB;
                             alusel = `Jump;
                             if(reg1_data == reg2_data) begin
                                 mux_pc = 1'b1; 
                             end
                         end
                         `bge:begin
                             aluop = `SUB;
                             alusel = `Jump;
                             if(reg1_data[63] == reg2_data[63]) begin
                                 if(reg1_data >= reg2_data) begin
                                     mux_pc = 1'b1; 
                                     end
                             end
                             else begin
                                 if(reg1_data[63] < reg2_data[63]) begin
                                     mux_pc = 1'b1;
                                 end
                             end  
                         end
                         `bgeu:begin
                             aluop = `SUB;
                             alusel = `Jump;
                             if(reg1_data >= reg2_data) begin
                                 mux_pc = 1'b1; 
                             end
                         end
                         `blt:begin
                             aluop = `SUB;
                             alusel = `Jump;
                             if(reg1_data[63] == reg2_data[63]) begin
                                 if(reg1_data < reg2_data) begin
                                     mux_pc = 1'b1; 
                                     end
                             end
                             else begin
                                 if(reg1_data[63] > reg2_data[63]) begin
                                     mux_pc = 1'b1;
                                 end
                             end  
                         end
                         `bltu:begin
                             aluop = `SUB;
                             alusel = `Jump;
                             if(reg1_data < reg2_data) begin
                                 mux_pc = 1'b1; 
                             end
                         end
                         `bne:begin
                             aluop = `SUB;
                             alusel = `Jump;
                             if(reg1_data != reg2_data) begin
                                 mux_pc = 1'b1; 
                             end
                         end
                         default:begin
                                 reg1_r_ena = `ZERO_ENA;
                                 reg2_r_ena = `ZERO_ENA;
                                 id_mem_ena = 1'b0;
                                 w_ena = 1'b0;
                         end
                    endcase
                    if((if_branch != branch) && (mux_pc)) begin
                        error_branch = 1'b1;
                    end
                    
              end
              
              //jal
              7'b1101111:begin
                  w_ena = 1'b1;
                  reg1_r_ena = 1'b0;
                  reg2_r_ena = 1'b0;
                  aluop = `NO;
                  alusel = `Jump;
                  branch = IF_pc + imm;
                  mux_pc = 1'b1;
                  if((if_branch != branch) && (mux_pc)) begin
                        error_branch = 1'b1;
                  end
              end

              //jalr
              7'b1100111:begin
                  mux_pc = 1'b1;
                  w_ena = 1'b1;
                  reg1_r_ena = 1'b1;
                  reg2_r_ena = 1'b0;
                  aluop = `NO;
                  alusel = `Jump;
                  branch = ((reg1_data + imm) & 64'hffff_ffff_ffff_fffe);
                  if((if_branch != branch) && (mux_pc)) begin
                        error_branch = 1'b1;
                  end
              end

              //S
              7'b0100011:begin
                    w_ena = 1'b0;
                    reg1_r_ena = 1'b1;
                    reg2_r_ena = 1'b1;
                    id_mem_wr = 1'b1;
                    id_mem_ena = 1'b1;
                    case (funct3)
                        `sb:begin
                            aluop = `NO;
                            alusel = `Store;
                            memop = `W_ONE;
                        end
                        `sd:begin
                            aluop = `NO;
                            alusel = `Store;
                            memop = `W_EIG;
                        end
                        `sh:begin
                            aluop = `NO;
                            alusel = `Store;
                            memop = `W_DOU;
                        end
                        `sw:begin
                            aluop = `NO;
                            alusel = `Store;
                            memop = `W_FOR;
                        end
                        default:begin
                            reg1_r_ena = `ZERO_ENA;
                            reg2_r_ena = `ZERO_ENA;
                            id_mem_ena = 1'b0;
                            w_ena = 1'b0;
                        end
                    endcase
              end

              //lui
              7'b0110111:begin
                    w_ena = 1'b1;
                    reg1_r_ena = 1'b0;
                    reg2_r_ena = 1'b0;
                    aluop = `LEFT12;
                    alusel = `Arith;
              end

              //auipc
              7'b0010111:begin
                    w_ena = 1'b1;
                    reg1_r_ena = 1'b0;
                    reg2_r_ena = 1'b0;
                    aluop = `LEFT12;
                    alusel = `Long;
              end


              //CSR
              7'b1110011:begin
                  id_csr_ena = 1'b1;
                  w_ena = 1'b1;
                  case(funct3)
                       `csrrw:begin
                           aluop = `NO;
                           alusel = `CSRRW;
                           reg1_r_ena = 1'b1;
                           reg2_r_ena = 1'b0;
                       end
                       `csrrs:begin
                           aluop = `NO;
                           alusel = `CSRRS;
                           reg1_r_ena = 1'b1;
                           reg2_r_ena = 1'b0;
                       end
                       `csrrc:begin
                           aluop = `NO;
                           alusel = `CSRRC;
                           reg1_r_ena = 1'b1;
                           reg2_r_ena = 1'b0;
                       end
                       `csrrwi:begin
                           aluop = `NO;
                           alusel = `CSRRWI;
                           reg1_r_ena = 1'b0;
                           reg2_r_ena = 1'b0;
                       end
                       `csrrsi:begin
                           aluop = `NO;
                           alusel = `CSRRSI;
                           reg1_r_ena = 1'b0;
                           reg2_r_ena = 1'b0;
                       end
                       `csrrci:begin
                           aluop = `NO;
                           alusel = `CSRRCI;
                           reg1_r_ena = 1'b0;
                           reg2_r_ena = 1'b0;
                       end
                       `system:begin
                           case(IF_instr[31 : 20])
                                `mret:begin
                                   aluop = `NO;
                                   alusel = `SYSTEM;
                                   reg1_r_ena = 1'b0;
                                   reg2_r_ena = 1'b0;
                                   w_ena = 1'b0; 
                                end
                                `ebreak:begin
                                   aluop = `NO;
                                   alusel = `SYSTEM;
                                   reg1_r_ena = 1'b0;
                                   reg2_r_ena = 1'b0;
                                   w_ena = 1'b0;
                                end
                                `ecall:begin
                                   aluop = `NO;
                                   alusel = `SYSTEM;
                                   reg1_r_ena = 1'b0;
                                   reg2_r_ena = 1'b0;
                                   w_ena = 1'b0;
                                end
                                default:begin
                                   aluop = `NO;
                                   alusel = `No;
                                   reg1_r_ena = 1'b0;
                                   reg2_r_ena = 1'b0;
                                   w_ena = 1'b0;
                                   id_csr_ena = 1'b0;
                                end
                           endcase
                       end

                       default:begin
                           aluop = `NO;
                           alusel = `No;
                           reg1_r_ena = 1'b0;
                           reg2_r_ena = 1'b0;
                           id_csr_ena = 1'b0;
                       end
                  endcase
              end

              //fence
              7'b0001111:begin
                    id_mem_ena = 1'b0;
                    w_ena = 1'b0;
                    id_csr_ena = 1'b0;
                    aluop = `NO;
                    alusel = `No;
                    reg1_r_ena = 1'b0;
                    reg2_r_ena = 1'b0;
                    case(funct3) 
                        `fence:begin
                      
                        end
                        `fencei:begin
                      
                        end
                        default:begin
                            
                        end
                    endcase
              end
              
              default:begin
                    reg1_r_ena = `ZERO_ENA;
                    reg2_r_ena = `ZERO_ENA;
                    id_mem_ena = 1'b0;
                    w_ena = 1'b0;
                    id_csr_ena = 1'b0;
              end
        endcase

        if( ((idex_mem_ena == 1'b1) && (idex_mem_wr == 1'b0)) && (ex_w_ena == 1'b1) &&
         ( ((ex_w_addr == reg1_addr) && (ex_w_addr != 5'b00000)) || ((ex_w_addr == reg2_addr) && (ex_w_addr != 5'b00000)) ) ) 
         begin
            id_mem_ena = 1'b0;
            w_ena = 1'b0;
            pc_con = 1'b1;
            id_mem_wr = 1'b0;
            id_csr_ena = 1'b0;
            ID_pc = `PC_START;      //difftest
            ID_instr = `ZERO_INST;  //difftest
         end
    end
end

    always @(*) begin
        if(reset == 1'b1) begin
            reg1_data = `ZERO_WORD;
        end
        else if(reg1_r_ena == 1'b1) begin
            if((ex_w_ena == 1'b1) && (ex_w_addr == reg1_addr) && (ex_w_addr != 5'b00000)) begin
                reg1_data = ex_w_data;
            end
            else if((mem_w_ena == 1'b1) && (mem_w_addr == reg1_addr) && (mem_w_addr != 5'b00000)) begin
                reg1_data = mem_w_data;
            end
            else begin
                reg1_data = reg_data1;
            end
        end
        else if(reg1_r_ena == 1'b0) begin
            reg1_data = imm;
        end
        else begin
            reg1_data = `ZERO_WORD;
        end
    end

    always @(*) begin
        if(reset == 1'b1) begin
            reg2_data = `ZERO_WORD;
        end
        else if(reg2_r_ena == 1'b1) begin
            if((ex_w_ena == 1'b1) && (ex_w_addr == reg2_addr) && (ex_w_addr != 5'b00000)) begin
                reg2_data = ex_w_data;
            end
            else if((mem_w_ena == 1'b1) && (mem_w_addr == reg2_addr) && (mem_w_addr != 5'b00000)) begin
                reg2_data = mem_w_data;
            end
            else begin
                reg2_data = reg_data2;
            end
        end
        else if(reg2_r_ena == 1'b0) begin
            reg2_data = imm;
        end
        else begin
            reg2_data = `ZERO_WORD;
        end
    end

endmodule