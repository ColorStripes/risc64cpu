//2122.8.14 xuxin
`include "defines.v"

module RAT_M#(
    parameter RAT_NUM = 32,
    parameter RAT_IND = 5,
    parameter RAT_WID = 6
)(
    input wire reset,
    input wire clock,

    input wire src0l_ena,
    input wire [RAT_IND-1 : 0] src0l,
    output wire [RAT_WID-1 : 0] src0l_data,
    input wire src0r_ena,
    input wire [RAT_IND-1 : 0] src0r,
    output wire [RAT_WID-1 : 0] src0r_data,
    input wire dst0r_ena,
    input wire [RAT_IND-1 : 0] dst0r,
    output wire [RAT_WID-1 : 0] dst0r_data,
    input wire wen0,
    input wire [RAT_IND-1 : 0] dst0w,
    input wire [RAT_WID-1 : 0] free_list0,

    input wire src1l_ena,
    input wire [RAT_IND-1 : 0] src1l,
    output wire [RAT_WID-1 : 0] src1l_data,
    input wire src1r_ena,
    input wire [RAT_IND-1 : 0] src1r,
    output wire [RAT_WID-1 : 0] src1r_data,
    input wire dst1r_ena,
    input wire [RAT_IND-1 : 0] dst1r,
    output wire [RAT_WID-1 : 0] dst1r_data,
    input wire wen1,
    input wire [RAT_IND-1 : 0] dst1w,
    input wire [RAT_WID-1 : 0] free_list1

);


    reg [RAT_WID-1 : 0] RAT[0 : RAT_NUM-1];
    //------------------write-------------------
    wire [RAT_WID-1 : 0] RAT_data0 = wen0 ? free_list0 : RAT[dst0w];
    wire [RAT_WID-1 : 0] RAT_data1 = wen1 ? free_list1 : RAT[dst1w];
    always @(posedge clock) begin
        if(reset) begin
            for(i = 0; i < RAT_NUM; i=i+1) begin
                RAT[i] <= 0;
            end
        end
        else begin
            RAT[dst0w] <= RAT_data0;
            RAT[dst1w] <= RAT_data1;
        end
    end


    //-----------------read-------------------------
    assign src0l_data = src0l_ena ? RAT[src0l] : `ZERO_PRF;
    assign src0r_data = src0r_ena ? RAT[src0r] : `ZERO_PRF;
    assign dst0r_data = dst0r_ena ? RAT[dst0r] : `ZERO_PRF;

    assign src1l_data = src1l_ena ? RAT[src1l] : `ZERO_PRF;
    assign src1r_data = src1r_ena ? RAT[src1r] : `ZERO_PRF;
    assign dst1r_data = dst1r_ena ? RAT[dst1r] : `ZERO_PRF;


endmodule
