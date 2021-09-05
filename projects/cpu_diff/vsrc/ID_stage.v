//2021.8.4
//xu xin


`include "defines.v"

module ID_stage (
    input wire rst,
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

    output reg reg1_r_ena,
    output reg reg2_r_ena,
    output reg [4 : 0] reg1_addr,
    output reg [4 : 0] reg2_addr,

    output reg [6 : 0] aluop,          //ALUoptions
    output reg [2 : 0] alusel,

    output reg [`REG_BUS] reg1_data,  //
    output reg [`REG_BUS] reg2_data,  //

    output reg [4 : 0] w_addr,       
    output reg w_ena,                  //write enable

    output wire [`PC_BUS] ID_pc,    //pc now
    output wire [`INST_BUS] ID_instr,
    output reg [`PC_BUS] branch,    //pc next
    output reg mux_pc,
    output reg pc_con,

    output reg [4 : 0] memop,
    output wire [63 : 0] imm,
    output reg id_mem_wr,
    output reg id_mem_ena
);
    wire [6 : 0] opcode;
    wire [2 : 0] funct3;
    wire [6 : 0] funct7;
    
    reg [63 : 0] pc;
    
    assign ID_pc = IF_pc;
    assign ID_instr = IF_instr;
    assign opcode = IF_instr[6:0];
    assign funct3 = IF_instr[14 : 12];
    assign funct7 = IF_instr[31 : 25];

    IMGN IMGN (
    .instr(IF_instr),

    .imm(imm)
);

    always @(*) begin                 //ID
        if(rst == 1) begin
            reg1_r_ena = `ZERO_ENA;
            reg2_r_ena = `ZERO_ENA;
            reg1_addr = `ZERO_REG_ADDR;
            reg2_addr = `ZERO_REG_ADDR;
            w_addr = `ZERO_REG_ADDR;
            w_ena = 1'b0;

            aluop = 7'b0000_000;          //ALUoptions
            alusel = 3'b000;

            mux_pc = 1'b0;
            branch = `ZERO_WORD;
            pc = `ZERO_WORD;
            memop = 5'b00000;
            id_mem_wr = 1'b0;
            id_mem_ena = 1'b0;
            pc_con = 1'b0;

        end
        else begin
            reg1_r_ena = `ZERO_ENA;
            reg2_r_ena = `ZERO_ENA;
            reg1_addr = IF_instr[19 : 15];
            reg2_addr = IF_instr[24 : 20];
            w_addr = IF_instr[11 : 7];
            w_ena = 1'b0;

            aluop = 7'b0000_000;          //ALUoptions
            alusel = 3'b000;

            mux_pc = 1'b0;
            branch = IF_pc;
            pc = `ZERO_WORD;

            memop = 5'b00000;
            id_mem_wr = 1'b0;
            id_mem_ena = 1'b0;
            pc_con = 1'b0;

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
                               if(IF_instr[25] == 0) begin
                                   aluop = `SHIL;
                                   alusel = `Arith;
                               end
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
              end
              //jalr
              7'b1100111:begin
                  mux_pc = 1'b1;
                  w_ena = 1'b1;
                  reg1_r_ena = 1'b0;
                  reg2_r_ena = 1'b0;
                  aluop = `NO;
                  alusel = `Jump;
                  pc = reg_data1 + imm;
                  branch = {IF_pc[63 : 1], 1'b0}; 
              end

              //S
              7'b0100011:begin
                    w_ena = 1'b1;
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
              default:begin
                    reg1_r_ena = `ZERO_ENA;
                    reg2_r_ena = `ZERO_ENA;
                    id_mem_ena = 1'b0;
                    w_ena = 1'b0;
              end
        endcase

        if( ((idex_mem_ena == 1'b1) && (idex_mem_wr == 1'b0)) && (ex_w_ena == 1'b1) &&
         ( ((ex_w_addr == reg1_addr) && (ex_w_addr != 5'b00000)) || ((ex_w_addr == reg2_addr) && (ex_w_addr != 5'b00000)) ) ) 
         begin
            id_mem_ena = 1'b0;
            w_ena = 1'b0;
            pc_con = 1'b1;
         end
    end
end

    always @(*) begin
        if(rst == 1'b1) begin
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
        if(rst == 1'b1) begin
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