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
    input wire hhhh,////////////////////////////
    input wire [63 : 0] c,
    input wire reset,
    input wire clock,
    //woshou
    input wire ex_valid,          //zhitong
    output wire dcache_ex_ready,  //to cpu
    output wire dcache_mem_valid,
    input wire mem_ready,
    //arbiter
    input wire arbiter_to_icache_valid,  //if_valid
    output wire to_arbiter_ex_valid, 
    output wire to_arbiter_mem_ready,


    //cpu
    input wire write_read,
    input wire [1 : 0] mem_size,
    input wire [`ysyx_22040931_DATA_BUS] stor_data,
    //read
    input wire [`ysyx_22040931_PC_BUS] address,
    input wire [`ysyx_22040931_CACHE_LINE] arbiter_data,

    output wire hit,
    output wire [`ysyx_22040931_DATA_BUS] data,
    //axi
    output wire axi_wr,
    output wire [`ysyx_22040931_CACHE_LINE] axi_stor_data,
    output wire [`ysyx_22040931_PC_BUS] axi_address
    
);

    always @(posedge clock) begin
        if(!write_read && ({address[63 : 4],4'b0} == 64'h800049E0) && (~mask[111 : 96] != 16'h0)) begin
            //$display("reat,mask:%h,maskkk:%h, cyc:%d\n",mask,~mask[111 : 96],c);
        end
    end

    always @(posedge clock) begin
        if(write_read && ({address[63 : 4],4'b0} == 64'h800049E0) && (~mask[111 : 96] != 16'h0)) begin
            //$display("write:%h,mask:%h,maskkk:%h, cyc:%d\n",cache_sort_data, mask,~mask[111 : 96],c);
        end
    end



    wire [D_TAG-1 : 0]    tag    = address[D_TAG-1 + D_OFFSET+D_INDEX : D_OFFSET+D_INDEX]; //[31 : 10]  22bit
    wire [D_INDEX-1 : 0]  index  = address[D_INDEX-1 + D_OFFSET : D_OFFSET];
    wire [D_OFFSET-1 : 0] offset = address[D_OFFSET-1 : 0];


    //WAY0
    wire [DATA_RAM_WIDTH-1 : 0] DATA_WAY0, DATA_WAY1, DATA_WAY2, DATA_WAY3;
    reg [D_TAG : 0] TAG_RAM_WAY0[0 : TAG_RAM_NUM-1];               //{1'dirty, 22tag}
    S011HD1P_X32Y2D128_BW DATA_BLOCK_WAY0(DATA_WAY0, clock, 0, wen0, wmask, index, wdata);
    //WAY1
    reg [D_TAG : 0] TAG_RAM_WAY1[0 : TAG_RAM_NUM-1];               //{1'dirty, 22tag}
    S011HD1P_X32Y2D128_BW DATA_BLOCK_WAY1(DATA_WAY1, clock, 0, wen1, wmask, index, wdata);
    //WAY2
    reg [D_TAG : 0] TAG_RAM_WAY2[0 : TAG_RAM_NUM-1];               //{1'dirty, 22tag}
    S011HD1P_X32Y2D128_BW DATA_BLOCK_WAY2(DATA_WAY2, clock, 0, wen2, wmask, index, wdata);
    //WAY3
    reg [D_TAG : 0] TAG_RAM_WAY3[0 : TAG_RAM_NUM-1];               //{1'dirty, 22tag}
    S011HD1P_X32Y2D128_BW DATA_BLOCK_WAY3(DATA_WAY3, clock, 0, wen3, wmask, index, wdata);

    //dirty <= 0;
    integer i;
    always @(posedge clock) begin
        if(reset) begin
            for(i = 0; i < TAG_RAM_NUM; i = i + 1) begin
                TAG_RAM_WAY0[i][D_TAG] <= 1'b0;
                TAG_RAM_WAY1[i][D_TAG] <= 1'b0;
                TAG_RAM_WAY2[i][D_TAG] <= 1'b0;
                TAG_RAM_WAY3[i][D_TAG] <= 1'b0;
            end
        end
    end


    //hit
    wire way0_hit = (TAG_RAM_WAY0[index][D_TAG-1 : 0] == tag);
    wire way1_hit = (TAG_RAM_WAY1[index][D_TAG-1 : 0] == tag);
    wire way2_hit = (TAG_RAM_WAY2[index][D_TAG-1 : 0] == tag);
    wire way3_hit = (TAG_RAM_WAY3[index][D_TAG-1 : 0] == tag);
    assign hit = way0_hit | way1_hit | way2_hit | way3_hit;
    //dcache valid
    assign dcache_mem_valid = write_read ? hit | (arbiter_to_icache_valid & ready) : hit & hit_reg & next_notvalid;
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
    reg old_write_read;
    reg old_way0_hit, old_way1_hit, old_way2_hit, old_way3_hit;
    always @(posedge clock) begin
        if(reset) begin
            old_index <= 0;
            old_write_read <= 0;
        end
        else begin 
            old_index <= index;
            old_write_read <= write_read;
            old_way0_hit <= way0_hit;
            old_way1_hit <= way1_hit;
            old_way2_hit <= way2_hit;
            old_way3_hit <= way3_hit;
        end
    end

    // wire next_notvalid = (old_index != index) | (old_write_read != write_read);
    //                   //read-read              //same index but write-read
    wire next_notvalid = (old_index == index) & 
                         (old_write_read == write_read) &
                         (old_way0_hit == way0_hit) & 
                         (old_way1_hit == way1_hit) & 
                         (old_way2_hit == way2_hit) & 
                         (old_way3_hit == way3_hit);

    //read
    wire [DATA_RAM_WIDTH-1 : 0] cache_data = way0_hit ? DATA_WAY0 : 
                                             way1_hit ? DATA_WAY1 : 
                                             way2_hit ? DATA_WAY2 :
                                             way3_hit ? DATA_WAY3 :
                                             `ysyx_22040931_ZERO_NUM;

    //wire [`ysyx_22040931_DATA_BUS] rdata;
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
    ysyx_22040931_Mux #(4, 2, 128) MASK (need_mask, mem_size, {
        2'b00,  128'h0000000000000000_00000000000000ff,
        2'b01,  128'h0000000000000000_000000000000ffff,
        2'b10,  128'h0000000000000000_00000000ffffffff,
        2'b11,  128'h0000000000000000_ffffffffffffffff
    });
    wire [DATA_RAM_WIDTH-1 : 0] mask = ~(need_mask << {address[3 : 0], 3'b000});
    wire [DATA_RAM_WIDTH-1 : 0] cache_sort_data = address[3] ? {stor_data, 64'h0} : {64'h0, stor_data};


    wire dirty0 = (write_read & hit & way0_hit) ? 1 : TAG_RAM_WAY0[index][D_TAG];
    wire dirty1 = (write_read & hit & way1_hit) ? 1 : TAG_RAM_WAY1[index][D_TAG];
    wire dirty2 = (write_read & hit & way2_hit) ? 1 : TAG_RAM_WAY2[index][D_TAG];
    wire dirty3 = (write_read & hit & way3_hit) ? 1 : TAG_RAM_WAY3[index][D_TAG];
    always @(posedge clock) begin
        TAG_RAM_WAY0[index][D_TAG] <= dirty0;
        TAG_RAM_WAY1[index][D_TAG] <= dirty1;
        TAG_RAM_WAY2[index][D_TAG] <= dirty2;
        TAG_RAM_WAY3[index][D_TAG] <= dirty3;
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
    wire choose_way0 = (age == 2'b00);
    wire choose_way1 = (age == 2'b01);
    wire choose_way2 = (age == 2'b10);
    wire choose_way3 = (age == 2'b11);
    //address
    wire [`ysyx_22040931_PC_BUS] rep_address;
    assign rep_address = choose_way0 ? {TAG_RAM_WAY0[index][D_TAG-1 : 0], index, 4'b0} : 
                         choose_way1 ? {TAG_RAM_WAY1[index][D_TAG-1 : 0], index, 4'b0} :
                         choose_way2 ? {TAG_RAM_WAY2[index][D_TAG-1 : 0], index, 4'b0} : 
                         choose_way3 ? {TAG_RAM_WAY3[index][D_TAG-1 : 0], index, 4'b0} : `ysyx_22040931_ZERO_PC;




     
    
    //not hit
    assign to_arbiter_mem_ready = mem_ready;
    assign to_arbiter_ex_valid = !hit & ex_valid;
    //cache ena
    wire [DATA_RAM_WIDTH-1 : 0] wdata = hit ? cache_sort_data : 
                                              write_read ? (mask & arbiter_data | cache_sort_data) : arbiter_data;
    wire [DATA_RAM_WIDTH-1 : 0] wmask = hit ? mask : 128'h0000000000000000_0000000000000000;
    wire wen0 = way0_hit ? !write_read : rwen0;
    wire wen1 = way1_hit ? !write_read : rwen1;
    wire wen2 = way2_hit ? !write_read : rwen2;
    wire wen3 = way3_hit ? !write_read : rwen3;
    





    //is_dirty
    wire is_dirty0 = TAG_RAM_WAY0[index][D_TAG] & !hit & choose_way0;
    wire is_dirty1 = TAG_RAM_WAY1[index][D_TAG] & !hit & choose_way1;
    wire is_dirty2 = TAG_RAM_WAY2[index][D_TAG] & !hit & choose_way2;
    wire is_dirty3 = TAG_RAM_WAY3[index][D_TAG] & !hit & choose_way3;
    wire is_dirty = is_dirty0 | is_dirty1 | is_dirty2 | is_dirty3;
    //axi ena
    //address
    assign axi_wr = !ready;
    assign axi_address = ready ? {address[63 : 4], 4'b0} : rep_address;
    assign axi_stor_data = is_dirty0 ? DATA_WAY0 : 
                           is_dirty1 ? DATA_WAY1 : 
                           is_dirty2 ? DATA_WAY2 : 
                           is_dirty3 ? DATA_WAY3 : 
                           128'h0;

    reg cache_ready;
    always @(posedge clock) begin
        if(reset) begin
            cache_ready <= 0;
        end
        if(is_dirty & arbiter_to_icache_valid) begin
            cache_ready <= cache_ready ^ 1;  //+1
        end
    end
    wire ready = is_dirty ? cache_ready : 1;
    
    







    //write from axi to cache
    wire rwen0 = !(arbiter_to_icache_valid & ready & choose_way0);
    wire rwen1 = !(arbiter_to_icache_valid & ready & choose_way1);
    wire rwen2 = !(arbiter_to_icache_valid & ready & choose_way2);
    wire rwen3 = !(arbiter_to_icache_valid & ready & choose_way3);

    always @(posedge clock) begin
        if(!rwen0) begin
            TAG_RAM_WAY0[index] <= {write_read, tag};   //write is dirty
        end
        if(!rwen1) begin
            TAG_RAM_WAY1[index] <= {write_read, tag};
        end
        if(!rwen2) begin
            TAG_RAM_WAY2[index] <= {write_read, tag};
        end
        if(!rwen3) begin
            TAG_RAM_WAY3[index] <= {write_read, tag};
        end
    end


wire [D_TAG : 0] test = TAG_RAM_WAY3[30];

endmodule
