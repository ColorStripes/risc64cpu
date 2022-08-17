//2022.8.13 xuxin
`include "defines.v"

module if_ib(
    input  wire reset,
    input  wire clock,
    input  wire [`FETCH_BUS] IF_fetch_group,

    output wire [`FETCH_BUS] IB_fetch_group
);



    Reg #(128, `ZERO_GROUP) if_ib (
        clock, 
        reset, 
        1'b1, 
        {IF_fetch_group}, 
        {IB_fetch_group}
    );


module 
