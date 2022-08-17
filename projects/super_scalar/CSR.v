//2022.8.4 xuxin
`include "defines.v"

module CSR(

    input wire reset,
    input wire clock,
    input wire valid,
    //except
    input wire wb_ready,
    input wire [`EXCEPT_BUS] except,
    input wire [`PC_BUS] except_pc,
    output wire [`PC_BUS] handle_pc,

    input wire csr_w_ena,
    input wire [`CSR_BUS] csr_w_addr,
    input wire [`DATA_BUS] csr_w_data,
    
    input wire csr_r_ena,
    input wire [`CSR_BUS] csr_r_addr,
    output reg [`DATA_BUS] csr_r_data,
    
  
    output wire [`DATA_BUS] csr_mstatus  ,
    output wire [`DATA_BUS] csr_mie      ,
    output wire [`DATA_BUS] csr_mtvec    ,
    output wire [`DATA_BUS] csr_mscratch ,
    output wire [`DATA_BUS] csr_mepc     ,
    output wire [`DATA_BUS] csr_mcause   ,
    output wire [`DATA_BUS] csr_mip      ,
    output wire [`DATA_BUS] csr_mcycle   ,          
    output wire [`DATA_BUS] csr_minstret , 
    output wire [`DATA_BUS] csr_sstatus    
);

   reg [`DATA_BUS] mstatus;
   reg [`DATA_BUS] mie;
   reg [`DATA_BUS] mtvec;
   reg [`DATA_BUS] mscratch;
   reg [`DATA_BUS] mepc;
   reg [`DATA_BUS] mcause;
   reg [`DATA_BUS] mip;
   reg [`DATA_BUS] mcycle;
   reg [`DATA_BUS] minstret;
   reg [`DATA_BUS] sstatus;


 w_data[16]), csr_w_data[62 : 0]} : sstatus ;
    always @(posedge clock) begin                
        if(reset == 1'b1) begin
            mstatus   <=  `ZERO_NUM;
            mie       <=  `ZERO_NUM;
            mtvec     <=  `ZERO_NUM;
            mscratch  <=  `ZERO_NUM;
            mepc      <=  `ZERO_NUM;
            mcause    <=  `ZERO_NUM;
            mip       <=  `ZERO_NUM;
            mcycle    <=  `ZERO_NUM;
            minstret  <=  `ZERO_NUM;
            sstatus   <=  `ZERO_NUM;
        end        
        else begin
            mcycle    <=  csr_mcycle  ;
            minstret  <=  csr_minstret;
            mstatus   <=  csr_mstatus ;
            mie       <=  csr_mie     ;
            mtvec     <=  csr_mtvec   ;
            mscratch  <=  csr_mscratch;
            mepc      <=  csr_mepc    ;
            mcause    <=  csr_mcause  ;
            mip       <=  csr_mip     ;
            sstatus   <=  csr_sstatus ;

        end
    end

    //read csr
    assign csr_r_data = csr_r_ena ? (csr_r_addr == csr_w_addr)  ? csr_w_data :
                                    (csr_r_addr == `mstatus )   ? mstatus    : 
                                    (csr_r_addr == `mie     )   ? mie        :
                                    (csr_r_addr == `mtvec   )   ? mtvec      :
                                    (csr_r_addr == `mscratch)   ? mscratch   :
                                    (csr_r_addr == `mepc    )   ? mepc       :
                                    (csr_r_addr == `mcause  )   ? mcause     :
                                    (csr_r_addr == `mip     )   ? mip        :
                                    (csr_r_addr == `mcycle  )   ? mcycle     :
                                    (csr_r_addr == `minstret)   ? minstret   :
                                    (csr_r_addr == `sstatus )   ? sstatus    : 
                                    `ZERO_NUM : `ZERO_NUM ;



    wire inter  = (except[6]) ? wb_ready : 1'b0;
    wire ecall  = (except == `ECALL ) ? wb_ready : 1'b0;
    wire ebreak = (except == `EBREAK) ? wb_ready : 1'b0;
    wire mret   = (except == `MRET  ) ? wb_ready : 1'b0;
                                                    
    assign csr_mstatus  = (inter | ecall | ebreak) ? {mstatus[63 : 13], 2'b11, mstatus[10 : 8], mstatus[3], mstatus[6 : 4], 1'b0, mstatus[2 : 0]} :
                          mret ? {mstatus[63 : 13], 2'b00, mstatus[10 : 8], 1'b1, mstatus[6 : 4], mstatus[7], mstatus[2 : 0]} :
                          (csr_w_addr == `mstatus ) & csr_w_ena ? {(csr_w_data[13] & csr_w_data[14]) | (csr_w_data[15] & csr_w_data[16]), csr_w_data[62 : 0]} : mstatus ;
    assign csr_mie      = (csr_w_addr == `mie     ) & csr_w_ena ? csr_w_data : mie     ;
    assign csr_mtvec    = (csr_w_addr == `mtvec   ) & csr_w_ena ? csr_w_data : mtvec   ;
    assign csr_mscratch = (csr_w_addr == `mscratch) & csr_w_ena ? csr_w_data : mscratch;
    assign csr_mepc     = (inter | ecall | ebreak) ? except_pc :
                          (csr_w_addr == `mepc    ) & csr_w_ena ? csr_w_data : mepc    ;
    assign csr_mcause   = inter ? {1'b1, 63'h7} :
                          ecall ? {1'b0, 59'h0, 4'b1011} :
                          ebreak ? {1'b0, 59'h0, 4'b0011} :
                          (csr_w_addr == `mcause  ) & csr_w_ena ? csr_w_data : mcause  ;
    assign csr_mip      = (csr_w_addr == `mip     ) & csr_w_ena ? csr_w_data : mip;//{mip[63 : 8], inter, mip[6 : 0]};
    assign csr_mcycle   = (csr_w_addr == `mcycle  ) & csr_w_ena ? csr_w_data : mcycle+1;
    assign csr_minstret = (csr_w_addr == `minstret) & csr_w_ena ? csr_w_data : valid ? minstret+1 : minstret;
    assign csr_sstatus  = csr_w_ena ? (csr_w_addr == `mstatus ) ? {(csr_w_data[13] & csr_w_data[14]) | (csr_w_data[15] & csr_w_data[16]), 46'h0, csr_w_data[16 : 13], 13'h0} :
                                      (csr_w_addr == `sstatus ) ? {(csr_w_data[13] & csr_w_data[14]) | (csr_w_data[15] & csr_w_data[16]), csr_w_data[62 : 0]} : sstatus 
                                      : sstatus;


    assign handle_pc = mret ? csr_mepc : csr_mtvec;


endmodule
