`include "include_file.v"

module nbyn_block_main #(parameter x_coord='d0,parameter y_coord='d0)
(
input wire clk,
input wire rst,
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
output wire [`total_width-1:0] o_data_t,
////input wire [264:0] main_input,
////output wire [264:0] main_output,
////output o_ready_scheduler,
////output o_valid_scheduler,
////input wire main_valid_pe,


input i_valid_pci,
input wire [`data_width-1:0] i_data_pci,
output o_ready_pci,

///From scheduler to PCI///

output wire [`data_width-1:0] o_data_pci,
output o_valid_pci,
input  i_ready_pci

);
wire [`total_width-1:0] i_data_pe;
wire [`total_width-1:0] o_data_pe;
wire o_ready_pe;
wire o_valid_pe;
//wire i_ready_pe;
wire i_valid_pe;


nbyn #(.x_coord(x_coord),.y_coord(y_coord))
 main_switch(
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

nbyn_pe_main main_pe(

.clk(clk),
.rst(rst),
.i_data(o_data_pe),
.i_ready(o_ready_pe),
.i_valid(o_valid_pe),
.o_data(i_data_pe),
.o_valid(i_valid_pe),

.i_valid_pci(i_valid_pci),
.i_data_pci(i_data_pci),
.o_ready_pci(o_ready_pci),
.o_data_pci(o_data_pci),
.o_valid_pci(o_valid_pci),
.i_ready_pci(i_ready_pci)
//.main_input(main_input),
//.main_output(main_output),
//.o_ready_scheduler(o_ready_scheduler),
//.o_valid_scheduler(o_valid_scheduler),
//.main_valid_pe(main_valid_pe)
);







endmodule