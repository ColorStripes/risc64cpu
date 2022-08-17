//2022.8.6 xuxin
`include "defines.v"

module CLINT (
    input wire reset,
    input wire clock,
    input wire mem_wr,
    input wire clint_ena,
    input wire [`PC_BUS] mem_addr,
    input wire [`DATA_BUS] stor_data,


    output reg time_inter,
    output wire [`DATA_BUS] clint_data

);
    reg [31 : 0] msip;
    reg [`DATA_BUS] mtime;
    reg [`DATA_BUS] mtimecmp;

    wire is_inter = (mtimecmp == 64'h0) | (mtime < mtimecmp) ? 1'b0 : 1'b1;
    wire [31 : 0] csr_msip     = (mem_addr == `msip    ) & clint_ena & mem_wr ? stor_data[31 : 0] : msip;
    wire [`DATA_BUS] csr_mtime    = (mem_addr == `mtime   ) & clint_ena & mem_wr ? stor_data : mtime + 1;
    wire [`DATA_BUS] csr_mtimecmp = (mem_addr == `mtimecmp) & clint_ena & mem_wr ? stor_data : mtimecmp;
    always @(posedge clock) begin
        if(reset == 1'b1) begin
            msip <= `ZERO_NUM;
            mtime <= `ZERO_NUM;
            mtimecmp <= `TIME;
            time_inter <= 1'b0;
        end
        else begin
            msip <= csr_msip;
            mtime <= csr_mtime;
            mtimecmp <= csr_mtimecmp;
            time_inter <= is_inter;
        end  
    end

    //read
    assign clint_data = clint_ena & !mem_wr ? (mem_addr == `msip    ) ? {32'h0, msip} :
                                              (mem_addr == `mtimecmp) ? mtimecmp :
                                              (mem_addr == `mtime   ) ? mtime : `ZERO_NUM :
                                              `ZERO_NUM;




                                                  
// always @(posedge clock) begin                                   //difftest
//     if(reset == 1'b1) begin
//         clint <= 1'b0;
//     end
//     else begin
//         clint <= 1'b0;
//         if(~ex_mem_wr & ex_clint_ena) begin
//             if((ex_mem_raddr == `msip) || (ex_mem_raddr == `mtimecmp) || (ex_mem_raddr == `mtime)) begin
//                 clint <= 1'b1;
//             end
//         end
//         if(ex_mem_wr & ex_clint_ena) begin
//             if((ex_mem_waddr == `msip) || (ex_mem_waddr == `mtimecmp) || (ex_mem_waddr == `mtime)) begin
//                 clint <= 1'b1;
//             end
//         end
//     end  
// end




endmodule