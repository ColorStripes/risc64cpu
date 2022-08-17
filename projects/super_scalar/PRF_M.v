//2122.8.14 xuxin
`include "defines.v"

module PRF_M#(
    parameter PRF_NUM = 64,
    parameter PRF_WID = 6
)(
    input wire reset,
    input wire clock,

    input wire r_ena1_0,
    input wire [PRF_WID-1 : 0] r_addr1_0,
    output wire [`DATA_BUS] r_data1_0,
    input wire r_ena2_0,
    input wire [PRF_WID-1 : 0] r_addr2_0,
    output wire [`DATA_BUS] r_data2_0,
    input wire w_ena_0,
    input wire [PRF_WID-1 : 0] w_addr_0,
    input wire [`DATA_BUS] w_data_0,



    input wire r_ena1_1,
    input wire [PRF_WID-1 : 0] r_addr1_1,
    output wire [`DATA_BUS] r_data1_1,
    input wire r_ena2_1,
    input wire [PRF_WID-1 : 0] r_addr2_1,
    output wire [`DATA_BUS] r_data2_1,
    input wire w_ena_1,
    input wire [PRF_WID-1 : 0] w_addr_1,
    input wire [`DATA_BUS] w_data_1,


);

    reg [PRF_WID-1 : 0] PRF[0 : PRF_NUM-1];



    //write
    integer i;
    wire PRF_data0 = (w_ena_0 && (w_addr_0 != `ZERO_PRF)) ? w_data_0 : PRF[w_addr_0];
    wire PRF_data1 = (w_ena_1 && (w_addr_1 != `ZERO_PRF)) ? w_data_1 : PRF[w_addr_1];
    always @(posedge clock) begin
        if(reset)begin
            for (i = 0; i < PRF_NUM; i = i + 1) begin
                PRF[i] <= `ZERO_NUM;      
            end
        end
        else begin
			PRF[w_addr_0] <= PRF_data0;
            PRF[w_addr_1] <= PRF_data1;
        end
    end
    

    //read
    assign r_data1_0 = r_ena1_0 ? PRF[r_addr1_0] : `ZERO_NUM;
    assign r_data2_0 = r_ena2_0 ? PRF[r_addr2_0] : `ZERO_NUM;
    assign r_data1_1 = r_ena1_1 ? PRF[r_addr1_1] : `ZERO_NUM;
    assign r_data2_1 = r_ena2_1 ? PRF[r_addr2_1] : `ZERO_NUM;



endmodule
