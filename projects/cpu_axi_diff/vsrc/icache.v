//2022.7.29 xuxin
`include "defines.v"

module icache #(
    parameter I_TAG         = 22,
    parameter I_INDEX       = 6,
    parameter I_OFFSET      = 4,
    parameter TAG_RAM_NUM   = 64,
    parameter DATA_RAM_NUM  = 64,
    parameter DATA_RAM_WIDTH= 128

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
    input wire [`ysyx_22040931_CACHE_LINE] arbiter_data,

    output wire hit,
    output wire [`ysyx_22040931_DATA_BUS] data,
    output wire [`ysyx_22040931_PC_BUS] axi_address
    
);

    wire [I_TAG-1 : 0]    tag    = address[I_TAG-1 + I_OFFSET+I_INDEX : I_OFFSET+I_INDEX];
    wire [I_INDEX-1 : 0]  index  = address[I_INDEX-1 + I_OFFSET : I_OFFSET];
    wire [I_OFFSET-1 : 0] offset = address[I_OFFSET-1 : 0];

    //WAY0
    reg [I_TAG : 0] TAG_RAM_WAY0[0 : TAG_RAM_NUM-1];               //{1'valid, 21tag}
    //reg [DATA_RAM_WIDTH-1 : 0] DATA_BLOCK_WAY0[0 : DATA_RAM_NUM-1];
    wire [DATA_RAM_WIDTH-1 : 0] DATA_WAY0;
    S011HD1P_X32Y2D128 DATA_BLOCK_WAY0(DATA_WAY0, clock, !pc_valid, wen0, index, arbiter_data);
    //WAY1
    reg [I_TAG : 0] TAG_RAM_WAY1[0 : TAG_RAM_NUM-1];               //{1'valid, 21tag}
    //reg [DATA_RAM_WIDTH-1 : 0] DATA_BLOCK_WAY1[0 : DATA_RAM_NUM-1];
    wire [DATA_RAM_WIDTH-1 : 0] DATA_WAY1;
    S011HD1P_X32Y2D128 DATA_BLOCK_WAY1(DATA_WAY1, clock, !pc_valid, wen1, index, arbiter_data);




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

    wire [21 : 0] test = TAG_RAM_WAY0[0];
    wire test2 = TAG_RAM_WAY0[index][I_TAG-1];
    //hit
    wire way0_hit = ((TAG_RAM_WAY0[index] == tag) && TAG_RAM_WAY0[index][I_TAG-1]); 
    wire way1_hit = ((TAG_RAM_WAY1[index] == tag) && TAG_RAM_WAY1[index][I_TAG-1]);
    assign hit = way0_hit | way1_hit;
    //icache valid
    assign icache_if_valid = hit & hit_reg;
    assign icache_pc_ready = icache_if_valid & if_ready;
    reg hit_reg;
    always @(posedge clock) begin
        if(reset) begin
            hit_reg <= 0;
        end
        else begin
            hit_reg <= hit;
        end
    end

    // wire [DATA_RAM_WIDTH-1 : 0] cache_data = way0_hit ? DATA_BLOCK_WAY0[index] : 
    //                                          way1_hit ? DATA_BLOCK_WAY1[index] : `ysyx_22040931_ZERO_NUM;

    wire [DATA_RAM_WIDTH-1 : 0] cache_data = way0_hit ? DATA_WAY0 : 
                                             way1_hit ? DATA_WAY1 : `ysyx_22040931_ZERO_NUM;

    ysyx_22040931_Mux #(16, 4, 64) DATA (data, offset, {
        4'b0000,  cache_data[63 : 0],
        4'b0001,  cache_data[71 : 8],
        4'b0010,  cache_data[79 : 16],
        4'b0011,  cache_data[87 : 24],
        4'b0100,  cache_data[95 : 32],
        4'b0101,  cache_data[103 : 40],
        4'b0110,  cache_data[111 : 48],
        4'b0111,  cache_data[119 : 56],
        4'b1000,  cache_data[127 : 64],
        4'b1001,  {8'h0,  cache_data[127 : 72]},
        4'b1010,  {16'h0, cache_data[127 : 80]},
        4'b1011,  {24'h0, cache_data[127 : 88]},
        4'b1100,  {32'h0, cache_data[127 : 96]},
        4'b1101,  {40'h0, cache_data[127 : 104]},
        4'b1110,  {48'h0, cache_data[127 : 112]},
        4'b1111,  {56'h0, cache_data[127 : 120]}
    });



    //replacement age
    reg age;   //1 is 0 has
    always @(posedge clock) begin
        if(reset) begin
            age <= 0;
        end
        else if(way0_hit) begin
            age <= 1;
        end
    end

    //address
    assign axi_address = {address[63 : 4], 4'b0};
    //not hit
    assign to_arbiter_if_ready = if_ready;
    assign to_arbiter_pc_valid = !hit & pc_valid;
    //write from axi to cache
    wire wen0 = !(arbiter_to_icache_valid & !age);
    wire wen1 = !(arbiter_to_icache_valid & age);
    always @(posedge clock) begin
        if(arbiter_to_icache_valid) begin
            if(age) begin
                TAG_RAM_WAY1[index] <= {1'b1, tag};
                //DATA_BLOCK_WAY1[index] <= arbiter_data;
            end
            else begin
                TAG_RAM_WAY0[index] <= {1'b1, tag};
                //DATA_BLOCK_WAY0[index] <= arbiter_data;   //
            end
        end
    end




endmodule
