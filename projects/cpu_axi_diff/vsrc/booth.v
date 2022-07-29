//2022.7.22 xuxin
`include "defines.v"

module booth(
    input wire [64 : 0] multiplicand,
    input wire [64 : 0] multiplier,

    output wire [131 : 0] p[32 : 0]
);

    wire [133 : 0] x_src;
    assign x_src = {{68{multiplicand[64]}}, multiplicand, 1'b0};
    wire [66 : 0] y_src;
    assign y_src = {multiplier[64], multiplier, 1'b0}; //67


    wire [131 : 0] pp[32 : 0];
    genvar i;
    generate
    for(i = 0; i < 66; i = i + 2) begin
        
        booth_p booth_p(
        .x_src(x_src),           //{1'bf, 132 , 1'b0}
        .y_3(y_src[i+2 : i]), 
    
        .p(pp[i>>1])
        );
    
    end
    endgenerate

//move <----- 2 
assign p[0]  = {pp[0]};
assign p[1]  = {pp[1],2'b0}[131 : 0];
assign p[2]  = {pp[2],4'b0}[131 : 0];
assign p[3]  = {pp[3],6'b0}[131 : 0];
assign p[4]  = {pp[4],8'b0}[131 : 0];
assign p[5]  = {pp[5],10'b0}[131 : 0];
assign p[6]  = {pp[6],12'b0}[131 : 0];
assign p[7]  = {pp[7],14'b0}[131 : 0];
assign p[8]  = {pp[8],16'b0}[131 : 0];
assign p[9]  = {pp[9],18'b0}[131 : 0];
assign p[10] = {pp[10],20'b0}[131 : 0];
assign p[11] = {pp[11],22'b0}[131 : 0];
assign p[12] = {pp[12],24'b0}[131 : 0];
assign p[13] = {pp[13],26'b0}[131 : 0];
assign p[14] = {pp[14],28'b0}[131 : 0];
assign p[15] = {pp[15],30'b0}[131 : 0];
assign p[16] = {pp[16],32'b0}[131 : 0];
assign p[17] = {pp[17],34'b0}[131 : 0];
assign p[18] = {pp[18],36'b0}[131 : 0];
assign p[19] = {pp[19],38'b0}[131 : 0];
assign p[20] = {pp[20],40'b0}[131 : 0];
assign p[21] = {pp[21],42'b0}[131 : 0];
assign p[22] = {pp[22],44'b0}[131 : 0];
assign p[23] = {pp[23],46'b0}[131 : 0];
assign p[24] = {pp[24],48'b0}[131 : 0];
assign p[25] = {pp[25],50'b0}[131 : 0];
assign p[26] = {pp[26],52'b0}[131 : 0];
assign p[27] = {pp[27],54'b0}[131 : 0];
assign p[28] = {pp[28],56'b0}[131 : 0];
assign p[29] = {pp[29],58'b0}[131 : 0];
assign p[30] = {pp[30],60'b0}[131 : 0];
assign p[31] = {pp[31],62'b0}[131 : 0];
assign p[32] = {pp[32],64'b0}[131 : 0];


endmodule
