//2021.8.3 -> 2021.8.12
//xuxin

`include "defines.v"
module DATA_MEN (
    input wire clk,
    input wire [63 : 0] addr,
    input wire [63 : 0] w_data,
    input wire [7 : 0] sel,
    input wire ena,
    input wire w_r,

    output reg [63 : 0] data
);
    
    reg [`DATA_BUS] d_mem1 [0 : `D_NUM-1];
    reg [`DATA_BUS] d_mem2 [0 : `D_NUM-1];
    reg [`DATA_BUS] d_mem3 [0 : `D_NUM-1];
    reg [`DATA_BUS] d_mem4 [0 : `D_NUM-1];
    reg [`DATA_BUS] d_mem5 [0 : `D_NUM-1];
    reg [`DATA_BUS] d_mem6 [0 : `D_NUM-1];
    reg [`DATA_BUS] d_mem7 [0 : `D_NUM-1];
    reg [`DATA_BUS] d_mem8 [0 : `D_NUM-1];

    always @ (*) begin
        if(ena == 1'b0) begin
            data = `ZERO_WORD;
        end
        else begin
            if(w_r == 1'b0) begin
                data = { d_mem8[addr[`D_NUMLOG+1 : 2]], d_mem7[addr[`D_NUMLOG+1 : 2]], 
                         d_mem6[addr[`D_NUMLOG+1 : 2]], d_mem5[addr[`D_NUMLOG+1 : 2]],
                         d_mem4[addr[`D_NUMLOG+1 : 2]], d_mem3[addr[`D_NUMLOG+1 : 2]],
                         d_mem2[addr[`D_NUMLOG+1 : 2]], d_mem1[addr[`D_NUMLOG+1 : 2]]};
            end
            else begin
                data = `ZERO_WORD;
            end
        end
    end

    always @ (posedge clk) begin
        if(ena == 1'b0) begin
            data = `ZERO_WORD;
        end
        else begin
            if(w_r == 1'b1) begin
                if(sel[7] == 1'b1) begin
                    d_mem8[addr[`D_NUMLOG+1 : 2]] <= w_data[63 : 56];
                end
                if(sel[6] == 1'b1) begin
                    d_mem7[addr[`D_NUMLOG+1 : 2]] <= w_data[55 : 48];
                end
                if(sel[5] == 1'b1) begin
                    d_mem6[addr[`D_NUMLOG+1 : 2]] <= w_data[47 : 40];
                end
                if(sel[4] == 1'b1) begin
                    d_mem5[addr[`D_NUMLOG+1 : 2]] <= w_data[39 : 32];
                end
                if(sel[3] == 1'b1) begin
                    d_mem4[addr[`D_NUMLOG+1 : 2]] <= w_data[31 : 24];
                end
                if(sel[2] == 1'b1) begin
                    d_mem3[addr[`D_NUMLOG+1 : 2]] <= w_data[23 : 16];
                end
                if(sel[1] == 1'b1) begin
                    d_mem2[addr[`D_NUMLOG+1 : 2]] <= w_data[15 : 8];
                end
                if(sel[0] == 1'b1) begin
                    d_mem1[addr[`D_NUMLOG+1 : 2]] <= w_data[7 : 0];
                end
            end
        end
    end
endmodule        