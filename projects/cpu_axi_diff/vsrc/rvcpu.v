//2022.7.26 xuxin
`include "defines.v"

module rvcpu(
  input         clock,
  input         reset,
  input         io_interrupt,
  input         io_master_awready,
  output        io_master_awvalid,
  output [31:0] io_master_awaddr,
  output [3:0]  io_master_awid,
  output [7:0]  io_master_awlen,
  output [2:0]  io_master_awsize,
  output [1:0]  io_master_awburst,
  input         io_master_wready,
  output        io_master_wvalid,
  output [63:0] io_master_wdata,
  output [7:0]  io_master_wstrb,
  output        io_master_wlast,
  output        io_master_bready,
  input         io_master_bvalid,
  input  [1:0]  io_master_bresp,
  input  [3:0]  io_master_bid,
  input         io_master_arready,
  output        io_master_arvalid,
  output [31:0] io_master_araddr,
  output [3:0]  io_master_arid,
  output [7:0]  io_master_arlen,
  output [2:0]  io_master_arsize,
  output [1:0]  io_master_arburst,
  output        io_master_rready,
  input         io_master_rvalid,
  input  [1:0]  io_master_rresp,
  input  [63:0] io_master_rdata,
  input         io_master_rlast,
  input  [3:0]  io_master_rid,
  output        io_slave_awready,
  input         io_slave_awvalid,
  input  [31:0] io_slave_awaddr,
  input  [3:0]  io_slave_awid,
  input  [7:0]  io_slave_awlen,
  input  [2:0]  io_slave_awsize,
  input  [1:0]  io_slave_awburst,
  output        io_slave_wready,
  input         io_slave_wvalid,
  input  [63:0] io_slave_wdata,
  input  [7:0]  io_slave_wstrb,
  input         io_slave_wlast,
  input         io_slave_bready,
  output        io_slave_bvalid,
  output [1:0]  io_slave_bresp,
  output [3:0]  io_slave_bid,
  output        io_slave_arready,
  input         io_slave_arvalid,
  input  [31:0] io_slave_araddr,
  input  [3:0]  io_slave_arid,
  input  [7:0]  io_slave_arlen,
  input  [2:0]  io_slave_arsize,
  input  [1:0]  io_slave_arburst,
  input         io_slave_rready,
  output        io_slave_rvalid,
  output [1:0]  io_slave_rresp,
  output [63:0] io_slave_rdata,
  output        io_slave_rlast,
  output [3:0]  io_slave_rid

);


assign io_slave_awready = 0;
assign io_slave_wready = 0;
assign io_slave_bvalid = 0;
assign io_slave_bresp = 0;
assign io_slave_bid = 0;
assign io_slave_arready = 0;
assign io_slave_rvalid = 0;
assign io_slave_rvalid = 0;
assign io_slave_rresp = 0;
assign io_slave_rdata = 0;
assign io_slave_rlast = 0;
assign io_slave_rid = 0;

    

    assign aw_ready                                 = io_master_awready;
    assign io_master_awvalid                        = aw_valid;
    assign io_master_awaddr                         = aw_addr[31 : 0];
    assign io_master_awid                           = aw_id;    
    assign io_master_awlen                          = aw_len;
    assign io_master_awsize                         = aw_size;
    assign io_master_awburst                        = aw_burst;    

    assign w_ready                                  = io_master_wready;
    assign io_master_wvalid                         = w_valid;
    assign io_master_wdata                          = w_data;
    assign io_master_wstrb                          = w_strb;
    assign io_master_wlast                          = w_last;

    assign io_master_bready                         = b_ready;
    assign b_valid                                  = io_master_bvalid;
    //assign b_resp                                   = io_master_bresp;
    assign b_id                                     = io_master_bid;

    assign ar_ready                                 = io_master_arready;
    assign io_master_arvalid                        = ar_valid;
    assign io_master_araddr                         = ar_addr[31 : 0];
    assign io_master_arid                           = ar_id;
    assign io_master_arlen                          = ar_len;
    assign io_master_arsize                         = ar_size;
    assign io_master_arburst                        = ar_burst;

    assign io_master_rready                         = r_ready;
    assign r_valid                                  = io_master_rvalid;
    //assign r_resp                                   = io_master_rresp;
    assign r_data                                   = io_master_rdata;
    assign r_last                                   = io_master_rlast;
    assign r_id                                     = io_master_rid;

    wire aw_ready;
    wire aw_valid;
    wire [`AXI_ADDR_WIDTH-1:0] aw_addr;
    wire [`AXI_ID_WIDTH-1:0] aw_id;
    wire [7:0] aw_len;
    wire [2:0] aw_size;
    wire [1:0] aw_burst;

    wire w_ready;
    wire w_valid;
    wire [`AXI_DATA_WIDTH-1:0] w_data;
    wire [`AXI_DATA_WIDTH/8-1:0] w_strb;
    wire w_last;
    
    wire b_ready;
    wire b_valid;
    wire [`AXI_ID_WIDTH-1:0] b_id;

    wire ar_ready;
    wire ar_valid;
    wire [`AXI_ADDR_WIDTH-1:0] ar_addr;
    wire [`AXI_ID_WIDTH-1:0] ar_id;
    wire [7:0] ar_len;
    wire [2:0] ar_size;
    wire [1:0] ar_burst;
    
    wire r_ready;
    wire r_valid;
    wire [`AXI_DATA_WIDTH-1:0] r_data;
    wire r_last;
    wire [`AXI_ID_WIDTH-1:0] r_id;



    // AXI4 AXI4 (
    // .reset(reset),
    // .clock(clock),
	// .rw_valid_i(AXI_vaild),     //
    // .rw_ready_o(AXI_ready),    //stall
    // //read
    // .data_read_o(AXI_r_data),  //
    // //write
    // .data_write_i(AXI_w_data),
    // .rw_addr_i(AXI_addr),    //
    // .rw_size_i(AXI_size),    //
    // .rw_req_i(AXI_req),      //
    // //ready
    // .cpu_id(AXI_id),
    // .out_id(AXI_ret_id),

    // // Advanced eXtensible Interface
    // .axi_aw_ready_i                 (aw_ready),
    // .axi_aw_valid_o                 (aw_valid),
    // .axi_aw_addr_o                  (aw_addr),
    // .axi_aw_id_o                    (aw_id),
    // .axi_aw_len_o                   (aw_len),
    // .axi_aw_size_o                  (aw_size),
    // .axi_aw_burst_o                 (aw_burst),
    // .axi_w_ready_i                  (w_ready),
    // .axi_w_valid_o                  (w_valid),
    // .axi_w_data_o                   (w_data),
    // .axi_w_strb_o                   (w_strb),
    // .axi_w_last_o                   (w_last),
    
    // .axi_b_ready_o                  (b_ready),
    // .axi_b_valid_i                  (b_valid),
    // //.axi_b_resp_i                   (b_resp),
    // .axi_b_id_i                     (b_id),
    // .axi_ar_ready_i                 (ar_ready),
    // .axi_ar_valid_o                 (ar_valid),
    // .axi_ar_addr_o                  (ar_addr),
    // .axi_ar_id_o                    (ar_id),
    // .axi_ar_len_o                   (ar_len),
    // .axi_ar_size_o                  (ar_size),
    // .axi_ar_burst_o                 (ar_burst),

    // .axi_r_ready_o                  (r_ready),
    // .axi_r_valid_i                  (r_valid),
    // //.axi_r_resp_i                   (r_resp),
    // .axi_r_data_i                   (r_data),
    // .axi_r_last_i                   (r_last),
    // .axi_r_id_i                     (r_id)
    // );


    // .AXI_ret_id(AXI_ret_id),
    // .AXI_r_data(AXI_r_data),
    // .AXI_addr(AXI_addr),
    // .AXI_w_data(AXI_w_data),
    // .AXI_size(AXI_size),
    // .AXI_id(AXI_id),    
    // .AXI_vaild(AXI_vaild),
    // .AXI_ready(AXI_ready),
    // .AXI_req(AXI_req) 

   ysyx_210457_axi_rw u_axi_rw (
        .clock                          (clock),
        .reset                          (reset),

        .rw_valid_i                     (AXI_vaild),
        .rw_req_i                       (AXI_req),
        .data_read_o                    (AXI_r_data),
        .data_write_i                   (AXI_w_data),
        .rw_addr_i                      (2147483648),
        .rw_size_i                      (AXI_size),
        .stall                          (),
        .cpu_id                         (3),
        .out_id                         (AXI_ret_id),

        .axi_aw_ready_i                 (aw_ready),
        .axi_aw_valid_o                 (aw_valid),
        .axi_aw_addr_o                  (aw_addr),
        .axi_aw_id_o                    (aw_id),
        .axi_aw_len_o                   (aw_len),
        .axi_aw_size_o                  (aw_size),
        .axi_aw_burst_o                 (aw_burst),

        .axi_w_ready_i                  (w_ready),
        .axi_w_valid_o                  (w_valid),
        .axi_w_data_o                   (w_data),
        .axi_w_strb_o                   (w_strb),
        .axi_w_last_o                   (w_last),
        
        .axi_b_ready_o                  (b_ready),
        .axi_b_valid_i                  (b_valid),
        //.axi_b_resp_i                   (b_resp),
        .axi_b_id_i                     (b_id),


        .axi_ar_ready_i                 (ar_ready),
        .axi_ar_valid_o                 (ar_valid),
        .axi_ar_addr_o                  (ar_addr),
        .axi_ar_id_o                    (ar_id),
        .axi_ar_len_o                   (ar_len),
        .axi_ar_size_o                  (ar_size),
        .axi_ar_burst_o                 (ar_burst),
  
        .axi_r_ready_o                  (r_ready),
        .axi_r_valid_i                  (r_valid),
        //.axi_r_resp_i                   (r_resp),
        .axi_r_data_i                   (r_data),
        .axi_r_last_i                   (r_last),
        .axi_r_id_i                     (r_id)

    );



    arbiter arbiter (
    .reset(reset),
    .clock(clock),
    .flush(),
    //woshou
    .pc_valid(pc_valid),                     //zhitong
    .arbiter_pc_ready(arbiter_pc_ready),      //to cpu
    .arbiter_if_valid(arbiter_if_valid),
    .if_ready(if_ready),
    //woshou
    .ex_valid(ex_valid),                     //zhitong
    .arbiter_ex_ready(arbiter_ex_ready),     //to cpu
    .arbiter_mem_valid(arbiter_mem_valid),
    .mem_ready(mem_ready),


    //if_Data
    .if_data(instr),
    .if_addr(pc),
    .if_size(if_size),
    .if_req(if_req),
    //mem_Data
    .mem_data(mem_data),
    .mem_stor_data(mem_stor_data),
    .mem_addr(mem_addr),
    .mem_size(mem_size),
    .mem_req(mem_req),



    //AXI
    .AXI_ret_id(AXI_ret_id),
    .AXI_r_data(AXI_r_data),
    .AXI_addr(AXI_addr),
    .AXI_w_data(AXI_w_data),
    .AXI_size(AXI_size),
    .AXI_id(AXI_id),    
    .AXI_vaild(AXI_vaild),
    .AXI_ready(AXI_ready),
    .AXI_req(AXI_req) 
);

//AXI
wire [`ysyx_22040931_DATA_BUS] AXI_r_data;
wire [`ysyx_22040931_PC_BUS]   AXI_addr;
wire [`ysyx_22040931_DATA_BUS] AXI_w_data;
wire [1 : 0] AXI_size;
wire AXI_vaild;
wire AXI_ready;
wire AXI_req; 
wire [3 : 0] AXI_ret_id;
wire [3 : 0] AXI_id;  




cputop cputop(
    .reset(reset),
    .clock(clock),
    //if
    .instr(instr), //
    //mem
    .momory_data(mem_data),
    

    //if
    .pc(pc),
    //woshou
    .arbiter_pc_ready(arbiter_pc_ready),
    .fetch_enb(pc_valid),
    .arbiter_if_valid(arbiter_if_valid),
    .if_ready(if_ready),
    
    //mem
    .memop(mem_size),
    .mem_wr(mem_req),
    .mem_addr(mem_addr),
    .mem_stor_data(mem_stor_data),
    //woshou
    .arbiter_ex_ready(arbiter_ex_ready),
    .mem_ena(ex_valid),         //ena & valid
    .arbiter_mem_valid(arbiter_mem_valid),
    .mem_ready(mem_ready)

);


//if
wire [`ysyx_22040931_INST_BUS] instr;
wire [`ysyx_22040931_PC_BUS] pc;
wire [1 : 0] if_size;
wire if_req;
assign if_size = 2'b10;
assign if_req = 1'b0;
//woshou
wire arbiter_pc_ready;
wire pc_valid;
wire arbiter_if_valid;
wire if_ready;

    
//mem
wire [`ysyx_22040931_DATA_BUS] mem_data;
wire [1 : 0]       mem_size;
wire               mem_req;
wire [`ysyx_22040931_MEM_BUS] mem_addr;
wire [`ysyx_22040931_DATA_BUS] mem_stor_data;
//woshou
wire arbiter_ex_ready;
wire ex_valid;            //ena & valid
wire arbiter_mem_valid;
wire mem_ready;




endmodule
