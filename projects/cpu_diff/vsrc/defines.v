
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
`define No 3'b000
`define Logic  3'b001
`define Arith  3'b010
`define Jump  3'b100
`define Load  3'b011
`define Store  3'b101
`define Long  3'b110
`define Short  3'b111

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
