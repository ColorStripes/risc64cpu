
`timescale 1ns / 1ps

`define ZERO_WORD  64'h00000000_00000000
`define ZERO_INST  32'h00000000    
`define REG_BUS    63 : 0  
`define DATA_BUS   7 : 0  
`define PC_BUS     63 : 0 
`define INST_BUS   31 : 0 
`define ZERO_ENA   1'b0
`define ZERO_REG_ADDR   5'b00000

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


//ROM
`define ROM_NUM  1024
`define ROM_NUMLOG  10

//DTAT_MEM
`define D_NUM  1024
`define D_NUMLOG  10

//forecase
`define FORECASE 4
`define FORECASE_LOG 2
`define PC 4
`define PC_LOG 2

//difftest
`define PC_START   64'h00000000_80000000 
`define RISCV_PRIV_MODE_U   0
`define RISCV_PRIV_MODE_S   1
`define RISCV_PRIV_MODE_M   3




//CSR



//CSR_ADDR
`define mvendorid 12'hf11    //MRO
`define marchid 12'hf12
`define mimpid 12'hf13
`define mhartid 12'hf14

`define mstatus 12'h300
`define misa 12'h301
`define medeleg 12'h302
`define mideleg 12'h303
`define mie 12'h304
`define mtvec 12'h305
`define mcounteren 12'h306
`define mscratch 12'h340
`define mepc 12'h341
`define mcause 12'h342
`define mtval 12'h343
`define mip 12'h344
`define mcycle 12'hb00
`define minstret 12'hb02
`define mcycleh 12'hb80         //32
`define minstreth 12'hb82       //32
`define mcountinhibit 12'h320
`define tselect 12'h7a0
`define tdata1 12'h7a1
`define tdata2 12'h7a2
`define tdata3 12'h7a3


//Clint
`define msip 64'h2000000
`define mtimecmp 64'h2004000
`define mtime 64'h200bff8
`define TIME 64'd60000
