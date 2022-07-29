//2022.7.24 xuxin
`include "defines.v"

module AXI4 # (
    parameter RW_DATA_WIDTH     = 64,
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
    wire r_valid    = rw_valid_i & r_trans;//) || (w_valid & ~r_state_read);   ///////////

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
                    W_STATE_ADDR:  if (aw_hs)   w_state <= W_STATE_WRITE;
                    W_STATE_WRITE: if (w_done)  w_state <= W_STATE_RESP;
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
                    R_STATE_ADDR: if (ar_hs)    r_state <= R_STATE_READ;
                    R_STATE_READ: if (r_done) begin r_state <= R_STATE_IDLE; end   
                    //R_STATE_VOID:begin r_state <= R_STATE_IDLE; end
                    default:;
                endcase
            end
        end
    end


// always @(posedge clock) begin
//     if(reset) begin
//         stall <= 1'b0;
//     end
//     else if (w_valid) begin
//         case (w_state)
//             W_STATE_IDLE: begin  stall <= 1'b1; end              
//             W_STATE_RESP: begin 
//                 if (b_hs) begin 
//                     stall <= 1'b0; 
//                 end 
//             end
//             default: begin end   
//         endcase
//     end
//     else if (rw_req_i) begin
//         stall <= ~axi_b_valid_i;
//     end
//     if (r_valid) begin
//         case (r_state)
//             R_STATE_IDLE:begin  stall <= 1'b1; end
//             R_STATE_READ: if (r_done) begin  stall <= 1'b0; end   
//             default:begin  end
//         endcase
//     end
//     else if (~rw_req_i) begin
//         stall <= ~axi_r_valid_i;
//     end
// end


    // ------------------Process Data------------------
    localparam ALIGNED_WIDTH = $clog2(AXI_DATA_WIDTH / 8);
    localparam OFFSET_WIDTH  = $clog2(AXI_DATA_WIDTH);
    localparam AXI_SIZE      = $clog2(AXI_DATA_WIDTH / 8);    /////////////brust
    localparam MASK_WIDTH    = AXI_DATA_WIDTH * 2;
    localparam TRANS_LEN     = RW_DATA_WIDTH / AXI_DATA_WIDTH;
    localparam BLOCK_TRANS   = TRANS_LEN > 1 ? 1'b1 : 1'b0;

    wire aligned            = BLOCK_TRANS | rw_addr_i[ALIGNED_WIDTH-1:0] == 0;
    wire size_b             = rw_size_i == `SIZE_B;
    wire size_h             = rw_size_i == `SIZE_H;
    wire size_w             = rw_size_i == `SIZE_W;
    wire size_d             = rw_size_i == `SIZE_D;
    wire [3:0] addr_op1     = {{4-ALIGNED_WIDTH{1'b0}}, rw_addr_i[ALIGNED_WIDTH-1:0]};
    wire [3:0] addr_op2     = ({4{size_b}} & {4'b0})
                                | ({4{size_h}} & {4'b1})
                                | ({4{size_w}} & {4'b11})
                                | ({4{size_d}} & {4'b111})
                                ;
    wire overstep           = {{addr_op1 + addr_op2} & 4'b1000} != 0;
    wire [7:0] axi_len      = aligned ? TRANS_LEN - 1 : {{7{1'b0}}, overstep};    
    wire [2:0] axi_size     = AXI_SIZE[2:0];                     ///////////////brust
    
    wire [OFFSET_WIDTH-1:0] aligned_offset    = {{OFFSET_WIDTH-ALIGNED_WIDTH{1'b0}}, {rw_addr_i[ALIGNED_WIDTH-1:0]}};
    wire [OFFSET_WIDTH-1:0] aligned_offset_l    = {{OFFSET_WIDTH-ALIGNED_WIDTH{1'b0}}, {rw_addr_i[ALIGNED_WIDTH-1:0]}} << 3;
    wire [OFFSET_WIDTH-1:0] aligned_offset_h    = 6'd32 - aligned_offset_l;
    wire [MASK_WIDTH-1:0] mask                  = (({MASK_WIDTH{size_b}} & {{MASK_WIDTH-8{1'b0}}, 8'hff})
                                                    | ({MASK_WIDTH{size_h}} & {{MASK_WIDTH-16{1'b0}}, 16'hffff})
                                                    | ({MASK_WIDTH{size_w}} & {{MASK_WIDTH-32{1'b0}}, 32'hffffffff})
                                                    | ({MASK_WIDTH{size_d}} & {{MASK_WIDTH-64{1'b0}}, 64'hffffffff_ffffffff})
                                                    ) << aligned_offset_l;
    wire [AXI_DATA_WIDTH-1:0] mask_l            = mask[AXI_DATA_WIDTH-1:0];
    wire [AXI_DATA_WIDTH-1:0] mask_h            = mask[MASK_WIDTH-1:AXI_DATA_WIDTH];

    wire [AXI_ID_WIDTH-1:0] axi_id              = {cpu_id[AXI_ID_WIDTH-1 : 0]};

    


    wire [3 : 0] out_id_nxt = (axi_r_valid_i) ? axi_r_id_i : (axi_b_valid_i) ? axi_b_id_i : 0;
    always @(posedge clock) begin
        if (reset) begin
            out_id <= 0;
        end
        else begin
            out_id <= out_id_nxt;
        end
    end



    wire rw_ready_nxt = trans_done;
    wire rw_ready_en      = trans_done | rw_ready_o;
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
    assign axi_w_strb_o     = (size_b) ? {{AXI_DATA_WIDTH/8-1{1'b0}}, 1'b1} << aligned_offset : 
                              (size_h) ? {{AXI_DATA_WIDTH/8-2{1'b0}}, 2'b11} << aligned_offset :
                              (size_w) ? {{AXI_DATA_WIDTH/8-4{1'b0}}, 4'b1111} << aligned_offset :
                              (size_d) ? {8'b11111111} << aligned_offset : {AXI_DATA_WIDTH/8-0{1'b0}};


    assign  axi_w_data_o  = (data_write_i & mask_l) ;
    //wire [AXI_DATA_WIDTH-1:0] axi_w_data_h  = (data_write_i & mask_h) ;


    assign axi_w_last_o = axi_w_valid_o;

    //Write respond channel signals
    assign axi_b_ready_o    = w_state_resp & w_valid;//




    
    // ------------------Read Transaction------------------

    // Read address channel signals
    assign axi_ar_valid_o   = r_state_addr;// & ~w_valid;
    assign axi_ar_addr_o    = rw_addr_i;
    assign axi_ar_id_o      = axi_id;
    assign axi_ar_len_o     = axi_len;
    assign axi_ar_size_o    = axi_size;
    assign axi_ar_burst_o   = `AXI_BURST_TYPE_INCR;

    // Read data channel signals
    assign axi_r_ready_o    = r_state_read;// & ~w_valid;

    wire [AXI_DATA_WIDTH-1:0] axi_r_data_l  = (axi_r_data_i & mask_l) >> aligned_offset_l;
    wire [AXI_DATA_WIDTH-1:0] axi_r_data_h  = (axi_r_data_i & mask_h) << aligned_offset_h;

    genvar i;
    generate
        for (i = 0; i < TRANS_LEN; i = i+1) begin : genbit
            always @(posedge clock) begin
                if (reset) begin
                    data_read_o[i*AXI_DATA_WIDTH+:AXI_DATA_WIDTH] <= 0;
                end
                else if (axi_r_ready_o & axi_r_valid_i) begin
                    if (~aligned & overstep) begin
                        if (len[0]) begin
                            data_read_o[AXI_DATA_WIDTH-1:0] <= data_read_o[AXI_DATA_WIDTH-1:0] | axi_r_data_h;
                        end
                        else begin
                            data_read_o[AXI_DATA_WIDTH-1:0] <= axi_r_data_l;
                        end
                    end
                    else if (len == i) begin
                        data_read_o[i*AXI_DATA_WIDTH+:AXI_DATA_WIDTH] <= axi_r_data_l;
                    end
                end
            end
        end
    endgenerate

endmodule
