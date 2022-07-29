//2022.7.23 xuxin
`include "defines.v"

module csa(

  input [131:0] in[2 : 0],

  output [131:0] cout,s

);


genvar i;
generate
for(i = 0; i < 131; i = i + 1) begin:CAR132
    csa_1 csa_1(

        .in({in[2][i], in[1][i], in[0][i]}),
        .cout(cout[i+1]),
        .s(s[i])

    );
end
endgenerate


    csa_1 csa_132(

        .in({in[2][131], in[1][131], in[0][131]}),
        .cout(),
        .s(s[131])

    );

endmodule
