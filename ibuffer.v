//2022.8.13 xuxin
`include "defines.v"

module ibuffer#(
    parameter BUFFER_NUM   = 32,
    parameter BUFFER_INDEX = $clog2(BUFFER_NUM)
)(   
    input  wire reset,
    input  wire clock,
    //handshake
    input  wire in_valid,
    output wire out_ready,
    input  wire in_ready,
    output wire out_valid,


    input  wire [1 : 0] instr_num,
    input  wire [`FETCH_BUS] fetch_group,
    

    output wire [`INST_BUS] instr1,
    output wire [`INST_BUS] instr2 
);

    //---------------------handshake------------------------
    wire in_handshake  = in_valid & out_ready;
    wire out_handshake = out_valid & in_ready;
    assign out_ready = !is_full_all;
    assign out_valid = !is_empty;


    //--------------------instruction------------------------
    reg [`INST_BUS] Instruction_Buffer[0 : BUFFER_NUM-1];

    wire is_full1 = ({write_index + 1} == r_index);
    wire is_full2 = ({write_index + 2} == r_index);
    wire is_full3 = ({write_index + 3} == r_index);
    wire is_full4 = ({write_index + 4} == r_index);
    wire is_full_all = is_full1 & is_full2 & is_full3 & is_full4;
    wire is_empty = (write_index == (read_index + 1));

    wire is_write1 = !is_full1 & in_handshake;
    wire is_write2 = !is_full2 & in_handshake & is_write1 & (instr_num[1] | instr_num[0]);
    wire is_write3 = !is_full3 & in_handshake & is_write2 & instr_num[1];
    wire is_write4 = !is_full4 & in_handshake & is_write3 & (instr_num[1] & instr_num[0]);
    wire [`INST_BUS] Instruction_Buffer_data1 = is_write1 ? fetch_group[`INST_BUS] : Instruction_Buffer[write_index];
    wire [`INST_BUS] Instruction_Buffer_data2 = is_write2 ? fetch_group[63 :32] : Instruction_Buffer[write_index+1];
    wire [`INST_BUS] Instruction_Buffer_data3 = is_write3 ? fetch_group[95 :64] : Instruction_Buffer[write_index+2];
    wire [`INST_BUS] Instruction_Buffer_data4 = is_write4 ? fetch_group[127:96] : Instruction_Buffer[write_index+3];                                                

    integer i;
    always@(posedge clock) begin
        if(reset == 1'b1) begin
            for(i = 0; i < BUFFER_NUM; i = i+1) begin
                Instruction_Buffer[i] <= 0;
            end
        end
        else begin
            Instruction_Buffer[write_index]   <= Instruction_Buffer_data1;
            Instruction_Buffer[write_index+1] <= Instruction_Buffer_data2;
            Instruction_Buffer[write_index+2] <= Instruction_Buffer_data3;
            Instruction_Buffer[write_index+3] <= Instruction_Buffer_data4;
        end
    end


    //---------------------------index---------------------------------
    reg [BUFFER_INDEX] read_index, write_index;
    wire [BUFFER_INDEX] read_index_data  = out_handshake ? read_index + 2 : read_index;
    wire [BUFFER_INDEX] write_index_data = is_write4 ? write_index + 4 : 
                                           is_write3 ? write_index + 3 :
                                           is_write2 ? write_index + 2 :
                                           is_write1 ? write_index + 1 :
                                           write_index;
    always @(posedge clock) begin
        if(reset) begin
            read_index <= 0;
            write_index <= 0;
        end
        else begin
            read_index <= read_index_data;
            write_index <= write_index_data;
        end
    end


    //-----------------instruction_data---------------------
    assign instr1 = Instruction_Buffer[read_index];
    assign instr2 = Instruction_Buffer[read_index+1];




endmodule
