//2022.8.16 xuxin
`include "defines.v"

module Issue_Queue_M#(
    parameter QUEUE_NUM = 8,
    parameter QUEUE_WID = 23,  //{6D, 1dv, 6SL, 1lv, 6SR, 1rv,    , 1lready, 1rready,  1I}
    parameter QUEUE_IND = 3 //{Dest_0, SrcL_0, SrcL_ena_0, SrcR_0, SrcR_ena_0}
)(
    input wire reset,
    input wire clock,

    input wire wen_0,
    input wire [`PRF_BUS] Dest_0,
    //input wire RdyL_0,
    input wire SrcL_ena_0,
    input wire [`PRF_BUS] SrcL_0,
    //input wire RdyR_0,
    input wire SrcR_ena_0,
    input wire [`PRF_BUS] SrcR_0,

    input wire ren_0,          //old
    input wire [QUEUE_IND-1 : 0] ridx_0,
    output wire [`PRF_BUS] SrcL_0_o,
    output wire [`PRF_BUS] SrcR_0_o,


    input wire wen_1,
    input wire [`ALU_BUS] OP,     //////////////////////
    input wire [`PRF_BUS] Dest_1, 
    //input wire RdyL_1,
    input wire SrcL_ena_1,
    input wire [`PRF_BUS] SrcL_1,
    //input wire RdyR_1,
    input wire SrcR_ena_1,
    input wire [`PRF_BUS] SrcR_1,

    input wire ren_1,            //new
    input wire [QUEUE_IND-1 : 0] ridx_1,
    output wire [`PRF_BUS] SrcL_1_o,
    output wire [`PRF_BUS] SrcR_1_o,

    input wire [`PRF_BUS] tag0,


    output wire is_full_0,
    output wire is_empty_0,

    output wire is_full_1,
    output wire is_empty_1,

    input wire Issue[QUEUE_NUM-1],         ///////////////////////
    output wire Request[QUEUE_NUM-1],      ///////////////////////

);

    reg [QUEUE_WID-1 : 0] Issue_Queue[0 : QUEUE_NUM-1];

    //----------------------------is_read?---is_write?----------------------------------------
    assign is_full_0  = (write_index == QUEUE_NUM);
    assign is_empty_0 = (write_index == 0);
    assign is_full_1  = (write_index+1 == QUEUE_NUM) | is_full_0;
    assign is_empty_1 = (write_index-1 == 0) | is_empty_0;

    wire read_two = ren_0 & ren_1 & !is_empty_1;
    wire read_one = ren_0 | ren_1 & !is_empty_0;
    wire read_zero = !(read_two | read_one);
    wire write_two = wen_1 & wen_0 & !is_full_1;
    wire write_one = wen_1 | wen_0 & !is_full_0;
    wire write_zero = !(write_two | write_one);

    //--------------------------------index--------------------------------------------------
    wire [QUEUE_IND : 0] write_index_data = (write_two & read_zero)                          ? write_index + 2 :
                                            (write_two & read_one) | (write_one & read_zero) ? write_index + 1 :
                                            (read_two & write_one) | (read_one & write_zero) ? write_index - 1 :
                                            (read_two & write_zero)                          ? write_index - 2 :
                                            write_index;
    reg [QUEUE_IND : 0] write_index;
    always @(posedge clock) begin
        if(reset) begin
            write_index <= 0;
        end
        else begin
            write_index <= write_index_data;
        end
    end


    //-------------------------------Compressing-----------------------------------------------
    wire [QUEUE_WID-1 : 0] Issue_Queue_data[0 : QUEUE_NUM-1];
    wire up_up[QUEUE_NUM-2], up[QUEUE_NUM-2];

    //      --------------------------up------------------------  
    genvar u;                             
    generate
    for(u = 0; u < QUEUE_NUM-2; u=u+1) begin
        assign up_up[u] = up[u] & !{{1'b0, ridx_1} - u}[QUEUE_IND];
        assign    up[u] = !{{1'b0, ridx_0} - u}[QUEUE_IND];
    end
    endgenerate
    assign    up[QUEUE_NUM-2] = !{{1'b0, ridx_0} - (QUEUE_NUM-2)}[QUEUE_IND];


    //      ------------Issue_Queue_write---------------  
    assign Issue_Queue_data[0][QUEUE_IND-1 : 3] = (write_index   == 0) & write_one ? (wen_0 ? {Dest_0, SrcL_0, SrcL_ena_0, SrcR_0, SrcR_ena_0} : {Dest_1, SrcL_1, SrcL_ena_1, SrcR_1, SrcR_ena_1}) :                    
                                                  up_up[0] ? Issue_Queue_data[2] : up[0] ? Issue_Queue_data[1] : Issue_Queue_data[0];
    genvar q;                             
    generate
    for(q = 1 ; q < QUEUE_NUM-2; q = q + 1) begin
        assign Issue_Queue_data[q][QUEUE_IND-1 : 3] = (write_index+1 == q) & write_two ? {Dest_1, SrcL_1, SrcL_ena_1, SrcR_1, SrcR_ena_1} :
                                                      (write_index   == q) & write_one ? (wen_0 ? {Dest_0, SrcL_0, SrcL_ena_0, SrcR_0, SrcR_ena_0} : {Dest_1, SrcL_1, SrcL_ena_1, SrcR_1, SrcR_ena_1}) :                    
                                                      up_up[q] ? Issue_Queue_data[q+2] : up[q] ? Issue_Queue_data[q+1] : Issue_Queue_data[q];
    end
    endgenerate
    assign Issue_Queue_data[QUEUE_NUM-2][QUEUE_IND-1 : 3] = (write_index+1 == QUEUE_NUM-2) & write_two ? {Dest_1, SrcL_1, SrcL_ena_1, SrcR_1, SrcR_ena_1} :
                                                            (write_index   == QUEUE_NUM-2) & write_one ? (wen_0 ? {Dest_0, SrcL_0, SrcL_ena_0, SrcR_0, SrcR_ena_0} : {Dest_1, SrcL_1, SrcL_ena_1, SrcR_1, SrcR_ena_1}) :                    
                                                            up[QUEUE_NUM-2] ? Issue_Queue_data[QUEUE_NUM-1] : Issue_Queue_data[QUEUE_NUM-2];
    assign Issue_Queue_data[QUEUE_NUM-1][QUEUE_IND-1 : 3] = (write_index+1 == QUEUE_NUM-1) & write_two ? {Dest_1, SrcL_1, SrcL_ena_1, SrcR_1, SrcR_ena_1} :
                                                            (write_index   == QUEUE_NUM-1) & write_one ? (wen_0 ? {Dest_0, SrcL_0, SrcL_ena_0, SrcR_0, SrcR_ena_0} : {Dest_1, SrcL_1, SrcL_ena_1, SrcR_1, SrcR_ena_1}) :                    
                                                            Issue_Queue_data[QUEUE_NUM-1];
    always @(posedge clock) begin
        if(reset)begin
            for(i = 0; i < QUEUE_NUM; i=i+1) begin
                Issue_Queue[i] <= 0;     
            end
        end
        else begin
            for(i = 0; i < QUEUE_NUM; i=i+1) begin
                Issue_Queue[i][QUEUE_IND-1 : 3] <= Issue_Queue_data[i][QUEUE_IND-1 : 3];     
            end
        end
    end
    

    //-----------------------------------read-----------------------------------------------------
    assign SrcL_0_o = read_one ? Issue_Queue[ridx_0][16 : 11] : 0;
    assign SrcR_0_o = read_one ? Issue_Queue[ridx_0][ 9 :  4] : 0;
    assign SrcL_1_o = read_two ? Issue_Queue[ridx_1][16 : 11] : 0;
    assign SrcR_1_o = read_two ? Issue_Queue[ridx_1][ 9 :  4] : 0;


    //----------------------------------Wake_up---------------------------------------------- 
    wire RdyL[QUEUE_NUM-1], RdyR[QUEUE_NUM-1];
    genvar r;
    generate
    for(r = 0; r < QUEUE_NUM; r=r+1) begin
        assign Request[r] = !Issue_Queue[r][0] & (!Issue_Queue[r][10] | Issue_Queue[r][2]) & (!Issue_Queue[r][3] | Issue_Queue[r][1]);
        assign RdyL[r] = (Issue_Queue[r][16 : 11] == tag0); 
        assign RdyR[r] = (Issue_Queue[r][ 9 :  4] == tag0);

        always @(posedge clock) begin
            Issue_Queue[r][2 : 0] <= {RdyL[r], RdyR[r], Issue[r]};
        end
    end
    endgenerate






    

endmodule
