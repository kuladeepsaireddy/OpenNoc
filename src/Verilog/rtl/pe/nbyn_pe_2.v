`timescale 1ns/1ps

`include "include_file.v"

module nbyn_pe(
input wire clk,
input wire [`total_width-1:0] i_data,
input wire i_valid,
output  wire [`total_width-1:0] o_data,
output wire o_valid,
input wire i_ready

);
integer x;
reg fifowr;
reg [`total_width-1:0] fifoWrData;
reg rst;

always @(posedge clk)
begin 
    if(i_valid)
    begin
		for(x=0;x<`iter;x=x+1)
	    begin
	    // o_data[264:9] <= 'd255 - i_data[264:9];
	       fifoWrData[`x_size+`y_size+`pck_num+x*8+:8]<=8'hff-i_data[`x_size+`y_size+`pck_num+x*8+:8];
	    end
	    fifoWrData[`x_size+`y_size-1:0] <= 'h0; //destination address is 0
	    fifoWrData[`x_size+`y_size+`pck_num-1:`y_size+`x_size] <= i_data[`x_size+`y_size+`pck_num-1:`y_size+`x_size]; //copy the packet number
	end
end


 
always @(posedge clk) 
begin
    fifowr <= i_valid;
end

initial
begin
rst = 0;
#5;
rst = 1;
end

myFifo fifo (

  .s_axis_aresetn(rst),          // input wire s_axis_aresetn
  .s_axis_aclk(clk),                // input wire s_axis_aclk
  .s_axis_tvalid(fifowr),            // input wire s_axis_tvalid
  .s_axis_tready(),            // output wire s_axis_tready
  .s_axis_tdata(fifoWrData),              // input wire [15 : 0] s_axis_tdata
  .m_axis_tvalid(o_valid),            // output wire m_axis_tvalid
  .m_axis_tready(i_ready),            // input wire m_axis_tready
  .m_axis_tdata(o_data),              // output wire [15 : 0] m_axis_tdata
  .axis_data_count(),        // output wire [31 : 0] axis_data_count
  .axis_wr_data_count(),  // output wire [31 : 0] axis_wr_data_count
  .axis_rd_data_count()  // output wire [31 : 0] axis_rd_data_count
);


endmodule
