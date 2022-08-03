//2022.7.23 xuxin
`include "defines.v"

module walloc_33in(
    input wire [131 : 0]  src_in[32 : 0],


    output wire [131 : 0]    s,
    output wire [131 : 0] cout
);

wire [131 : 0] c[29:0];
///////////////first////////////////
wire [131 : 0] first_s[10:0];
csa csa0  (.in (src_in[32:30]), .cout (c[10]), .s (first_s[10]) );
csa csa1  (.in (src_in[29:27]), .cout (c[09]), .s (first_s[09]) );
csa csa2  (.in (src_in[26:24]), .cout (c[08]), .s (first_s[08]) );
csa csa3  (.in (src_in[23:21]), .cout (c[07]), .s (first_s[07]) );
csa csa4  (.in (src_in[20:18]), .cout (c[06]), .s (first_s[06]) );
csa csa5  (.in (src_in[17:15]), .cout (c[05]), .s (first_s[05]) );
csa csa6  (.in (src_in[14:12]), .cout (c[04]), .s (first_s[04]) );
csa csa7  (.in (src_in[11:09]), .cout (c[03]), .s (first_s[03]) );
csa csa8  (.in (src_in[08:06]), .cout (c[02]), .s (first_s[02]) );
csa csa9  (.in (src_in[05:03]), .cout (c[01]), .s (first_s[01]) );
csa csa10 (.in (src_in[02:00]), .cout (c[00]), .s (first_s[00]) );


wire [131 : 0] secnod_f14[2:0];
assign secnod_f14[2:1] = first_s[01:00];
assign secnod_f14[0] = c[09];
///////////////secnod//////////////
wire [131 : 0] secnod_s[6:0];
csa csa11 (.in (first_s[10:08]          ), .cout (c[17]), .s (secnod_s[6]) );
csa csa12 (.in (first_s[07:05]          ), .cout (c[16]), .s (secnod_s[5]) );
csa csa13 (.in (first_s[04:02]          ), .cout (c[15]), .s (secnod_s[4]) );
csa csa14 (.in (secnod_f14              ), .cout (c[14]), .s (secnod_s[3]) );
csa csa15 (.in (c[08:06]                ), .cout (c[13]), .s (secnod_s[2]) );
csa csa16 (.in (c[05:03]                ), .cout (c[12]), .s (secnod_s[1]) );
csa csa17 (.in (c[02:00]                ), .cout (c[11]), .s (secnod_s[0]) );

wire [131 : 0] thrid_f20[2:0];
assign thrid_f20[2] = secnod_s[0];
assign thrid_f20[1:0] = c[17:16];
//////////////thrid////////////////
wire [131 : 0] thrid_s[4:0];
csa csa18 (.in (secnod_s[6:4]           ), .cout (c[22]), .s (thrid_s[4]));
csa csa19 (.in (secnod_s[3:1]           ), .cout (c[21]), .s (thrid_s[3]));
csa csa20 (.in (thrid_f20               ), .cout (c[20]), .s (thrid_s[2]));
csa csa21 (.in (c[15:13]                ), .cout (c[19]), .s (thrid_s[1]));
csa csa22 (.in (c[12:10]                ), .cout (c[18]), .s (thrid_s[0]));

wire [131 : 0] fourth_f24[2:0];
assign fourth_f24[2:1] = thrid_s[1:0];
assign fourth_f24[0] = c[21];
//////////////fourth////////////////
wire [131 : 0] fourth_s[2:0];
csa csa23 (.in (thrid_s[4:2]           ),  .cout (c[25]), .s (fourth_s[2]));
csa csa24 (.in (fourth_f24             ),  .cout (c[24]), .s (fourth_s[1]));
csa csa25 (.in (c[20:18]               ),  .cout (c[23]), .s (fourth_s[0]));

//////////////fifth/////////////////
wire [131 : 0] fifth_s[1:0];
csa csa26 (.in (fourth_s[2:0]            ),  .cout (c[27]), .s (fifth_s[1]));
csa csa27 (.in (c[24 : 22]               ),  .cout (c[26]), .s (fifth_s[0]));


wire [131 : 0] sixth_f28[2:0];
assign sixth_f28[2:1] = fifth_s[1:0];
assign sixth_f28[0] = c[25];
///////////////sixth///////////////
wire [131 : 0] sixth_s;
csa csa28 (.in (sixth_f28                ),  .cout (c[28]),  .s  (sixth_s));


wire [131 : 0] seventh_f29[2:0];
assign seventh_f29[2] = sixth_s;
assign seventh_f29[1:0] = c[27:26];
///////////////seventh///////////////
wire [131 : 0] seventh_s;
csa csa29 (.in (seventh_f29               ),  .cout (c[29]),  .s  (seventh_s));


wire [131 : 0] eighth_f30[2:0];
assign eighth_f30[2] = seventh_s;
assign eighth_f30[1:0] = c[29:28];
///////////////eighth///////////////
csa csa30 (.in (eighth_f30                ),  .cout (cout),   .s  (s));

///////////////output///////////////
//assign cout_group = c;
endmodule