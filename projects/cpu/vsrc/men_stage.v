//xuxin
//2021.7.29
`include "defines.v"

module men_stage (
    input wire rst,
    input wire [4 : 0]inst_type_m,
    input wire [`REG_BUS] men_addr_i,
    input wire [`REG_BUS] men_data_i,

    output reg men_w_ena,
    output reg men_ld_ena,
    output reg [`REG_BUS] men_addr_o,
    output reg [`REG_BUS] men_data_o
);
    always @( * ) 
    begin
        if( rst == 1 )
        begin
            men_w_ena <= 0;
            men_ld_ena <= 0;
        end
        else 
        begin
            case(inst_type_m)
                 5'b10000:begin men_ld_ena <= 0;end
                 5'b01000:begin end
                 5'b00100:begin men_ld_ena <= 1; men_w_ena <= 1;end
                 default:begin  end
            endcase
        end

        
    end
endmodule