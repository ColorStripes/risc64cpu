//2022.8.14 xuxin
`include "defines.v"

module FREE_LIST_M#(

    parameter FREE_LIST_NUM = 64,
    parameter FREE_LIST_WID = $clog2(FREE_LIST_NUM)

)(
    input wire reset,
    input wire clock,
    input wire wen_0,
    input wire [FREE_LIST_WID-1 : 0] w_data_0,
    input wire ren_0,
    output wire [FREE_LIST_WID-1 : 0] r_data_0,

    input wire wen_1,
    input wire [FREE_LIST_WID-1 : 0] w_data_1,
    input wire ren_1,
    output wire [FREE_LIST_WID-1 : 0] r_data_1,

    output wire is_full_0,
    output wire is_empty_0,

    output wire is_full_1,
    output wire is_empty_1


);


    //----------------------------is_read?---is_write?----------------------------------------
    assign is_full_0  = (read_index[FREE_LIST_WID-1 : 0] == write_index[FREE_LIST_WID-1 : 0]) && (read_index[FREE_LIST_WID] ^ write_index[FREE_LIST_WID]);
    assign is_empty_0 = (read_index == write_index);
    assign is_full_1  = (((read_index+1)[FREE_LIST_WID-1 : 0] == write_index[FREE_LIST_WID-1 : 0]) && ((read_index+1)[FREE_LIST_WID] ^ write_index[FREE_LIST_WID])) | is_full_0;
    assign is_empty_1 = (read_index+1 == write_index) | is_empty_0;

    wire read_two = ren_0 & ren_1 & ! is_empty_1;
    wire read_one = ren_0 | ren_1 & ! is_empty_0;
    wire write_two = wen_1 & wen_0 & !is_full_1;
    wire write_one = wen_1 | wen_0 & !is_full_0;
    

    //--------------------------------index--------------------------------------------------
    wire [FREE_LIST_WID : 0] read_index_data  = read_two ? read_index + 2 : 
                                                read_one ? read_index + 1 :
                                                read_index;
    wire [FREE_LIST_WID : 0] write_index_data = write_two ? write_index + 2 :
                                                write_one ? write_index + 1 :
                                                write_index;

    reg [FREE_LIST_WID : 0] read_index, write_index;
    always @(posedge clock) begin
        if(reset) begin
            read_index  <= 0;
            write_index <= 63;
        end
        else begin
            read_index  <= read_index_data;
            write_index <= write_index_data;
        end
    end

    //-------------------------------write--------------------------------------------------- 
    reg [FREE_LIST_WID-1 : 0] FREE_LIST[0 : FREE_LIST_NUM-1];
    wire [FREE_LIST_WID-1 : 0] FREE_LIST_data_0 = write_one ? wen_0 ? w_data_0 : w_data_1 :
                                                  FREE_LIST[write_index];
    wire [FREE_LIST_WID-1 : 0] FREE_LIST_data_1 = write_two ? w_data_1 : FREE_LIST[write_index+1];
    always @(posedge clock) begin
        if(reset) begin
            for(i = 0; i < FREE_LIST_NUM; i=i+1) begin
                FREE_LIST[i] = i;      //0~63
            end
        end
        else begin
            FREE_LIST[write_index[FREE_LIST_WID-1 : 0]  ] = FREE_LIST_data_0;
            FREE_LIST[write_index[FREE_LIST_WID-1 : 0]+1] = FREE_LIST_data_1;
        end
    end


    //--------------------------------read-----------------------------------------------------
    assign r_data_0 = read_one ? FREE_LIST[r_index[FREE_LIST_WID-1 : 0]  ] : `ZERO_PRF;
    assign r_data_1 = read_two ? FREE_LIST[r_index[FREE_LIST_WID-1 : 0]+1] : `ZERO_PRF;



endmodule
