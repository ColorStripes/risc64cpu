//2022.7.24 xuxin
`include "defines.v"

module AXI4 # (
    parameter RW_DATA_WIDTH     = 128,
    parameter AXI_DATA_WIDTH    = 64,
    parameter AXI_ADDR_WIDTH    = 32,
    parameter AXI_ID_WIDTH      = 4

)(
    input                               reset,
    input                               clock,
	input                               rw_valid_i,     //
    output reg                          rw_ready_o,    //stall
    //read
    output reg [RW_DATA_WIDTH-1:0]      data_read_o,  //
    //write
    input  [RW_DATA_WIDTH-1:0]          data_write_i,
    input  [AXI_ADDR_WIDTH-1:0]         rw_addr_i,    //
    input  [1:0]                        rw_size_i,    //
    input                               rw_req_i,      //
    //ready
    input [AXI_ID_WIDTH-1:0]            cpu_id,
    output reg [AXI_ID_WIDTH-1:0]       out_id,

    // Advanced eXtensible Interface
    input                               axi_aw_ready_i, //write addresse
    output                              axi_aw_valid_o,
    output [AXI_ADDR_WIDTH-1:0]         axi_aw_addr_o,
    output [AXI_ID_WIDTH-1:0]           axi_aw_id_o,
    output [7:0]                        axi_aw_len_o,
    output [2:0]                        axi_aw_size_o,
    output [1:0]                        axi_aw_burst_o,


    input                               axi_w_ready_i, //write data
    output                              axi_w_valid_o,
    output [AXI_DATA_WIDTH-1:0]         axi_w_data_o,
    output [AXI_DATA_WIDTH/8-1:0]       axi_w_strb_o,
    output                              axi_w_last_o,
    
    output                              axi_b_ready_o,
    input                               axi_b_valid_i,
    input  [AXI_ID_WIDTH-1:0]           axi_b_id_i,

    input                               axi_ar_ready_i, //read address
    output                              axi_ar_valid_o, //zhu
    output [AXI_ADDR_WIDTH-1:0]         axi_ar_addr_o,
    output [AXI_ID_WIDTH-1:0]           axi_ar_id_o,
    output [7:0]                        axi_ar_len_o,
    output [2:0]                        axi_ar_size_o,
    output [1:0]                        axi_ar_burst_o,

    output                              axi_r_ready_o, //read data
    input                               axi_r_valid_i,
    input  [AXI_DATA_WIDTH-1:0]         axi_r_data_i,
    input                               axi_r_last_i,
    input  [AXI_ID_WIDTH-1:0]           axi_r_id_i
);

    wire w_trans    = rw_req_i == `REQ_WRITE;
    wire r_trans    = rw_req_i == `REQ_READ;
    wire w_valid    = rw_valid_i & w_trans;                               
    wire r_valid    = rw_valid_i & r_trans;

    // handshake
    wire aw_hs      = axi_aw_ready_i & axi_aw_valid_o;
    wire w_hs       = axi_w_ready_i  & axi_w_valid_o;
    wire b_hs       = axi_b_ready_o  & axi_b_valid_i;
    wire ar_hs      = axi_ar_ready_i & axi_ar_valid_o;
    wire r_hs       = axi_r_ready_o  & axi_r_valid_i;

    wire w_done     = w_hs & axi_w_last_o;
    wire r_done     = r_hs & axi_r_last_i;
    wire trans_done = w_trans ? b_hs : r_done;


    // ------------------State Machine------------------
    parameter [1:0] W_STATE_IDLE = 2'b00, W_STATE_ADDR = 2'b01, W_STATE_WRITE = 2'b10, W_STATE_RESP = 2'b11;
    parameter [1:0] R_STATE_IDLE = 2'b00, R_STATE_ADDR = 2'b01, R_STATE_READ  = 2'b10, R_STATE_VOID = 2'b11;
    reg [1:0] w_state, r_state;
    wire w_state_idle = w_state == W_STATE_IDLE, w_state_addr = w_state == W_STATE_ADDR, w_state_write = w_state == W_STATE_WRITE, w_state_resp = w_state == W_STATE_RESP;
    wire r_state_idle = r_state == R_STATE_IDLE, r_state_addr = r_state == R_STATE_ADDR, r_state_read  = r_state == R_STATE_READ;
    
    // Wirte State Machine
    always @(posedge clock) begin
        if (reset) begin
            w_state <= W_STATE_IDLE;
        end
        else begin
            if (w_valid) begin
                case (w_state)
                    W_STATE_IDLE: begin w_state <= W_STATE_ADDR;   end              
                    W_STATE_ADDR:  if (aw_hs) begin  w_state <= W_STATE_WRITE; end
                    W_STATE_WRITE: if (w_done) begin w_state <= W_STATE_RESP;  end
                    W_STATE_RESP:  if (b_hs) begin w_state <= W_STATE_IDLE;  end   
                endcase
            end
        end
    end

    // Read State Machine
    always @(posedge clock) begin
        if (reset) begin
            r_state <= R_STATE_IDLE;
        end
        else begin
            if (r_valid) begin
                case (r_state)
                    R_STATE_IDLE:begin r_state <= R_STATE_ADDR; end
                    R_STATE_ADDR: if (ar_hs)  begin  r_state <= R_STATE_READ; end
                    R_STATE_READ: if (r_done) begin r_state <= R_STATE_IDLE; end   
                    default:;
                endcase
            end
        end
    end

    // ------------------Process Data------------------
    localparam ALIGNED_WIDTH = $clog2(AXI_DATA_WIDTH / 8);
    localparam OFFSET_WIDTH  = $clog2(AXI_DATA_WIDTH);
    localparam AXI_SIZE      = $clog2(AXI_DATA_WIDTH / 8);          /////////////brust
    localparam MASK_WIDTH    = AXI_DATA_WIDTH * 2;
    localparam TRANS_LEN     = RW_DATA_WIDTH / AXI_DATA_WIDTH ;
    localparam BLOCK_TRANS   = TRANS_LEN > 1 ? 1'b1 : 1'b0;

    wire size_b             = rw_size_i == `SIZE_B;
    wire size_h             = rw_size_i == `SIZE_H;
    wire size_w             = rw_size_i == `SIZE_W;
    wire size_d             = rw_size_i == `SIZE_D;

    wire [7:0] axi_len      = 8'b1;  
    wire [2:0] axi_size     = AXI_SIZE[2:0];                     ///////////////brust
    wire [AXI_ID_WIDTH-1:0] axi_id              = {cpu_id[AXI_ID_WIDTH-1 : 0]};

    


    wire [3 : 0] out_id_nxt = (axi_b_valid_i) ? axi_b_id_i : (axi_r_valid_i) ? axi_r_id_i : 0;
    always @(posedge clock) begin
        if (reset) begin
            out_id <= 0;
        end
        else begin
            out_id <= out_id_nxt;
        end
    end

    wire rw_ready_nxt = trans_done;
    wire rw_ready_en  = trans_done | rw_ready_o;
    always @(posedge clock) begin
        if (reset) begin
            rw_ready_o <= 0;
        end
        else if (rw_ready_en) begin
            rw_ready_o <= rw_ready_nxt;
        end
    end
 


    // ------------------Number of transmission------------------
    reg [7:0] len;
    wire len_reset      = reset | (w_trans & w_state_idle) | (r_trans & r_state_idle);
    wire len_incr_en    = (len != axi_len) & (w_hs | r_hs);
    always @(posedge clock) begin
        if (len_reset) begin
            len <= 0;
        end
        else if (len_incr_en) begin
            len <= len + 1;
        end
    end


    // ------------------Write Transaction------------------

    // Write address channel signals
    assign axi_aw_valid_o   = w_state_addr & w_valid;
    assign axi_aw_addr_o    = rw_addr_i;
    assign axi_aw_id_o      = axi_id;
    assign axi_aw_len_o     = axi_len;
    assign axi_aw_size_o    = axi_size;
    assign axi_aw_burst_o   = `AXI_BURST_TYPE_INCR;


    // Write data channel signals
    assign axi_w_valid_o    = w_state_write;
    assign axi_w_strb_o     = 8'b11111111;

    assign axi_w_data_o = w_last ? data_write_i[127 : 64] : data_write_i[63 : 0];
    assign axi_w_last_o = w_last;

    reg w_last;
    always @(posedge clock) begin
        w_last <= axi_w_valid_o;
    end

    //Write respond channel signals
    assign axi_b_ready_o    = w_state_resp & w_valid;



    
    // ------------------Read Transaction------------------

    // Read address channel signals
    assign axi_ar_valid_o   = r_state_addr;
    assign axi_ar_addr_o    = rw_addr_i;
    assign axi_ar_id_o      = axi_id;
    assign axi_ar_len_o     = axi_len;
    assign axi_ar_size_o    = axi_size;
    assign axi_ar_burst_o   = `AXI_BURST_TYPE_INCR;

    // Read data channel signals
    assign axi_r_ready_o    = r_state_read;


        always @(posedge clock) begin
            if (reset) begin
                data_read_o <= 0;
            end
            else if (axi_r_ready_o & axi_r_valid_i) begin
                if (len == TRANS_LEN-1) begin
                    data_read_o[TRANS_LEN*AXI_DATA_WIDTH-1:AXI_DATA_WIDTH] <= axi_r_data_i;
                end
                else begin
                    data_read_o[AXI_DATA_WIDTH-1:0] <= axi_r_data_i;
                end
            end
        end





endmodule
