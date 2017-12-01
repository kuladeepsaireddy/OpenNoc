//`include "include_file.v"

`define X 1
`define Y 2
`define x_size 1
`define y_size 1
`define data_width 256
`define total_width (`x_size+`y_size+`data_width)
`define numPackets 10
`define injectRate 1

`define clkPeriod 2

`timescale 1ns/1ps

module randomTb();
reg  clk;
reg rst;
wire done;
wire [(`X*`Y)-1:0] r_valid_pe;
wire [(`total_width*`X*`Y)-1:0] r_data_pe;
wire [(`X*`Y)-1:0] r_ready_pe;
wire [(`X*`Y)-1:0] w_valid_pe;
wire [(`total_width*`X*`Y)-1:0] w_data_pe;
integer startTime;

initial
begin
 clk = 1'b0;
 forever
 begin
    clk = ~clk;
	#(`clkPeriod/2);
 end
end

initial
begin
    rst = 0;
    #10;
    rst = 1;
	startTime = $time;
end



openNocTop #(.X(`X),.Y(`Y),.data_width(`data_width), .x_size(`x_size),.y_size(`y_size))
ON
(
.clk(clk),
.rstn(rst),
.r_valid_pe(r_valid_pe),
.r_data_pe(r_data_pe),
.r_ready_pe(r_ready_pe),
.w_valid_pe(w_valid_pe),
.w_data_pe(w_data_pe)
);

randomPeTop #(.X(`X),.Y(`Y),.data_width(`data_width), .x_size(`x_size),.y_size(`y_size),.numPackets(`numPackets),.rate(`injectRate)) 
rPeT(
.clk(clk),
.rstn(rst),
//PE interfaces
.r_valid_pe(r_valid_pe),
.r_data_pe(r_data_pe),
.r_ready_pe(r_ready_pe),
.w_valid_pe(w_valid_pe),
.w_data_pe(w_data_pe),
.done(done)
);

wire noReadOp;
wire noWriteOp;

assign noReadOp = ~(|r_valid_pe);
assign noWriteOp = ~(|w_valid_pe);

always@(posedge clk)
begin
	if(done & noReadOp & noWriteOp)
	begin
	   $display("Simulation finished at",,,,$time);
	   $display("Max Throughput:\t %f packets/cycle",(`X*`Y*1.0/`injectRate));
	   $display("Achieved Throughput:\t %f packets/cycle",(`numPackets*`X*`Y*1.0)/(($time-startTime)/`clkPeriod));
	   $display("Efficiency:\t %f",((`numPackets*`X*`Y*100.0)/(($time-startTime)/`clkPeriod))/(`X*`Y*1.0/`injectRate));
	   $stop;
	end
end
 
 
endmodule

