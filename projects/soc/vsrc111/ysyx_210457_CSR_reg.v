//2021.9.14
//xu xin 
`include "defines.v"

module ysyx_210457_CSR_reg (
   input wire reset,
   input wire clock,
   input wire [11 : 0] csr_r_addr,

   input wire csr_w_ena,
   input wire [11 : 0] csr_w_addr,
   input wire [`REG_BUS] csr_w_data,
   
   input wire [`REG_BUS] except_type,
   input wire [`PC_BUS] except_pc,             //mem_pc
   input wire time_inter,
   input wire stall,


   output reg [`REG_BUS] csr_reg_data,
   output wire mstatus,
   output wire [`REG_BUS] mtvec,
   output wire [`REG_BUS] mepc,
   output wire mie,
   output wire mip,

   output reg flush
   

);


   
   reg [`REG_BUS] csr_mepc;
   reg [`REG_BUS] csr_mstatus;
   reg [`REG_BUS] csr_mip;
   reg [`REG_BUS] csr_mie;
   reg [`REG_BUS] csr_mtvec;
   
   reg [`REG_BUS] csr_mscratch;        
   reg [`REG_BUS] csr_mcause;   
   reg [`REG_BUS] csr_mcycle;
   reg [`REG_BUS] csr_minstret;
   reg [`REG_BUS] csr_sstatus;

    always @(posedge clock) begin                //write csr
        if(reset == 1'b1) begin
            csr_mtvec <= `ZERO_WORD;
            csr_mepc <= `ZERO_WORD;
            csr_mcause <= `ZERO_WORD;
            csr_mstatus <= `ZERO_WORD;
            csr_mie <= `ZERO_WORD;
            csr_mip <= `ZERO_WORD;
            csr_mcycle <= `ZERO_WORD;
            csr_minstret <= 64'h1;
            csr_mscratch <= `ZERO_WORD;
            csr_sstatus <= `ZERO_WORD;
        end
        else begin

            csr_mcycle <= csr_mcycle + 1;        //cycle

            csr_mip[7] <= time_inter;            //interrpt

            if((except_pc != `PC_START) && (except_type != 64'h1) && (stall != 1'b1)) begin
                csr_minstret <= csr_minstret + 1;
            end

            if(csr_w_ena == 1'b1) begin
                case(csr_w_addr)
                    `mstatus:begin
                        csr_mstatus[62 : 0] <= csr_w_data[62 : 0];
                        csr_mstatus[63] <= (csr_w_data[13] & csr_w_data[14]) | (csr_w_data[15] & csr_w_data[16]);
                        csr_sstatus[63] <= (csr_w_data[13] & csr_w_data[14]) | (csr_w_data[15] & csr_w_data[16]);
                        csr_sstatus[16 : 13] <= csr_w_data[16 : 13];
                    end
                     `mtvec:begin
                        csr_mtvec <= csr_w_data;
                    end
                    `mie:begin
                        csr_mie <= csr_w_data;
                    end
                    `mepc:begin
                        csr_mepc <= csr_w_data;
                    end
                    `mcause:begin
                        csr_mcause <= csr_w_data;
                    end
                    `mscratch:begin
                        csr_mscratch <= csr_w_data;
                    end
                    `mcycle:begin
                        csr_mcycle <= csr_w_data;
                    end
                    `minstret:begin
                        csr_minstret <= csr_w_data;
                    end
                    `mip:begin
                        csr_mip[3 : 0] <= csr_w_data[3 : 0];
                    end
                    `sstatus:begin
                        csr_sstatus <= csr_w_data;
                    end
                    default:begin
                        
                    end
                endcase
            end
            

            case(except_type)
                 64'h1:begin            ////time_interrupt
                    csr_mstatus[7] <= csr_mstatus[3];    //MPIE
                    csr_mstatus[3] <= 1'b0;          //MIE->0
                    csr_mstatus[12 : 11] <= 2'b11;   //MPP
                    csr_mcause <= {1'b1, 63'h7};
                    csr_mepc <= except_pc;
                    csr_mip[7] <= 1'b0;
                 end

                 64'h2:begin           ////ecall
                    csr_mstatus[7] <= csr_mstatus[3];    //MPIE
                    csr_mstatus[3] <= 1'b0;          //MIE->0
                    csr_mstatus[12 : 11] <= 2'b11;   //MPP
                    csr_mcause <= {1'b0, 59'h0, 4'b1011};
                    csr_mepc <= except_pc;
                 end

                 64'h3:begin           ////ebreak
                    csr_mstatus[7] <= csr_mstatus[3];    //MPIE
                    csr_mstatus[3] <= 1'b0;          //MIE->0
                    csr_mstatus[12 : 11] <= 2'b11;   //MPP
                    csr_mcause <= {1'b0, 59'h0, 4'b0011};
                    csr_mepc <= except_pc;
                 end

                 64'h4:begin           ////mret                   
                    csr_mstatus[3] <= csr_mstatus[7];
                    csr_mstatus[7] <= 1'b1;
                    csr_mstatus[12 : 11] <= 2'b00;
                    //csr_mepc <= except_pc;
                 end

                 default:begin
                     
                 end
            endcase
        end
    end

    always @(*) begin                          //read csr
        if(reset == 1'b1) begin
            csr_reg_data = `ZERO_WORD;
        end
        else if((csr_w_ena == 1'b1) && (csr_r_addr == csr_w_addr)) begin
            csr_reg_data = csr_w_data;
        end
        else begin
            case(csr_r_addr)
                `mstatus:begin
                    csr_reg_data = csr_mstatus;
                end
                `mtvec:begin
                    csr_reg_data = csr_mtvec;
                end
                `mie:begin
                    csr_reg_data = csr_mie;
                end
                `mepc:begin
                    csr_reg_data = csr_mepc;
                end
                `mcause:begin
                    csr_reg_data = csr_mcause;
                end
                `mcycle:begin
                    csr_reg_data = csr_mcycle;
                end
                `minstret:begin
                    csr_reg_data = csr_minstret;
                end
                `mip:begin
                    csr_reg_data = csr_mip;
                end
                `mscratch:begin
                    csr_reg_data = csr_mscratch;
                end
                `sstatus:begin
                    csr_reg_data = csr_sstatus;
                end
                default:begin
                    csr_reg_data = `ZERO_WORD;    
                end
            endcase
        end
    end


 assign mstatus = ((csr_w_ena == 1'b1) & (csr_w_addr == `mstatus)) ? {(csr_w_data[13] & csr_w_data[14]) | (csr_w_data[15] & csr_w_data[16]),  csr_w_data[62 : 0]}[3] : csr_mstatus[3]; 
 assign mepc = ((csr_w_ena == 1'b1) & (csr_w_addr == `mepc)) ? csr_w_data : csr_mepc;
 assign mip = ((csr_w_ena == 1'b1) & (csr_w_addr == `mip)) ? csr_w_data[7] :csr_mip[7]; 
 assign mie = ((csr_w_ena == 1'b1) & (csr_w_addr == `mie)) ? csr_w_data[7] : csr_mie[7];
 assign mtvec = ((csr_w_ena == 1'b1) & (csr_w_addr == `mtvec)) ? csr_w_data : csr_mtvec;


    always @(*) begin                          //Ctrl
        if(reset == 1'b1) begin
            flush = 1'b0;         
        end
        else begin
            if(except_type != `ZERO_WORD) begin
                flush = 1'b1;
            end
            else begin
                flush = 1'b0;
            end
        end
    end


endmodule
