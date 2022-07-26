//2022.7.18 xuxin
`include "defines.v"

module direction_predictor(
    input wire reset,
    input wire clock,
    input wire valid_pre,
    
    
    input wire [`ysyx_22040931_PC_BUS] id_pc,
    input wire id_jump,  //jump?
    input wire [1 : 0] id_jumptype,
    input wire [`ysyx_22040931_PC_BUS] pc,


    output wire jump
);

    reg [1 : 0] PHT[0 : `ysyx_22040931_PHT_SIZE-1];
    reg [`ysyx_22040931_BHT_WIDTH-1 : 0] BHT[0 : `ysyx_22040931_BHT_SIZE-1];


    wire [`ysyx_22040931_HASH_WIDTH-1 : 0] hash;
    assign hash = pc[33 : 26] + pc[25 : 18] + pc[17 : 10] + pc[9 : 2];
    wire [`ysyx_22040931_HASH_WIDTH-1 : 0] pht_index;
    assign pht_index = pc[`ysyx_22040931_HASH_WIDTH+2 : 3] ^ BHT[hash];///////////



    wire [`ysyx_22040931_HASH_WIDTH-1 : 0] id_hash;
    assign id_hash = id_pc[33 : 26] + id_pc[25 : 18] + id_pc[17 : 10] + id_pc[9 : 2];
    wire [`ysyx_22040931_HASH_WIDTH-1 : 0] id_pht_index;
    assign id_pht_index = id_pc[`ysyx_22040931_HASH_WIDTH+2 : 3] ^ BHT[id_hash]; ///////


    integer i,j;
    always @(posedge clock) begin
        if(reset == 1'b1) begin
            for(i = 0; i < `ysyx_22040931_PHT_SIZE; i = i + 1) begin
                PHT[i] = 2'b00;
            end
            for(j = 0; j < `ysyx_22040931_BHT_SIZE; j = j + 1) begin
                BHT[j] = 8'b0000_0000;
            end
        end
        else begin

            if(id_jumptype != 0) begin
                BHT[id_hash] <= {{BHT[id_hash]}[`ysyx_22040931_BHT_WIDTH-1 : 1], id_jump};
                if(id_jump) begin
                    case(PHT[id_pht_index])
                        2'b00: begin PHT[id_pht_index] <= 2'b01; end
                        2'b01: begin PHT[id_pht_index] <= 2'b11; end
                        2'b11: begin PHT[id_pht_index] <= 2'b10; end
                        2'b10: begin PHT[id_pht_index] <= 2'b10; end
                    endcase
                end
                else begin
                    case(PHT[id_pht_index])
                        2'b00: begin PHT[id_pht_index] <= 2'b00; end
                        2'b01: begin PHT[id_pht_index] <= 2'b00; end
                        2'b11: begin PHT[id_pht_index] <= 2'b01; end
                        2'b10: begin PHT[id_pht_index] <= 2'b11; end
                    endcase
                end
            end   

        end
    end

    assign jump = valid_pre ? {PHT[pht_index]}[1] : 1'b0;


endmodule
