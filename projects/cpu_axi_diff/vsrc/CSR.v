//2022.8.4 xuxin
`include "defines.v"

module CSR(

    input wire reset,
    input wire clock,
    input wire valid,

    input wire csr_w_ena,
    input wire [`ysyx_22040931_CSR_BUS] csr_w_addr,
    input wire [`ysyx_22040931_DATA_BUS] csr_w_data,
    
    input wire csr_r_ena,
    input wire [`ysyx_22040931_CSR_BUS] csr_r_addr,
    output reg [`ysyx_22040931_DATA_BUS] csr_r_data,
    
  
    output wire [`ysyx_22040931_DATA_BUS] csr_mstatus  ,
    output wire [`ysyx_22040931_DATA_BUS] csr_mie      ,
    output wire [`ysyx_22040931_DATA_BUS] csr_mtvec    ,
    output wire [`ysyx_22040931_DATA_BUS] csr_mscratch ,
    output wire [`ysyx_22040931_DATA_BUS] csr_mepc     ,
    output wire [`ysyx_22040931_DATA_BUS] csr_mcause   ,
    output wire [`ysyx_22040931_DATA_BUS] csr_mip      ,
    output wire [`ysyx_22040931_DATA_BUS] csr_mcycle   ,          
    output wire [`ysyx_22040931_DATA_BUS] csr_minstret , 
    output wire [`ysyx_22040931_DATA_BUS] csr_sstatus    
);
    //output reg flush
    // input wire [`ysyx_22040931_DATA_BUS] except_type,
    // input wire [`PC_BUS] except_pc,             //mem_pc
    // input wire time_inter,
   
    // input wire [`ysyx_22040931_DATA_BUS] except_type,
    // input wire [`ysyx_22040931_PC_BUS] except_pc,             //mem_pc
    // input wire time_inter,
    // input wire stall,   



   reg [`ysyx_22040931_DATA_BUS] mstatus;
   reg [`ysyx_22040931_DATA_BUS] mie;
   reg [`ysyx_22040931_DATA_BUS] mtvec;
   reg [`ysyx_22040931_DATA_BUS] mscratch;
   reg [`ysyx_22040931_DATA_BUS] mepc;
   reg [`ysyx_22040931_DATA_BUS] mcause;
   reg [`ysyx_22040931_DATA_BUS] mip;
   reg [`ysyx_22040931_DATA_BUS] mcycle;
   reg [`ysyx_22040931_DATA_BUS] minstret;
   reg [`ysyx_22040931_DATA_BUS] sstatus;


    //write csr
    assign csr_mstatus  = (csr_w_addr == `mstatus ) & csr_w_ena ? {(csr_w_data[13] & csr_w_data[14]) | (csr_w_data[15] & csr_w_data[16]), csr_w_data[62 : 0]} : mstatus ;
    assign csr_mie      = (csr_w_addr == `mie     ) & csr_w_ena ? csr_w_data : mie     ;
    assign csr_mtvec    = (csr_w_addr == `mtvec   ) & csr_w_ena ? csr_w_data : mtvec   ;
    assign csr_mscratch = (csr_w_addr == `mscratch) & csr_w_ena ? csr_w_data : mscratch;
    assign csr_mepc     = (csr_w_addr == `mepc    ) & csr_w_ena ? csr_w_data : mepc    ;
    assign csr_mcause   = (csr_w_addr == `mcause  ) & csr_w_ena ? csr_w_data : mcause  ;
    assign csr_mip      = (csr_w_addr == `mip     ) & csr_w_ena ? csr_w_data : mip     ;
    assign csr_mcycle   = (csr_w_addr == `mcycle  ) & csr_w_ena ? csr_w_data : mcycle+1;
    assign csr_minstret = (csr_w_addr == `minstret) & csr_w_ena ? csr_w_data : valid ? minstret+1 : minstret;
    assign csr_sstatus  = (csr_w_addr == `sstatus ) & csr_w_ena ? {(csr_w_data[13] & csr_w_data[14]) | (csr_w_data[15] & csr_w_data[16]), csr_w_data[62 : 0]} : sstatus ;
    always @(posedge clock) begin                
        if(reset == 1'b1) begin
            mstatus   <=  `ysyx_22040931_ZERO_NUM;
            mie       <=  `ysyx_22040931_ZERO_NUM;
            mtvec     <=  `ysyx_22040931_ZERO_NUM;
            mscratch  <=  `ysyx_22040931_ZERO_NUM;
            mepc      <=  `ysyx_22040931_ZERO_NUM;
            mcause    <=  `ysyx_22040931_ZERO_NUM;
            mip       <=  `ysyx_22040931_ZERO_NUM;
            mcycle    <=  `ysyx_22040931_ZERO_NUM;
            minstret  <=  `ysyx_22040931_ZERO_NUM;
            sstatus   <=  `ysyx_22040931_ZERO_NUM;
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
    assign csr_r_data = csr_r_ena ? (csr_r_addr == csr_w_addr) ? csr_w_data :
                                    (csr_r_addr == mstatus )   ? mstatus    : 
                                    (csr_r_addr == mie     )   ? mie        :
                                    (csr_r_addr == mtvec   )   ? mtvec      :
                                    (csr_r_addr == mscratch)   ? mscratch   :
                                    (csr_r_addr == mepc    )   ? mepc       :
                                    (csr_r_addr == mcause  )   ? mcause     :
                                    (csr_r_addr == mip     )   ? mip        :
                                    (csr_r_addr == mcycle  )   ? mcycle     :
                                    (csr_r_addr == minstret)   ? minstret   :
                                    (csr_r_addr == sstatus )   ? sstatus    : 
                                    `ysyx_22040931_ZERO_NUM : `ysyx_22040931_ZERO_NUM ;




    // assign csr_mstatus =  ((csr_w_ena == 1'b1) & (csr_w_addr == `mstatus))  ? {(csr_w_data[13] & csr_w_data[14]) | (csr_w_data[15] & csr_w_data[16]),  csr_w_data[62 : 0]}: mstatus;     
    // assign csr_mie =      ((csr_w_ena == 1'b1) & (csr_w_addr == `mie))      ? csr_w_data : mie;
    // assign csr_mtvec =    ((csr_w_ena == 1'b1) & (csr_w_addr == `mtvec))    ? csr_w_data : mtvec;
    // assign csr_mscratch = ((csr_w_ena == 1'b1) & (csr_w_addr == `mscratch)) ? csr_w_data : mscratch;
    // assign csr_mepc =     ((csr_w_ena == 1'b1) & (csr_w_addr == `mepc))     ? csr_w_data : mepc;
    // assign csr_mcause =   ((csr_w_ena == 1'b1) & (csr_w_addr == `mcause))   ? csr_w_data : mcause;
    // assign csr_mip =      ((csr_w_ena == 1'b1) & (csr_w_addr == `mip))      ? csr_w_data : mip; 
    // assign csr_mcycle =   ((csr_w_ena == 1'b1) & (csr_w_addr == `mcycle))   ? csr_w_data : mcycle;
    // assign csr_minstret = ((csr_w_ena == 1'b1) & (csr_w_addr == `mcycle))   ? csr_w_data : minstret;
    // assign csr_sstatus =  ((csr_w_ena == 1'b1) & (csr_w_addr == `mstatus))  ? {{(csr_w_data[13] & csr_w_data[14]) | (csr_w_data[15] & csr_w_data[16])}, 46'h0, csr_w_data[16 : 13], 13'h0} : sstatus;


    // always @(*) begin                          //Ctrl
    //     if(reset == 1'b1) begin
    //         flush = 1'b0;         
    //     end
    //     else begin
    //         if(except_type != `ZERO_WORD) begin
    //             flush = 1'b1;
    //         end
    //         else begin
    //             flush = 1'b0;
    //         end
    //     end
    // end




endmodule
