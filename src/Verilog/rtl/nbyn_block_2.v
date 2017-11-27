`include "include_file.v"

module nbyn_block #(parameter x_coord='d0,parameter y_coord='d0)
(
input wire clk,
input wire i_ready_r,
input wire i_ready_t,
input wire i_valid_l,
input wire i_valid_b,
output wire o_ready_l,
output wire o_ready_b,
output wire o_valid_r,
output wire o_valid_t,
input wire [`total_width-1:0] i_data_l,
input wire [`total_width-1:0] i_data_b,
output wire [`total_width-1:0] o_data_r,
output wire [`total_width-1:0] o_data_t


);
wire [`total_width-1:0] i_data_pe;
wire [`total_width-1:0] o_data_pe;
wire o_ready_pe;
wire o_valid_pe;
//wire i_ready_pe;
wire i_valid_pe;


nbyn #(.x_coord(x_coord),.y_coord(y_coord))
 switch(
 .clk(clk),
 .i_ready_r(i_ready_r),
 .i_ready_t(i_ready_t),
 //.i_ready_pe(i_ready_pe),
 .i_valid_l(i_valid_l),
 .i_valid_b(i_valid_b),
 .i_valid_pe(i_valid_pe),
 .o_ready_l(o_ready_l),
 .o_ready_b(o_ready_b),
 .o_ready_pe(o_ready_pe),
 .o_valid_r(o_valid_r),
 .o_valid_t(o_valid_t),
 .o_valid_pe(o_valid_pe),
 .i_data_l(i_data_l),
 .i_data_b(i_data_b),
 .i_data_pe(i_data_pe),
 .o_data_r(o_data_r),
 .o_data_t(o_data_t),
 .o_data_pe(o_data_pe)
);

nbyn_pe pe(

.clk(clk),
.i_data(o_data_pe),
.i_ready(o_ready_pe),
.i_valid(o_valid_pe),
.o_data(i_data_pe),
.o_valid(i_valid_pe)

);







endmodule
