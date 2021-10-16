
//2021.8.15
//xu xin

`include "ysyx_210457_defines.v"

module ysyx_210457_forecase (
    input wire reset,
    input wire clock,
    input wire mux_pc,
    input wire [`PC_BUS] pc_id,
    input wire [`PC_BUS] add_pc,
    input wire [`PC_BUS] branch,
    input wire id_forecase,
    input wire error_branch,
    input wire stall,

    output reg wash,
    output reg if_forecase,
    output reg [`PC_BUS] pc
);
    integer i;
    reg [1 : 0] fore;
    reg [`PC_BUS] fore_branch[`FORECASE-1 : 0];
    reg [`PC_BUS] pc_now[`PC-1 : 0];




always @(posedge clock) begin
    if(reset == 1'b1) begin
        fore <= 2'b00;        
        for(i=0; i<`PC; i=i+1) begin
            pc_now[i] <= `ZERO_WORD; 
        end
        for(i=0; i<`FORECASE; i=i+1) begin
            fore_branch[i] <= `ZERO_WORD; 
        end
    end
    else begin

        if(~stall) begin
            if((timeo < 2) || (pc_id != `PC_START)) begin
                if(mux_pc == 1'b1) begin
                    if(fore_branch[{pc_id + 4}[`FORECASE_LOG+1 : 2]] != branch) begin
                        fore_branch[{pc_id + 4}[`FORECASE_LOG+1 : 2]] <= branch; 
                        pc_now[{pc_id + 4}[`PC_LOG+1 : 2]] <= pc_id + 4;
                    end
                    if(fore < 2'b11) begin
                        fore <= fore + 1;
                    end
                end
            
                else begin
                    if(pc_now[{pc_id + 4}[`PC_LOG+1 : 2]] == {pc_id + 4}) begin
                        if(fore > 2'b00) begin
                            fore <= fore - 1;
                        end
                    end
                end
            end
        end
    end
end



    always @(*) begin
        if(reset == 1'b1) begin
            wash = 1'b0;
            pc = `ZERO_WORD;
            if_forecase = 1'b0;
        end
        else begin
            wash = 1'b0;
            pc = add_pc;
            if_forecase = 1'b0;
            if(~stall) begin
                wash = 1'b0;
                pc = add_pc;
                if_forecase = 1'b0;
                if((timeo < 2) || (pc_id != `PC_START)) begin
                    if(add_pc == pc_now[add_pc[`PC_LOG + 1 : 2]]) begin
                        if(fore >= 2'b10) begin
                            pc = fore_branch[add_pc[`FORECASE_LOG + 1 : 2]];
                            if_forecase = 1'b1;
                        end
                        else begin
                            pc = add_pc;
                            if_forecase = 1'b0;
                        end
                    end
                    else begin
                        if_forecase = 1'b0;
                        pc = add_pc;
                    end

                    if(mux_pc == 1'b1) begin
                        if((mux_pc != id_forecase) || (error_branch)) begin  
                           wash = 1'b1;
                           pc = branch;
                           if_forecase = 1'b0;
                        end
                    end
                
                    if(mux_pc == 1'b0) begin
                        if(mux_pc != id_forecase) begin
                            wash = 1'b1;
                            pc = pc_id + 4;
                            if_forecase = 1'b0;
                        end
                    end
                    
                end
            end
        end
    end

    

reg [1 : 0] timeo;
always @(posedge clock) begin   //count
    if(reset == 1'b1) begin
        timeo <= 2'b0;
    end
    else begin
        if(pc_id == `PC_START) begin
           if(timeo < 2) begin
               timeo <= timeo + 1 ;
           end
        end
    end
end


endmodule