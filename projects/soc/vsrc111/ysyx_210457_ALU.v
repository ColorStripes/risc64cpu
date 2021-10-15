
//2021.7.25
//xuxin

`include "defines.v"

module ysyx_210457_ALU(
    input wire [63:0] num1,
    input wire [63:0] num2,
    input wire [6:0] op,

    output reg [63:0] out
);
wire signed [63 : 0] num1_s;
wire signed [31 : 0] num1_sw;

assign num1_s = num1;
assign num1_sw = num1[31 : 0];
 
    always @(*) begin
        case (op)
            7'b0000_001: begin
                out = num1 + num2;
            end
            7'b0000_010: begin
                out = num1 - num2;
            end
            7'b0000_100: begin
                out = num1 & num2;
            end
            7'b0001_000: begin
                out = num1 | num2;
            end
            7'b0010_000: begin
                out = num1 ^ num2;
            end
            7'b0100_000: begin
                out = ~num1;
            end
            7'b1000_000: begin
                out = ~num2;
            end
            7'b0000_110: begin
                if(num1[63] == num2[63]) begin
                    if(num1[62 :0] < num2[62 :0]) begin
                        out = 1;
                    end
                    else begin
                        out = 0;
                    end
                end
                else begin
                    if(num1[63] > num2[63]) begin
                        out = 1;
                    end
                    else begin
                        out = 0;
                    end
                end
            end
            7'b0000_011: begin
                if(num1 < num2)
                out = 1;
                else
                out = 0;
            end
            7'b0001_100:begin
                out = num1 << num2[5 : 0];
            end
            7'b0001_101:begin
                out = num1 << num2[4 : 0];
            end
            7'b0011_000:begin
                out = num1 >> num2[5 : 0];
            end
            7'b0011_001:begin
                out = {{32{1'b0}} , {num1[31 : 0] >> num2[4 : 0]}};
            end
            7'b0110_000:begin
                //num1_s = num1;
                out =  num1_s >>> num2[5 : 0];
            end    
            7'b0110_001:begin
                //num1_sw = num1[31 : 0];
                out =  {{32{num1_sw[31]}} , {num1_sw >>> num2[4 : 0]}};
            end   
            7'b1100_000:begin
                out = num1 << 12;
            end       
            default: begin
                out = 64'h00000000_00000000;
            end
        endcase
    end
endmodule