//`include "include_file.v"

`timescale 1ns/1ps

module randomPeTop  #(parameter X=2,Y=2,data_width=256, x_size=1, y_size=1,numPackets=100,total_width = (x_size+y_size+data_width),rate=1,pat="RANDOM")
(
input  wire clk,
input  wire rstn,
//PE interfaces
output wire [(X*Y)-1:0]              r_valid_pe,
output wire [(total_width*X*Y)-1:0] r_data_pe,
input  wire [(X*Y)-1:0]              r_ready_pe,
input wire [(X*Y)-1:0]               w_valid_pe,
input wire [(total_width*X*Y)-1:0]  w_data_pe,
output wire done,
input wire  start,
input wire [(X*Y)-1:0] enableSend
);

wire [(X*Y)-1:0] pedone;

assign done = &pedone;

generate
	genvar x, y; 
	for (x=0;x<X;x=x+1) begin:xs
		for (y=0; y<Y; y=y+1) begin:ys
			randomPe #(.xcord(x), .ycord(y),.X(X),.Y(Y), .dest_x(x_size), .dest_y(y_size),.num_of_pckts(numPackets),.rate(rate)) pe (
			.clk(clk),
			.rstn(rstn),
			.i_data(w_data_pe[(total_width*x)+(total_width*X*y)+:total_width]),
			.i_valid(w_valid_pe[x+X*y]),
			.o_data(r_data_pe[(total_width*x)+(total_width*X*y)+:total_width]),
			.o_valid(r_valid_pe[x+X*y]),
			.done(pedone[(y*X)+x]),
			.i_ready(r_ready_pe[x+X*y]),
			.start(start),
			.enableSend(enableSend[(y*X)+x])
			);
		end
	end			
endgenerate 

endmodule