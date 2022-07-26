//2022.7.18 xuxin
`include "defines.v"

module target_predictor(
    input wire reset,
    input wire clock,
    input wire valid_pre,
    input wire [`ysyx_22040931_PC_BUS] pc,
    input wire [`ysyx_22040931_PC_BUS] id_pc,
    input wire [`ysyx_22040931_PC_BUS] id_branch, 
    input wire [1 : 0] id_jumptype,  //11ret 10call


    output wire [`ysyx_22040931_PC_BUS] branch,
    output wire hit
    
);

    reg [`ysyx_22040931_BTB_WIDTH-1 : 0] BTB1[`ysyx_22040931_BTB_SIZE-1 : 0];
    //reg [`ysyx_22040931_BTB_WIDTH-1 : 0] BTB2[`ysyx_22040931_BTB_SIZE-1 : 0];

    wire [7 : 0] btb_index; 
    assign btb_index = pc[9 : 2];
    wire [7 : 0] id_btb_index; 
    assign id_btb_index = id_pc[9 : 2];

    wire [1 : 0] jumptype;
    assign jumptype = {BTB1[btb_index]}[1 : 0];
    assign hit = ({BTB1[btb_index]}[`ysyx_22040931_BTB_WIDTH-1 : `ysyx_22040931_BTB_WIDTH-32] == pc[31 : 0]) ? 1'b1 : 1'b0;
    assign branch = ({BTB1[btb_index]}[1 : 0] == 2'b11) ? RAS[ras_index - 1] : {BTB1[btb_index]}[`ysyx_22040931_BTB_WIDTH-33 : 2];

    integer i,j;
    always@(posedge clock) begin
        if(reset == 1'b1) begin
            for(i = 0; i < 64; i = i+1) begin
                BTB1[i] <= 0;
            end
            for(i = 64; i < 128; i = i+1) begin
                BTB1[i] <= 0;
            end
            for(i = 128; i < 192; i = i+1) begin
                BTB1[i] <= 0;
            end
            for(i = 192; i < `ysyx_22040931_BTB_SIZE; i = i+1) begin
                BTB1[i] <= 0;
            end
        end
        else begin
            if(id_jumptype != 0) begin
                BTB1[id_btb_index] <= {id_pc[31 : 0], id_branch, id_jumptype};
            end
        end
    end
     


    //RAS
    reg [`ysyx_22040931_PC_BUS] RAS[0 : `ysyx_22040931_RAS_SIZE-1];
    reg [`ysyx_22040931_RAS_INDEX-1 : 0] ras_index;

    always@(posedge clock) begin
        if(reset == 1'b1) begin
            for(j = 0; j < `ysyx_22040931_RAS_SIZE; j = j+1) begin
                RAS[j] <= `ysyx_22040931_ZERO_PC;
            end
            ras_index <= 0;
        end
        else begin
            if(valid_pre) begin
                if(jumptype == 2'b11) begin
                    ras_index <= ras_index - 1;
                end
                else if(jumptype == 2'b10) begin
                    RAS[ras_index] <= pc + 4;     //pc
                    ras_index <= ras_index + 1;
                end
            end
        end
    end

endmodule
