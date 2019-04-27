//`include "include_file.v"

`timescale 1ns/1ps

module randomPeTop  #(parameter X=2,Y=2,data_width=256, pkt_no_field_size=0,x_size=$clog2(X), y_size=$clog2(Y), numPackets=100,total_width = (x_size+y_size+pkt_no_field_size+data_width),rate=1,pat="RANDOM")
(
input  wire clk,
input  wire rstn,
//PE interfaces
output wire [(X*Y)-1:0]              r_valid_pe,
output wire [(total_width*X*Y)-1:0] r_data_pe,
input  wire [(X*Y)-1:0]              r_ready_pe,
input wire [(X*Y)-1:0]               w_valid_pe,
output wire [(X*Y)-1:0]               w_ready_pe,
input wire [(total_width*X*Y)-1:0]  w_data_pe,
output wire done,
input wire  start,
input wire [(X*Y)-1:0] enableSend,
output wire [(32*X*Y)-1:0] receiveCount
);

wire [(X*Y)-1:0] pedone;

assign done = &pedone;

generate
	genvar x, y; 
	for (x=0;x<X;x=x+1) begin:xs
		for (y=0; y<Y; y=y+1) begin:ys
			randomPe #(.xcord(x), .ycord(y),.data_width(data_width),.X(X),.Y(Y), .x_size(x_size), .y_size(y_size),.total_width(total_width),.num_of_pckts(numPackets),.rate(rate),.pat(pat)) pe (
			.clk(clk),
			.rstn(rstn),
			.i_data(w_data_pe[(total_width*x)+(total_width*X*y)+:total_width]),
			.i_valid(w_valid_pe[x+X*y]),
			.o_data(r_data_pe[(total_width*x)+(total_width*X*y)+:total_width]),
			.o_valid(r_valid_pe[x+X*y]),
			.o_ready(w_ready_pe[x+X*y]),
			.done(pedone[(y*X)+x]),
			.i_ready(r_ready_pe[x+X*y]),
			.start(start),
			.enableSend(enableSend[(y*X)+x]),
			.receivedPktCount(receiveCount[(32*x)+(32*X*y)+:32])
			);
		end
	end			
endgenerate 

endmodule