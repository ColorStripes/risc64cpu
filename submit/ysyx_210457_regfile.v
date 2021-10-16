
`timescale 1ns / 1ps

`define ZERO_WORD  64'h00000000_00000000
`define ZERO_PC    64'h00000000_00000000
`define ZERO_ADDR  32'h00000000
`define ZERO_INST  32'h00000000    
`define REG_BUS    63 : 0 
`define PC_BUS     63 : 0 
`define ADDR_BUS   31 : 0  
`define INST_BUS   31 : 0 
`define ZERO_ENA   1'b0
`define ZERO_REG_ADDR   5'b00000
`define PC_START   64'h00000000_30000000 

module ysyx_210457_regfile(
    input  wire clock,
	input  wire reset,
	
	input  wire  [4  : 0] w_addr,
	input  wire  [`REG_BUS] w_data,
	input  wire 		  w_ena,
	
	input  wire  [4  : 0] r_addr1,
	input  wire 		  r_ena1,
	output reg   [`REG_BUS] r_data1,  //OUT1

	input  wire  [4  : 0] r_addr2,
	input  wire 		  r_ena2,
	output reg   [`REG_BUS] r_data2   //OUT2


    );

    // 32 registers
	reg [`REG_BUS] 	regs[0 : 31];
	
	always @(posedge clock) 
	begin
		if ( reset == 1'b1 ) 
		begin
			regs[ 0] <= `ZERO_WORD;  //0
			regs[ 1] <= `ZERO_WORD;
			regs[ 2] <= `ZERO_WORD;
			regs[ 3] <= `ZERO_WORD;
			regs[ 4] <= `ZERO_WORD;
			regs[ 5] <= `ZERO_WORD;
			regs[ 6] <= `ZERO_WORD;
			regs[ 7] <= `ZERO_WORD;
			regs[ 8] <= `ZERO_WORD;
			regs[ 9] <= `ZERO_WORD;
			regs[10] <= `ZERO_WORD;
			regs[11] <= `ZERO_WORD;
			regs[12] <= `ZERO_WORD;
			regs[13] <= `ZERO_WORD;
			regs[14] <= `ZERO_WORD;
			regs[15] <= `ZERO_WORD;
			regs[16] <= `ZERO_WORD;
			regs[17] <= `ZERO_WORD;
			regs[18] <= `ZERO_WORD;
			regs[19] <= `ZERO_WORD;
			regs[20] <= `ZERO_WORD;
			regs[21] <= `ZERO_WORD;
			regs[22] <= `ZERO_WORD;
			regs[23] <= `ZERO_WORD;
			regs[24] <= `ZERO_WORD;
			regs[25] <= `ZERO_WORD;
			regs[26] <= `ZERO_WORD;
			regs[27] <= `ZERO_WORD;
			regs[28] <= `ZERO_WORD;
			regs[29] <= `ZERO_WORD;
			regs[30] <= `ZERO_WORD;
			regs[31] <= `ZERO_WORD;
		end
		else 
		begin
			if ((w_ena == 1'b1) && (w_addr != 5'h00))	
				regs[w_addr] <= w_data;
		end
	end
	
	always @(*) begin
		if (reset == 1'b1) begin
			r_data1 = `ZERO_WORD;
		end
		else if (r_ena1 == 1'b1) begin
			if((r_addr1 == w_addr) && (w_addr != 5'h00) && (w_ena == 1'b1)) begin
				r_data1 = w_data;
			end
			else begin
				r_data1 = regs[r_addr1];
			end
		end
		else begin
			r_data1 = `ZERO_WORD;
		end
	end
	
	always @(*) begin
		if (reset == 1'b1) begin
			r_data2 = `ZERO_WORD;
		end
		else if (r_ena2 == 1'b1) begin
			if((r_addr2 == w_addr) && (w_addr != 5'h00) && (w_ena == 1'b1)) begin
				r_data2 = w_data;
			end
			else begin
				r_data2 = regs[r_addr2];
			end
		end	
		else begin
			r_data2 = `ZERO_WORD;
		end
	end


endmodule
