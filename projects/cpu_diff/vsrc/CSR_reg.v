//2021.9.14
//xu xin 
`include "defines.v"

module CSR_reg (
   input wire rst,
   input wire clk,
   input wire [11 : 0] csr_r_addr,

   input wire csr_w_ena,
   input wire [11 : 0] csr_w_addr,
   input wire [`REG_BUS] csr_w_data,
   
   input wire [`REG_BUS] except_type,
   input wire [`PC_BUS] except_pc,             //mem_pc
   input wire time_inter,


   output reg [`REG_BUS] csr_reg_data,
   output reg [`REG_BUS] mtvec,
   output reg [`REG_BUS] mepc,
   output reg [`REG_BUS] mie,
   output reg [`REG_BUS] mip,
   output reg [`REG_BUS] mstatus,

   output reg [`REG_BUS] mcause,   ////////////////////////////////////////
   output reg [`REG_BUS] mcycle,

   output reg flush

);


    always @(posedge clk) begin                //write csr
        if(rst == 1'b1) begin
            mtvec <= `ZERO_WORD;
            mepc <= `ZERO_WORD;
            mcause <= `ZERO_WORD;
            mstatus <= `ZERO_WORD;
            mie <= `ZERO_WORD;
            mip <= `ZERO_WORD;
            mcycle <= `ZERO_WORD;
        end
        else begin

            if(mcycle != 64'hffff_ffff_ffff_ffff) begin
                mcycle <= mcycle +1;
            end
            else begin
                mcycle <= 64'h0;
            end

            mip[7] <= time_inter;                    //interrpt

            if(csr_w_ena == 1'b1) begin
                case(csr_w_addr)
                    `mstatus:begin
                        mstatus <= csr_w_data;
                    end
                     `mtvec:begin
                        mtvec <= csr_w_data;
                    end
                    `mie:begin
                        mie <= csr_w_data;
                    end
                    `mepc:begin
                        mepc <= csr_w_data;
                    end
                    `mcause:begin
                        mcause <= csr_w_data;
                    end
                    `mcycle:begin
                        mcycle <= csr_w_data;
                    end
                    `mip:begin
                        mip[3 : 0] <= csr_w_data[3 : 0];
                    end
                    default:begin
                        
                    end
                endcase
            end

            case(except_type)
                 64'h1:begin            ////time_interrupt
                    mstatus[7] <= mstatus[3];    //MPIE
                    mstatus[3] <= 1'b0;          //MIE->0
                    mstatus[12 : 11] <= 2'b11;   //MPP
                    mcause <= {1'b1, 63'h7};
                    mepc <= except_pc;
                 end

                 64'h2:begin           ////ecall
                    mstatus[7] <= mstatus[3];    //MPIE
                    mstatus[3] <= 1'b0;          //MIE->0
                    mstatus[12 : 11] <= 2'b11;   //MPP
                    mcause <= {1'b0, 59'h0, 4'b1011};
                    mepc <= except_pc;
                 end

                 64'h3:begin           ////ebreak
                    mcause <= {1'b0, 59'h0, 4'b0011};
                    mstatus[7] <= mstatus[3];    //MPIE
                    mstatus[3] <= 1'b0;          //MIE->0
                    mstatus[12 : 11] <= 2'b11;   //MPP
                    mepc <= except_pc;
                 end

                 64'h4:begin           ////mret
                    mcause <= {1'b0, 59'h0, 4'b1100};         //yichang mret
                    mstatus[3] <= mstatus[7];
                    mstatus[7] <= 1'b0;
                    mstatus[12 : 11] <= 2'b00;
                 end

                 default:begin
                     
                 end
            endcase
        end
    end

    always @(*) begin                          //read csr
        if(rst == 1'b1) begin
            csr_reg_data = `ZERO_WORD;
        end
        else begin
            case(csr_r_addr)
                `mstatus:begin
                    csr_reg_data = mstatus;
                end
                `mtvec:begin
                    csr_reg_data = mtvec;
                end
                `mie:begin
                    csr_reg_data = mie;
                end
                `mepc:begin
                    csr_reg_data = mepc;
                end
                `mcause:begin
                    csr_reg_data = mcause;
                end
                `mcycle:begin
                    csr_reg_data = mcycle;
                end
                `mip:begin
                    csr_reg_data = mip;
                end
                default:begin
                    csr_reg_data = `ZERO_WORD;    
                end
            endcase
        end
    end



    always @(*) begin                          //Ctrl
        if(rst == 1'b1) begin
            flush = 1'b0;         
        end
        else begin
            flush = 1'b0;
            if(except_type != `ZERO_WORD) begin
                flush = 1'b1;
            end
        end
    end


endmodule
