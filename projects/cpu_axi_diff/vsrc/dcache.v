//2022.7.29 xuxin
`include "defines.v"

module dcache #(
    parameter D_TAG         = 22,
    parameter D_INDEX       = 6,
    parameter D_OFFSET      = 4,
    parameter TAG_RAM_NUM   = 64,
    parameter DATA_RAM_NUM  = 64,
    parameter DATA_RAM_WIDTH= 128

)(
    input wire reset,
    input wire clock,
    //woshou
    input wire ex_valid,          //zhitong
    output wire icache_ex_ready,  //to cpu
    output wire icache_mem_valid,
    input wire mem_ready,
    //arbiter
    input wire arbiter_to_icache_valid,  //if_valid
    output wire to_arbiter_ex_valid, 
    output wire to_arbiter_mem_ready,


    //cpu
    input wire naligned;
    input wire write_read;
    input wire [1 : 0] mem_size;
    input wire [`ysyx_22040931_DATA_BUS] stor_data,
    //read
    input wire [`ysyx_22040931_PC_BUS] address,
    input wire [`ysyx_22040931_CACHE_LINE] arbiter_data,

    output wire hit,
    output wire [`ysyx_22040931_DATA_BUS] data,
    output wire axi_wr,
    output wire [`ysyx_22040931_DATA_BUS] axi_stor_data,
    output wire [`ysyx_22040931_PC_BUS] axi_address
    
);

    wire [D_TAG-1 : 0]    tag    = address[D_TAG-1 + D_OFFSET+I_INDEX : D_OFFSET+D_INDEX]; //[31 : 10]  22bit
    wire [D_INDEX-1 : 0]  index  = address[D_INDEX-1 + D_OFFSET : D_OFFSET];
    wire [D_OFFSET-1 : 0] offset = address[D_OFFSET-1 : 0];


    //WAY0
    wire [DATA_RAM_WIDTH-1 : 0] DATA_WAY0,  DATA_WAY1, DATA_WAY2, DATA_WAY3;
    reg [D_TAG : 0] TAG_RAM_WAY0[0 : TAG_RAM_NUM-1];               //{1'dirty, 22tag}
    S011HD1P_X32Y2D128_BW DATA_BLOCK_WAY0(DATA_WAY0, clock, !pc_valid, wen0, mask, index, arbiter_data);
    //WAY1
    reg [D_TAG : 0] TAG_RAM_WAY1[0 : TAG_RAM_NUM-1];               //{1'dirty, 22tag}
    S011HD1P_X32Y2D128_BW DATA_BLOCK_WAY1(DATA_WAY1, clock, !pc_valid, wen1, mask, index, arbiter_data);
    //WAY2
    reg [D_TAG : 0] TAG_RAM_WAY2[0 : TAG_RAM_NUM-1];               //{1'dirty, 22tag}
    S011HD1P_X32Y2D128_BW DATA_BLOCK_WAY2(DATA_WAY2, clock, !pc_valid, wen2, mask, index, arbiter_data);
    //WAY3
    reg [D_TAG : 0] TAG_RAM_WAY3[0 : TAG_RAM_NUM-1];               //{1'dirty, 22tag}
    S011HD1P_X32Y2D128_BW DATA_BLOCK_WAY3(DATA_WAY3, clock, !pc_valid, wen3, mask, index, arbiter_data);

    //dirty <= 0;
    integer i;
    always @(posedge clock) begin
        if(reset) begin
            for(i = 0; i < TAG_RAM_NUM; i = i + 1) begin
                TAG_RAM_WAY0[i][D_TAG-1] <= 1'b0;
                TAG_RAM_WAY1[i][D_TAG-1] <= 1'b0;
                TAG_RAM_WAY2[i][D_TAG-1] <= 1'b0;
                TAG_RAM_WAY3[i][D_TAG-1] <= 1'b0;
            end
        end
    end


    //hit
    wire way0_hit = (TAG_RAM_WAY0[index][I_TAG-1 : 0] == tag);
    wire way1_hit = (TAG_RAM_WAY1[index][I_TAG-1 : 0] == tag);
    wire way2_hit = (TAG_RAM_WAY2[index][I_TAG-1 : 0] == tag);
    wire way3_hit = (TAG_RAM_WAY3[index][I_TAG-1 : 0] == tag);
    assign hit = way0_hit | way1_hit | way2_hit | way3_hit;
    //dcache valid
    assign dcache_mem_valid = hit & hit_reg & (old_index == index);
    assign dcache_ex_ready = dcache_mem_valid & mem_ready;
    reg hit_reg;
    always @(posedge clock) begin
        if(reset) begin
            hit_reg <= 0;
        end
        else begin
            hit_reg <= hit;
        end
    end

    reg [D_INDEX-1 : 0] old_index;
    always @(posedge clock) begin
        if(reset) begin
            old_index <= 0;
        end
        else begin 
            old_index <= index;
        end
    end


    //read
    wire [DATA_RAM_WIDTH-1 : 0] cache_data = way0_hit ? DATA_WAY0 : 
                                             way1_hit ? DATA_WAY1 : 
                                             way2_hit ? DATA_WAY2 :
                                             way3_hit ? DATA_WAY3 :
                                             `ysyx_22040931_ZERO_NUM;


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

    //write  way0_hit==wen
    //data
    wire [DATA_RAM_WIDTH-1 : 0] need_mask;
    ysyx_22040931_Mux #(16, 2, 64) MASK (need_mask, offset, {
        2'b00,  128'hffffffffffffffff_ffffffffffffff00,
        2'b01,  128'hffffffffffffffff_ffffffffffff0000,
        2'b10,  128'hffffffffffffffff_ffffffff00000000,
        2'b11,  128'hffffffffffffffff_0000000000000000,
    });
    wire mask = need_mask << {address[3 : 0], 3'b000};

    write_read



    //not hit
    //write
    assign axi_stor_data = stor_data;
    assign aix_wr = write_read;
    //address
    assign axi_address = {address[63 : 4], 4'b0};
    //not hit
    assign to_arbiter_mem_ready = mem_ready;
    assign to_arbiter_ex_valid = !hit & ex_valid;

    always @(posedge clock) begin
        if(arbiter_to_icache_valid) begin
            
        end
    end
    





    //replacement age
    reg [1 : 0] age;   //1 is 0 has  //age[1] way12 age[0] 1 or 2
    always @(posedge clock) begin
        if(way0_hit | way1_hit) begin
            age[1] <= 1;
        end
        if(way2_hit | way3_hit) begin
            age[1] <= 0;
        end
        if(way0_hit | way2_hit) begin
            age[0] <= 1;
        end
        if(way1_hit | way3_hit) begin
            age[0] <= 0;
        end
    end


    //address
    assign axi_address = {address[63 : 4], 4'b0};
    //not hit
    assign to_arbiter_mem_ready = mem_ready;
    assign to_arbiter_ex_valid = !hit & ex_valid;
    //write from axi to cache
    wire wen0 = !(arbiter_to_icache_valid & (age == 2'b00));
    wire wen1 = !(arbiter_to_icache_valid & (age == 2'b01));
    wire wen2 = !(arbiter_to_icache_valid & (age == 2'b10));
    wire wen3 = !(arbiter_to_icache_valid & (age == 2'b11));

    always @(posedge clock) begin
        if(arbiter_to_icache_valid) begin
            if(!wen0) begin
                TAG_RAM_WAY0[index] <= {1'b1, tag};
            end
            if(!wen1) begin
                TAG_RAM_WAY1[index] <= {1'b1, tag};
            end
            if(!wen2) begin
                TAG_RAM_WAY2[index] <= {1'b1, tag};
            end
            if(!wen3) begin
                TAG_RAM_WAY3[index] <= {1'b1, tag};
            end
        end
    end



endmodule
