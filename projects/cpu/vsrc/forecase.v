//2021.8.15
//xu xin
`include "defines.v"


module forecase (
    input wire rst,
    input wire clk,
    input wire mux_pc,
    input wire [`PC_BUS] pc_id,
    input wire [`PC_BUS] add_pc,
    input wire [`PC_BUS] branch,

    output reg wash,
    output reg [`PC_BUS] pc
);
    reg [1 : 0] fore;//
    reg [`PC_BUS] fore_branch[`FORECASE-1 : 0];//
    reg [`PC_BUS] pc_now[3 : 0];//
    reg if_forecase;//

    always @(posedge clk) begin
        if(rst == 1'b1) begin
            wash = 1'b0;
            pc = `ZERO_WORD;
            if_forecase = 1'b0;
        end
        else begin
            if(mux_pc == 1'b1) begin
                if(fore_branch[pc_id[`FORECASE_LOG+1 : 2]] != branch) begin

                    fore_branch[pc_id[`FORECASE_LOG+1 : 2]] = branch; 
                    pc_now[pc_id[3 : 2]] = pc_id;

                end
            end


            if(mux_pc != if_forecase) begin
                wash = 1'b1;
                pc = branch;
            end
            else begin
                wash = 1'b0;
                pc = add_pc;
            end

            if(add_pc == pc_now[add_pc[3 : 2]] + 4) begin
                if(fore >= 2'b10) begin
                    pc = fore_branch[add_pc[`FORECASE_LOG+1 : 2]];
                    if_forecase = 1'b1;
                end
                else begin
                    pc = add_pc;
                    if_forecase = 1'b0;
                end
            end
            else begin
                if_forecase = 1'b0;
            end

        end
    end

   always @(*) begin
        if(rst == 1'b1) begin
            fore = 2'b00;
        end
        else begin
            if(add_pc == pc_now[add_pc[3 : 2]] + 4) begin
                if(mux_pc >= 1'b1) begin
                    if(fore < 2'b11) begin
                    fore = fore + 1;
                    end
                end
                else begin
                    if(fore > 2'b00) begin
                    fore = fore - 1;
                    end
                end
            end
        end
    end


endmodule