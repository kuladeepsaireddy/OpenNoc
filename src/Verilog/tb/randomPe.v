module randomPe #(parameter xcord=0, ycord=0,data_width=240, X=4,Y=4, dest_x=2, dest_y=2,source_x=8,source_y=8,total_width=(dest_x+dest_y+source_x+source_y+data_width),num_of_pckts=3,rate=1)
(
input wire clk,
input wire rstn,
input wire [total_width-1:0] i_data,
input wire i_valid,
output  reg [total_width-1:0] o_data,
output wire o_valid,
output wire  done,
input wire i_ready

);

integer counter;
integer accept_counter=0;
wire check_reg;
integer in_data_count=0;

//reg done;
reg[dest_x-1:0]dest_x_addr;
reg [dest_y-1:0]dest_y_addr;
reg valid;


assign check_reg=(counter%rate==0)?0:1;
assign o_valid = valid&!done;

always @(posedge clk)
begin
	if(!rstn)
	begin
		counter <= 0;
		dest_x_addr <= 0;
		dest_y_addr<=0;
		valid <= 0;
	end
   else if(check_reg==0 & !done)
   begin
	  valid<=1'b1;
	  dest_x_addr = $urandom%X;
	  dest_y_addr = $urandom%Y;
	  o_data[dest_x-1:0]<=dest_x_addr;
	  o_data[dest_x+dest_y-1:dest_x]<=dest_y_addr;
	  o_data[dest_x+dest_y+source_x-1:dest_x+dest_y]<=xcord;
	  o_data[dest_x+dest_y+source_x+source_y-1:dest_x+dest_y+source_x]<=ycord;
	  o_data[dest_x+dest_y+source_x+source_y+data_width-1:dest_x+dest_y+source_x+source_y]<=counter;
	  counter<=counter+1;
   end	
   else if(done)
	  valid<=0;
 end 


always@(posedge clk)
 begin
    if(i_ready & o_valid)  
    begin
	   accept_counter<=accept_counter+1;
	end
 end
 
 
 always@(posedge clk)
 begin
    if(i_valid)
	begin
	    in_data_count<=in_data_count+1;
	end 
 end 
  
  

 assign done = (accept_counter==num_of_pckts) ? 1'b1 : 1'b0;

 /*
  always@(posedge clk)
   begin
    if(end_flag)
	 done<=1;
	else
     done<=0;	
   end
  */
endmodule