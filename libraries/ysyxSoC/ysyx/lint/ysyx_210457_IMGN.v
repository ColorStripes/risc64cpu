//2021.8.3
//xuxin
`include "defines.v"


module ysyx_210457_IMGN (
    input wire [31:0] instr,

    output reg [63 : 0] imm
);

    wire [4 : 0] op;
    assign op[4] = (~instr[6] & ~instr[5] & ~instr[2]) | (instr[6] & instr[5] & ~instr[3] & instr[2]) | (instr[6] & instr[5] & instr[4]);
    assign op[3] = ~instr[6] & instr[5] & ~instr[4];
    assign op[2] = instr[6] & instr[5] & ~instr[4] & ~instr[2];
    assign op[1] = instr[6] & instr[5] & instr[3];
    assign op[0] = (~instr[6] & instr[5] & instr[2]) | (~instr[6] & ~instr[5] & instr[2]);

    always @ (*) begin
        case(op)
             5'b10000://I-type
             begin
                 imm = {{52{instr[31]}}, instr[31:20]};
             end
             5'b01000://S-type
             begin
                 imm = {{52{instr[31]}}, instr[31:25], instr[11:7]};
             end
             5'b00100://B-type
             begin
                 imm = {{51{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
             end
             5'b00010://J-type
             begin
                 imm = {{43{instr[31]}}, instr[31], instr[19 : 12], instr[20], instr[30 : 21], 1'b0};
             end
             5'b00001://U_type
             begin
                 imm = {{32{instr[31]}}, instr[31 : 12], 12'h000};  //ex alu had <<12
             end
             default:
             begin
                 imm = `ZERO_WORD;
             end
         endcase
    end

endmodule