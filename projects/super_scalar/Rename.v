//2022.8.15 xuxin
`include "defines.v"

module Rename(
    input wire reset,
    input wire clock,

    //RAT
    input wire src0l_ena,
    input wire [`REG_BUS] src0l,
    output wire [`PRF_BUS] src0l_data,

    input wire src0r_ena,
    input wire [`REG_BUS] src0r,
    output wire [`PRF_BUS] src0r_data,

    input wire wen0,
    input wire [`REG_BUS] dst0w,
    input wire [`PRF_BUS] free_list0,

    input wire src1l_ena,
    input wire [`REG_BUS] src1l,
    output wire [`PRF_BUS] src1l_data,

    input wire src1r_ena,
    input wire [`REG_BUS] src1r,
    output wire [`PRF_BUS] src1r_data,

    input wire wen1,
    input wire [`REG_BUS] dst1w,
    input wire [`PRF_BUS] free_list1,


    //retire
    input wire retire_0,
    input wire [`REG_BUS] retire_dst0,
    input wire retire_1,
    input wire [`REG_BUS] retire_dst1,



);




Check Check(
    .wen_0(wen0),
    .w_addr_0(dst0w),
    .wen_1(wen1),
    .w_addr_1(dst1w),
    .ren1_1(src1l_ena),
    .r_addr1_1(src1l),
    .ren2_1(src1r_ena),
    .r_addr2_1(src1r),



    .FL_1_1(FL_1_1),
    .FL_2_1(FL_2_1),
    .rat_wen_0(rat_wen_0),
    .rat_wen_1(rat_wen_1)

);

wire FL_1_1;
wire FL_2_1;
wire rat_wen_0;
wire rat_wen_1;


RAT_M RAT_M(
    .reset(reset),
    .clock(clock),


    .src0l_ena(src0l_ena),
    .src0l(src0l),
    .src0l_data(src0l_data),

    .src0r_ena(src0r_ena),
    .src0r(src0r),
    .src0r_data(src0r_data),

    .dst0r_ena(retire_0),
    .dst0r(retire_dst0),
    .dst0r_data(retire_data_0),

    .wen0(rat_wen_0),
    .dst0w(dst0w),
    .free_list0(free_list0),

    .src1l_ena(src1l_ena),
    .src1l(src1l),
    .src1l_data(src1l_rat_data),

    .src1r_ena(src1r_ena),
    .src1r(src1r),
    .src1r_data(src1r_rat_data),

    .dst1r_ena(retire_1),
    .dst1r(retire_dst1),
    .dst1r_data(retire_data_1),

    .wen1(rat_wen_1),
    .dst1w(dst1w),
    .free_list1(free_list1)

);

wire [`PRF_BUS] retire_data_0;
wire [`PRF_BUS] retire_data_1;
wire [`PRF_BUS] src1l_rat_data;
wire [`PRF_BUS] src1r_rat_data;
assign src1l_data = FL_1_1 ? free_list0 : src1l_rat_data;
assign src1r_data = FL_2_1 ? free_list0 : src1r_rat_data;

FREE_LIST_M FREE_LIST_M(
    .reset(reset),
    .clock(clock),

    .wen_0(retire_0),
    .w_data_0(retire_data_0),

    .ren_0(wen0),
    .r_data_0(free_list0),

    .wen_1(retire_1),
    .w_data_1(retire_data_1),

    .ren_1(wen1),
    .r_data_1(free_list1),

    .is_full_0(is_full_0),
    .is_empty_0(is_empty_0),

    .is_full_1(is_full_1),
    .is_empty_1(is_empty_1)


);

wire [`PRF_BUS] free_list0;
wire [`PRF_BUS] free_list1;
wire is_full_0;
wire is_empty_0;
wire is_full_1;
wire is_empty_1;

endmodule
