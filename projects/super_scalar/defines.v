`timescale 1ns / 1ps

//CACHE
`define CACHE_LINE 127 : 0

`define ALU        6
`define ALU_BUS    5 : 0
`define REG        32
`define MEM        64
`define ZERO_NUM   64'h00000000_00000000
`define ZERO_PC    64'h00000000_80000000
`define NONE_INST  32'h00000000
`define ZERO_PRF   6'b000000
`define ZERO_CSR   12'b0000_0000_0000
`define PC_BUS     63 : 0
`define DATA_BUS   63 : 0
`define MEM_BUS    63 : 0
`define INST_BUS   31 : 0
`define PRF_BUS     5 : 0
`define REG_BUS     4 : 0
`define CSR_BUS    11 : 0
`define N_ENA        1'b0
`define ENA          1'b1
`define READ         1'b0 

//ALUOP
`define NO      6'b000000
`define ADD     6'b000001
`define SUB     6'b000010
`define AND     6'b000011
`define XOR     6'b000100
`define OR      6'b000101
`define COM     6'b000110
`define COMU    6'b000111
`define SHIL    6'b001000
`define SHIR    6'b001001
`define SRA     6'b001010
`define SHILW   6'b001011
`define SRAW    6'b001100
`define SHIRW   6'b001101
`define PC      6'b001110
`define SORT    6'b001111
`define JUMP    6'b010000
`define REMW    6'b010001
`define REMUW   6'b010010
`define REMU    6'b010011
`define REM     6'b010100
`define MUL     6'b010101
`define MULH    6'b010110
`define MULHSU  6'b010111
`define MULHU   6'b011000
`define MULW    6'b011001
`define DIV     6'b011010
`define DIVU    6'b011011
`define DIVUW   6'b011100
`define DIVW    6'b011101
`define ANOR    6'b011110
`define NUM1    6'b011111


//EXOP
`define EX_BUS  2 : 0
`define No      3'b000
`define Arith   3'b111
`define Short   3'b110
`define Stort   3'b101
`define Load    3'b100
`define System  3'b011
`define Lui     3'b010
`define Csr     3'b001

//MEMROP
`define MNO     3'b000
`define R_ONE   3'b001
`define R_ONEU  3'b010
`define R_DOU   3'b011
`define R_DOUU  3'b100
`define R_FOR   3'b101
`define R_FORU  3'b110
`define R_EIG   3'b111

//MEMWOP
`define MNO   3'b000
`define W_ONE   3'b001
`define W_DOU   3'b011
`define W_FOR   3'b101
`define W_EIG   3'b111

//MEMOP
`define SIZE_B    2'b00
`define SIZE_H    2'b01
`define SIZE_W    2'b10
`define SIZE_D    2'b11


//TYPE
`define It     3'b111
`define St     3'b110
`define Bt     3'b101
`define Jt     3'b100
`define Ut     3'b011
`define Rt     3'b010
`define Ct     3'b001


//R
`define add    17'b0000000_000_0110011
`define addw   17'b0000000_000_0111011
`define and    17'b0000000_111_0110011
`define sll    17'b0000000_001_0110011
`define sllw   17'b0000000_001_0111011
`define slt    17'b0000000_010_0110011
`define sltu   17'b0000000_011_0110011
`define sra    17'b0100000_101_0110011
`define sraw   17'b0100000_101_0111011
`define srl    17'b0000000_101_0110011
`define srlw   17'b0000000_101_0111011
`define sub    17'b0100000_000_0110011
`define subw   17'b0100000_000_0111011
`define xor    17'b0000000_100_0110011
`define remw   17'b0000001_110_0111011
`define remuw  17'b0000001_111_0111011
`define remu   17'b0000001_111_0110011
`define rem    17'b0000001_110_0110011
`define or     17'b0000000_110_0110011
`define mul    17'b0000001_000_0110011
`define mulh   17'b0000001_001_0110011
`define mulhsu 17'b0000001_010_0110011
`define mulhu  17'b0000001_011_0110011
`define mulw   17'b0000001_000_0111011
`define div    17'b0000001_100_0110011
`define divu   17'b0000001_101_0110011
`define divuw  17'b0000001_101_0111011
`define divw   17'b0000001_100_0111011

//I
`define addi    10'b000_0010011 
`define addiw   10'b000_0011011
`define andi    10'b111_0010011   
`define ld      10'b011_0000011 
`define lw      10'b010_0000011
`define lh      10'b001_0000011
`define lb      10'b000_0000011
`define lwu     10'b110_0000011 
`define lhu     10'b101_0000011 
`define lbu     10'b100_0000011 
`define xori    10'b100_0010011
`define jalr    10'b000_1100111 
`define ori     10'b110_0010011
`define slti    10'b010_0010011
`define sltiu   10'b011_0010011  
`define slli    16'b000000_001_0010011 
`define srai    16'b010000_101_0010011
`define srli    16'b000000_101_0010011     
`define slliw   17'b0000000_001_0011011

`define sraiw   17'b0100000_101_0011011 
`define srliw   17'b0000000_101_0011011

`define ecall   22'b0000000_00000_000_1110011
`define ebreak  22'b0000000_00001_000_1110011 
`define mret    22'b0011000_00010_000_1110011 

//S
`define sd  10'b011_0100011
`define sw  10'b010_0100011
`define sh  10'b001_0100011
`define sb  10'b000_0100011

//B
`define beq   10'b000_1100011
`define bge   10'b101_1100011
`define bgeu  10'b111_1100011
`define blt   10'b100_1100011
`define bltu  10'b110_1100011
`define bne   10'b001_1100011

//J
`define jal     7'b1101111

//U
`define auipc   7'b0010111
`define lui     7'b0110111

//C
`define csrrw  10'b001_1110011
`define csrrs  10'b010_1110011
`define csrrc  10'b011_1110011
`define csrrwi 10'b101_1110011
`define csrrsi 10'b110_1110011
`define csrrci 10'b111_1110011


//CSR
`define mvendorid       12'hf11    //MRO
`define marchid         12'hf12
`define mimpid          12'hf13
`define mhartid         12'hf14

`define mstatus         12'h300
`define misa            12'h301
`define medeleg         12'h302
`define mideleg         12'h303
`define mie             12'h304
`define mtvec           12'h305
`define mcounteren      12'h306
`define mcountinhibit   12'h320
`define mscratch        12'h340
`define mepc            12'h341
`define mcause          12'h342
`define mtval           12'h343
`define mip             12'h344
`define mcycle          12'hb00
`define minstret        12'hb02
`define mcycleh         12'hb80       //32
`define minstreth       12'hb82       //32
`define tselect         12'h7a0
`define tdata1          12'h7a1
`define tdata2          12'h7a2
`define tdata3          12'h7a3

`define sstatus         12'h100

//Clint
`define msip     64'h2000000
`define mtimecmp 64'h2004000
`define mtime    64'h200bff8
`define TIME     64'd00002

//exception
`define EXCEPT_BUS 6 : 0
`define NO_EXCEPT 7'b0000_000
`define ECALL  7'b0000_001
`define EBREAK 7'b0000_010
`define MRET   7'b0000_100
`define INTER  7'b1000_000










///////////////////////   AIX4    //////////////////////////////////   
`define SIZE_B              2'b00
`define SIZE_H              2'b01
`define SIZE_W              2'b10
`define SIZE_D              2'b11

`define REQ_READ            1'b0
`define REQ_WRITE           1'b1


//aw_axi
// Burst types
`define AXI_BURST_TYPE_FIXED                                2'b00
`define AXI_BURST_TYPE_INCR                                 2'b01
`define AXI_BURST_TYPE_WRAP                                 2'b10
// Access permissions
`define AXI_PROT_UNPRIVILEGED_ACCESS                        3'b000
`define AXI_PROT_PRIVILEGED_ACCESS                          3'b001
`define AXI_PROT_SECURE_ACCESS                              3'b000
`define AXI_PROT_NON_SECURE_ACCESS                          3'b010
`define AXI_PROT_DATA_ACCESS                                3'b000
`define AXI_PROT_INSTRUCTION_ACCESS                         3'b100
// Memory types (AR)
`define AXI_ARCACHE_DEVICE_NON_BUFFERABLE                   4'b0000
`define AXI_ARCACHE_DEVICE_BUFFERABLE                       4'b0001
`define AXI_ARCACHE_NORMAL_NON_CACHEABLE_NON_BUFFERABLE     4'b0010
`define AXI_ARCACHE_NORMAL_NON_CACHEABLE_BUFFERABLE         4'b0011
`define AXI_ARCACHE_WRITE_THROUGH_NO_ALLOCATE               4'b1010
`define AXI_ARCACHE_WRITE_THROUGH_READ_ALLOCATE             4'b1110
`define AXI_ARCACHE_WRITE_THROUGH_WRITE_ALLOCATE            4'b1010
`define AXI_ARCACHE_WRITE_THROUGH_READ_AND_WRITE_ALLOCATE   4'b1110
`define AXI_ARCACHE_WRITE_BACK_NO_ALLOCATE                  4'b1011
`define AXI_ARCACHE_WRITE_BACK_READ_ALLOCATE                4'b1111
`define AXI_ARCACHE_WRITE_BACK_WRITE_ALLOCATE               4'b1011
`define AXI_ARCACHE_WRITE_BACK_READ_AND_WRITE_ALLOCATE      4'b1111
// Memory types (AW)
`define AXI_AWCACHE_DEVICE_NON_BUFFERABLE                   4'b0000
`define AXI_AWCACHE_DEVICE_BUFFERABLE                       4'b0001
`define AXI_AWCACHE_NORMAL_NON_CACHEABLE_NON_BUFFERABLE     4'b0010
`define AXI_AWCACHE_NORMAL_NON_CACHEABLE_BUFFERABLE         4'b0011
`define AXI_AWCACHE_WRITE_THROUGH_NO_ALLOCATE               4'b0110
`define AXI_AWCACHE_WRITE_THROUGH_READ_ALLOCATE             4'b0110
`define AXI_AWCACHE_WRITE_THROUGH_WRITE_ALLOCATE            4'b1110
`define AXI_AWCACHE_WRITE_THROUGH_READ_AND_WRITE_ALLOCATE   4'b1110
`define AXI_AWCACHE_WRITE_BACK_NO_ALLOCATE                  4'b0111
`define AXI_AWCACHE_WRITE_BACK_READ_ALLOCATE                4'b0111
`define AXI_AWCACHE_WRITE_BACK_WRITE_ALLOCATE               4'b1111
`define AXI_AWCACHE_WRITE_BACK_READ_AND_WRITE_ALLOCATE      4'b1111

`define AXI_SIZE_BYTES_1                                    3'b000
`define AXI_SIZE_BYTES_2                                    3'b001
`define AXI_SIZE_BYTES_4                                    3'b010
`define AXI_SIZE_BYTES_8                                    3'b011
`define AXI_SIZE_BYTES_16                                   3'b100
`define AXI_SIZE_BYTES_32                                   3'b101
`define AXI_SIZE_BYTES_64                                   3'b110
`define AXI_SIZE_BYTES_128                                  3'b111


`define RW_DATA_WIDTH      64
`define RW_ADDR_WIDTH      64
`define AXI_DATA_WIDTH     64
`define AXI_ADDR_WIDTH     32
`define AXI_ID_WIDTH       4
`define AXI_USER_WIDTH     1
