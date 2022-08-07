`timescale 1ns / 1ps
//ROM
`define ROM_NUM  1024
`define ROM_NUMLOG  10

//DTAT_MEM
`define D_NUM  1024
`define D_NUMLOG  10

//CACHE
`define ysyx_22040931_CACHE_LINE 127 : 0

//forcase
`define ysyx_22040931_PHT_SIZE  256     //1<<`ysyx_22040931_BHT_WIDTH
`define ysyx_22040931_BHT_WIDTH  8      //ysyx_22040931_HASH_WIDTH
`define ysyx_22040931_BHT_SIZE  256     //1<<`ysyx_22040931_HASH_WIDTH
`define ysyx_22040931_HASH_WIDTH 8      //
//
`define ysyx_22040931_BTB_WIDTH 98       //
`define ysyx_22040931_BTB_SIZE 256
`define ysyx_22040931_RAS_INDEX 4
`define ysyx_22040931_RAS_SIZE 16

`define ysyx_22040931_ALU        6
`define ysyx_22040931_ALU_BUS    5 : 0
`define ysyx_22040931_REG        32
`define ysyx_22040931_MEM        64
`define ysyx_22040931_ZERO_NUM   64'h00000000_00000000
`define ysyx_22040931_ZERO_PC    64'h00000000_80000000
`define ysyx_22040931_NONE_INST  32'h00000000
`define ysyx_22040931_ZERO_REG   5'b00000
`define ysyx_22040931_ZERO_CSR   12'b0000_0000_0000
`define ysyx_22040931_PC_BUS     63 : 0
`define ysyx_22040931_DATA_BUS   63 : 0
`define ysyx_22040931_MEM_BUS    63 : 0
`define ysyx_22040931_INST_BUS   31 : 0
`define ysyx_22040931_REG_BUS     4 : 0
`define ysyx_22040931_CSR_BUS    11 : 0
`define ysyx_22040931_N_ENA        1'b0
`define ysyx_22040931_ENA          1'b1
`define ysyx_22040931_READ         1'b0 

//ALUOP
`define ysyx_22040931_NO      6'b000000
`define ysyx_22040931_ADD     6'b000001
`define ysyx_22040931_SUB     6'b000010
`define ysyx_22040931_AND     6'b000011
`define ysyx_22040931_XOR     6'b000100
`define ysyx_22040931_OR      6'b000101
`define ysyx_22040931_COM     6'b000110
`define ysyx_22040931_COMU    6'b000111
`define ysyx_22040931_SHIL    6'b001000
`define ysyx_22040931_SHIR    6'b001001
`define ysyx_22040931_SRA     6'b001010
`define ysyx_22040931_SHILW   6'b001011
`define ysyx_22040931_SRAW    6'b001100
`define ysyx_22040931_SHIRW   6'b001101
`define ysyx_22040931_PC      6'b001110
`define ysyx_22040931_SORT    6'b001111
`define ysyx_22040931_JUMP    6'b010000
`define ysyx_22040931_REMW    6'b010001
`define ysyx_22040931_REMUW   6'b010010
`define ysyx_22040931_REMU    6'b010011
`define ysyx_22040931_REM     6'b010100
`define ysyx_22040931_MUL     6'b010101
`define ysyx_22040931_MULH    6'b010110
`define ysyx_22040931_MULHSU  6'b010111
`define ysyx_22040931_MULHU   6'b011000
`define ysyx_22040931_MULW    6'b011001
`define ysyx_22040931_DIV     6'b011010
`define ysyx_22040931_DIVU    6'b011011
`define ysyx_22040931_DIVUW   6'b011100
`define ysyx_22040931_DIVW    6'b011101
`define ysyx_22040931_ANOR    6'b011110
`define ysyx_22040931_NUM1    6'b011111


//EXOP
`define ysyx_22040931_No      3'b000
`define ysyx_22040931_Arith   3'b111
`define ysyx_22040931_Short   3'b110
`define ysyx_22040931_Stort   3'b101
`define ysyx_22040931_Load    3'b100
`define ysyx_22040931_System  3'b011
`define ysyx_22040931_Lui     3'b010
`define ysyx_22040931_Csr     3'b001

//MEMROP
`define ysyx_22040931_MNO     3'b000
`define ysyx_22040931_R_ONE   3'b001
`define ysyx_22040931_R_ONEU  3'b010
`define ysyx_22040931_R_DOU   3'b011
`define ysyx_22040931_R_DOUU  3'b100
`define ysyx_22040931_R_FOR   3'b101
`define ysyx_22040931_R_FORU  3'b110
`define ysyx_22040931_R_EIG   3'b111

//MEMWOP
`define ysyx_22040931_MNO   3'b000
`define ysyx_22040931_W_ONE   3'b001
`define ysyx_22040931_W_DOU   3'b011
`define ysyx_22040931_W_FOR   3'b101
`define ysyx_22040931_W_EIG   3'b111

//MEMOP
`define ysyx_22040931_SIZE_B    2'b00
`define ysyx_22040931_SIZE_H    2'b01
`define ysyx_22040931_SIZE_W    2'b10
`define ysyx_22040931_SIZE_D    2'b11


//TYPE
`define ysyx_22040931_It     3'b111
`define ysyx_22040931_St     3'b110
`define ysyx_22040931_Bt     3'b101
`define ysyx_22040931_Jt     3'b100
`define ysyx_22040931_Ut     3'b011
`define ysyx_22040931_Rt     3'b010
`define ysyx_22040931_Ct     3'b001


//R
`define ysyx_22040931_add    17'b0000000_000_0110011
`define ysyx_22040931_addw   17'b0000000_000_0111011
`define ysyx_22040931_and    17'b0000000_111_0110011
`define ysyx_22040931_sll    17'b0000000_001_0110011
`define ysyx_22040931_sllw   17'b0000000_001_0111011
`define ysyx_22040931_slt    17'b0000000_010_0110011
`define ysyx_22040931_sltu   17'b0000000_011_0110011
`define ysyx_22040931_sra    17'b0100000_101_0110011
`define ysyx_22040931_sraw   17'b0100000_101_0111011
`define ysyx_22040931_srl    17'b0000000_101_0110011
`define ysyx_22040931_srlw   17'b0000000_101_0111011
`define ysyx_22040931_sub    17'b0100000_000_0110011
`define ysyx_22040931_subw   17'b0100000_000_0111011
`define ysyx_22040931_xor    17'b0000000_100_0110011
`define ysyx_22040931_remw   17'b0000001_110_0111011
`define ysyx_22040931_remuw  17'b0000001_111_0111011
`define ysyx_22040931_remu   17'b0000001_111_0110011
`define ysyx_22040931_rem    17'b0000001_110_0110011
`define ysyx_22040931_or     17'b0000000_110_0110011
`define ysyx_22040931_mul    17'b0000001_000_0110011
`define ysyx_22040931_mulh   17'b0000001_001_0110011
`define ysyx_22040931_mulhsu 17'b0000001_010_0110011
`define ysyx_22040931_mulhu  17'b0000001_011_0110011
`define ysyx_22040931_mulw   17'b0000001_000_0111011
`define ysyx_22040931_div    17'b0000001_100_0110011
`define ysyx_22040931_divu   17'b0000001_101_0110011
`define ysyx_22040931_divuw  17'b0000001_101_0111011
`define ysyx_22040931_divw   17'b0000001_100_0111011

//I
`define ysyx_22040931_addi    10'b000_0010011 
`define ysyx_22040931_addiw   10'b000_0011011
`define ysyx_22040931_andi    10'b111_0010011   
`define ysyx_22040931_ld      10'b011_0000011 
`define ysyx_22040931_lw      10'b010_0000011
`define ysyx_22040931_lh      10'b001_0000011
`define ysyx_22040931_lb      10'b000_0000011
`define ysyx_22040931_lwu     10'b110_0000011 
`define ysyx_22040931_lhu     10'b101_0000011 
`define ysyx_22040931_lbu     10'b100_0000011 
`define ysyx_22040931_xori    10'b100_0010011
`define ysyx_22040931_jalr    10'b000_1100111 
`define ysyx_22040931_ori     10'b110_0010011
`define ysyx_22040931_slti    10'b010_0010011
`define ysyx_22040931_sltiu   10'b011_0010011  
`define ysyx_22040931_slli    16'b000000_001_0010011 
`define ysyx_22040931_srai    16'b010000_101_0010011
`define ysyx_22040931_srli    16'b000000_101_0010011     
`define ysyx_22040931_slliw   17'b0000000_001_0011011

`define ysyx_22040931_sraiw   17'b0100000_101_0011011 
`define ysyx_22040931_srliw   17'b0000000_101_0011011

`define ysyx_22040931_ecall   22'b0000000_00000_000_1110011
`define ysyx_22040931_ebreak  22'b0000000_00001_000_1110011 
`define ysyx_22040931_mret    22'b0011000_00010_000_1110011 

//S
`define ysyx_22040931_sd  10'b011_0100011
`define ysyx_22040931_sw  10'b010_0100011
`define ysyx_22040931_sh  10'b001_0100011
`define ysyx_22040931_sb  10'b000_0100011

//B
`define ysyx_22040931_beq   10'b000_1100011
`define ysyx_22040931_bge   10'b101_1100011
`define ysyx_22040931_bgeu  10'b111_1100011
`define ysyx_22040931_blt   10'b100_1100011
`define ysyx_22040931_bltu  10'b110_1100011
`define ysyx_22040931_bne   10'b001_1100011

//J
`define ysyx_22040931_jal     7'b1101111

//U
`define ysyx_22040931_auipc   7'b0010111
`define ysyx_22040931_lui     7'b0110111

//C
`define ysyx_22040931_csrrw  10'b001_1110011
`define ysyx_22040931_csrrs  10'b010_1110011
`define ysyx_22040931_csrrc  10'b011_1110011
`define ysyx_22040931_csrrwi 10'b101_1110011
`define ysyx_22040931_csrrsi 10'b110_1110011
`define ysyx_22040931_csrrci 10'b111_1110011


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
`define ysyx_22040931_EXCEPT_BUS 6 : 0
`define ysyx_22040931_NO_EXCEPT 7'b0000_000
`define ysyx_22040931_ECALL  7'b0000_001
`define ysyx_22040931_EBREAK 7'b0000_010
`define ysyx_22040931_MRET   7'b0000_100
`define ysyx_22040931_INTER  7'b1000_000










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
