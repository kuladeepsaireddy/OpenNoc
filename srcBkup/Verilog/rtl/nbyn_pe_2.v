`include "include_file.v"

module nbyn_pe(
input wire clk,
input wire [`total_width-1:0] i_data,
input wire i_valid,
output  reg [`total_width-1:0] o_data,
output reg o_valid,
input wire i_ready

);
integer x;

always @(posedge clk)
begin 
    if(i_valid)
    begin
		for(x=0;x<`iter;x=x+1)
	    begin
	    // o_data[264:9] <= 'd255 - i_data[264:9];
	       o_data[`x_size+`y_size+`pck_num+x*8+:8]<=8'hff-i_data[`x_size+`y_size+`pck_num+x*8+:8];
	    end
	    o_data[`x_size+`y_size-1:0] <= 'h0;
	    o_data[`x_size+`y_size+`pck_num-1:`y_size+`x_size]<=i_data[`x_size+`y_size+`pck_num-1:`y_size+`x_size];
	end
end

 
 

 
always @(posedge clk) 
begin
    if(o_valid & i_ready)
    begin
	   o_valid <= 1'b0;
	end
    else if(i_valid)
	begin
       o_valid <=1'b1;
	end
 end



endmodule
