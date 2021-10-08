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
    input wire pc_con,
    input wire id_forecase,
    input wire error_branch,

    output reg wash,
    output reg if_forecase,
    output reg [`PC_BUS] pc
);
    integer i;
    reg [1 : 0] fore;
    reg [`PC_BUS] fore_branch[`FORECASE-1 : 0];
    reg [`PC_BUS] pc_now[3 : 0];

    reg [1 : 0] fore_reg;
    reg [`PC_BUS] fore_branch_reg[`FORECASE-1 : 0];
    reg [`PC_BUS] pc_now_reg[3 : 0];
    

    reg [`PC_BUS] pc_s; // pc_id + 4
    reg ifa;  //former if_forecase
    //reg error_branch;  //if branch != forecase_branch when mux_pc==1



always @(posedge clk) begin
    if(rst == 1'b1) begin
        fore = 2'b00;
        pc_s = `ZERO_WORD;        
        //error_branch = 1'b0;
        for(i=0; i<`PC; i=i+1) begin
            pc_now[i] = `ZERO_WORD; 
        end
        for(i=0; i<`FORECASE; i=i+1) begin
            fore_branch[i] = `ZERO_WORD; 
        end
    end
    else begin
        //fore = fore_reg;
        //pc_now = pc_now_reg;
        //fore_branch = fore_branch_reg;
        //pc_s = `ZERO_WORD;
        //error_branch = 1'b0;

        if((timeo < 2) || (pc_id != `PC_START)) begin
            if(mux_pc == 1'b1) begin
                pc_s = pc_id + 4;
                if(fore_branch[pc_s[`FORECASE_LOG+1 : 2]] != branch) begin
                    //error_branch = 1'b1;
                    fore_branch[pc_s[`FORECASE_LOG+1 : 2]] = branch; 
                    pc_now[pc_s[`PC_LOG+1 : 2]] = pc_id + 4;
                end
                if(fore < 2'b11) begin
                    fore = fore + 1;
                end
            end
            
            else begin
                if(add_pc == pc_now[add_pc[`PC_LOG+1 : 2]]) begin
                    if(fore > 2'b00) begin
                        fore = fore - 1;
                    end
                end
            end
        end

    end
end

always @(posedge clk) begin
        fore_reg = fore;
        pc_now_reg = pc_now;
        fore_branch_reg = fore_branch;
end


    always @(*) begin
        if(rst == 1'b1) begin
            wash = 1'b0;
            pc = `ZERO_WORD;
            if_forecase = 1'b0;
        end
        else begin
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
                    end
                end
                
                if(mux_pc == 1'b0) begin
                    if(mux_pc != id_forecase) begin
                        wash = 1'b1;
                        pc = pc_id + 4;
                    end
                end


            end
        end
    end

    reg [1 : 0] timeo;

always @(posedge clk) begin   //count
    if(rst == 1'b1) begin
        timeo <= 1'b0;
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