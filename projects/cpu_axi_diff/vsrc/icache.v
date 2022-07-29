//2022.7.29 xuxin
`include "defines.v"

module icache #(
    parameter I_TAG         = 21,
    parameter I_INDEX       = 6,
    parameter I_OFFSET      = 5,
    parameter TAG_RAM_NUM   = 64,
    parameter DATA_RAM_NUM  = 64,
    parameter DATA_RAM_WIDTH= 256,

)(
    input wire reset,
    input wire clock,
    //woshou
    input wire pc_valid,          //zhitong
    output wire icache_pc_ready,  //to cpu
    output wire icache_if_valid,
    input wire if_ready,
    //arbiter
    input wire arbiter_to_icache_valid,  //if_valid
    output wire to_arbiter_pc_valid, 
    output wire to_arbiter_if_ready,

    //read
    input wire [`ysyx_22040931_PC_BUS] address,
    input wire [`ysyx_22040931_DATA_BUS] arbiter_data,

    output wire hit,
    output wire [`ysyx_22040931_DATA_BUS] data,
    
);

    wire [I_TAG-1 : 0]    tag    = address[I_TAG-1 + I_OFFSE+I_INDEX : I_OFFSE+I_INDEX];
    wire [I_INDEX-1 : 0]  index  = address[I_INDEX-1 + I_OFFSET : I_OFFSET];
    wire [I_OFFSET-1 : 0] offset = address[I_OFFSET-1 : 0];

    //WAY0
    reg [I_TAG : 0] TAG_RAM_WAY0[0 : TAG_RAM_NUM-1];               //{1'valid, 21tag}
    reg [DATA_RAM_WIDTH-1 : 0] DATA_BLOCK_WAY0[0 : DATA_RAM_NUM-1];
    //WAY1
    reg [I_TAG : 0] TAG_RAM_WAY1[0 : TAG_RAM_NUM-1];               //{1'valid, 21tag}
    reg [DATA_RAM_WIDTH-1 : 0] DATA_BLOCK_WAY1[0 : DATA_RAM_NUM-1];

    //valid <= 0;
    integer i;
    always @(posedge clock) begin
        if(reset) begin
            for(i = 0; i < TAG_RAM_NUM; i = i + 1) begin
                TAG_RAM_WAY0[i][I_TAG] <= 1'b0;
                TAG_RAM_WAY1[i][I_TAG] <= 1'b0;
            end
        end
    end

    //hit
    wire way0_hit = ((TAG_RAM_WAY0[index] == tag) & TAG_RAM_WAY0[index][I_TAG]); 
    wire way1_hit = ((TAG_RAM_WAY1[index] == tag) & TAG_RAM_WAY1[index][I_TAG]);
    assign hit = way0_hit | way1_hit;

    wire [DATA_RAM_WIDTH-1 : 0] cache_data = way0_hit ? DATA_BLOCK_WAY0[index] : 
                                             way1_hit ? DATA_BLOCK_WAY1[index] : `ysyx_22040931_ZERO_NUM;

    ysyx_22040931_Mux #(32, 5, 64) DATA (data, chose, {
        5'b00000,  cache_data[63 : 0],
        5'b00001,  cache_data[71 : 8],
        5'b00010,  cache_data[79 : 16],
        5'b00011,  cache_data[87 : 24],
        5'b00100,  cache_data[95 : 32],
        5'b00101,  cache_data[103 : 40],
        5'b00110,  cache_data[111 : 48],
        5'b00111,  cache_data[119 : 56],
        5'b01000,  cache_data[127 : 64],
        5'b01001,  cache_data[135 : 72],
        5'b01010,  cache_data[143 : 80],
        5'b01011,  cache_data[151 : 88],
        5'b01100,  cache_data[159 : 96],
        5'b01101,  cache_data[167 : 104],
        5'b01110,  cache_data[175 : 112],
        5'b01111,  cache_data[183 : 120],
        5'b10000,  cache_data[191 : 128],
        5'b10001,  cache_data[199 : 136],
        5'b10010,  cache_data[207 : 144],
        5'b10011,  cache_data[215 : 152],
        5'b10100,  cache_data[223 : 160],
        5'b10101,  cache_data[231 : 168],
        5'b10110,  cache_data[239 : 176],
        5'b10111,  cache_data[249 : 184],
        5'b11000,  cache_data[255 : 192],
        5'b11001,  {8'h0,  cache_data[255 : 200]},
        5'b11010,  {16'h0, cache_data[255 : 208]},
        5'b11011,  {24'h0, cache_data[255 : 216]},
        5'b11100,  {32'h0, cache_data[255 : 224]},
        5'b11101,  {40'h0, cache_data[255 : 232]},
        5'b11110,  {48'h0, cache_data[255 : 240]},
        5'b11111,  {56'h0, cache_data[255 : 248]}
    });



    //replacement
    reg age;   //1 is 0 has
    always @(posedge clock) begin
        if(reset) begin
            age <= 0;
        end
        else if(way0_hit) begin
            age <= 1;
        end
    end

    //not hit
    assign to_arbiter_if_ready = if_ready;
    assign to_arbiter_pc_valid = !hit;
    //write from axi to cache
    always @(posedge clock) begin
        if(arbiter_to_icache_valid) begin
            if(age) begin
                TAG_RAM_WAY1[index] <= {1'b1, tag};
            end
            else begin
                TAG_RAM_WAY0[index] <= {1'b1, tag};
                DATA_BLOCK_WAY0[index] <= arbiter_data;//
            end
        end
    end




endmodule
