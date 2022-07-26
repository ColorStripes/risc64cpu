//2022.6.23 xuxin
`include "defines.v"

module ysyx_22040931_Regfile(
	input  wire reset,
    input  wire clock,

	input  wire 		  w_ena,
	input  wire  [4  : 0] w_addr,
	input  wire  [`ysyx_22040931_DATA_BUS]  w_data,
	
	input  wire 		  r_ena1,
	input  wire  [4  : 0] r_addr1,
	output reg   [`ysyx_22040931_DATA_BUS] r_data1,      //OUT1
	
	input  wire 		  r_ena2,
	input  wire  [4  : 0] r_addr2,
	output reg   [`ysyx_22040931_DATA_BUS] r_data2,       //OUT2

	//difftest
	output wire [`ysyx_22040931_DATA_BUS] regs_o[0 : 31]

);
reg [`ysyx_22040931_DATA_BUS]	regs[0 : 31];

    integer i;
    always @(posedge clock)
    begin
        if ( reset == 1'b1 )
        begin
            for (i = 0; i < `ysyx_22040931_REG; i = i + 1) begin
                regs[i] <= `ysyx_22040931_ZERO_NUM;      //0
            end
        end
        else
        begin
            if ((w_ena == 1'b1) && (w_addr != 5'h00))	
				regs[w_addr] <= w_data;
        end
    end


//  assign r_data1 = regs[r_addr1];
//  assign r_data2 = regs[r_addr2];

    //read
    always @(*) begin
		if (reset == 1'b1) begin
			r_data1 = `ysyx_22040931_ZERO_NUM;
		end
		else if (r_ena1 == 1'b1) begin
			if((r_addr1 == w_addr) && (w_addr != 5'h00) && w_ena) begin
				r_data1 = w_data;
			end
			else begin
				r_data1 = regs[r_addr1];
			end
		end
		else begin
			r_data1 = `ysyx_22040931_ZERO_NUM;
		end
	end
	
	always @(*) begin
		if (reset == 1'b1) begin
			r_data2 = `ysyx_22040931_ZERO_NUM;
		end
		else if (r_ena2 == 1'b1) begin
			if((r_addr2 == w_addr) && (w_addr != 5'h00) && w_ena) begin
				r_data2 = w_data;
			end
			else begin
				r_data2 = regs[r_addr2];
			end
		end	
		else begin
			r_data2 = `ysyx_22040931_ZERO_NUM;
		end
	end	
	
// import "DPI-C" function void set_gpr_ptr(input logic [63:0] a []);
// initial set_gpr_ptr(regs);  // rf为通用寄存器的二维数组变量




	genvar j;
	generate
		for (j = 0; j < 32; j = j + 1) begin
			assign regs_o[j] = (w_ena & w_addr == j & j != 0) ? w_data : regs[j];
		end
	endgenerate




endmodule
