`include "include_file.v"


module nbyn #(parameter x_coord ='d0,parameter y_coord='d0) //parameter pck_no=16'd0)
(
input wire clk,
input wire i_ready_r,
input wire i_ready_t,
//input wire i_ready_pe,
input wire i_valid_l,
input wire i_valid_b,
input wire i_valid_pe,
output wire o_ready_l,
output wire o_ready_b,
output wire  o_ready_pe,
output reg o_valid_r,
output reg o_valid_t,
output reg o_valid_pe,
input wire [`total_width-1:0] i_data_l,
input wire [`total_width-1:0] i_data_b,
input wire [`total_width-1:0] i_data_pe,
output reg [`total_width-1:0] o_data_r,
output reg [`total_width-1:0] o_data_t,
output reg [`total_width-1:0] o_data_pe

);
assign  o_ready_l = 1'b1;
assign  o_ready_b = 1'b1;


initial
begin
   o_valid_r <= 1'b0;
	o_valid_t <= 1'b0;
end


assign o_ready_pe = !(i_valid_b & i_valid_l);

//assign o_ready_pe = ((i_valid_b & i_valid_l) ==1)? 0 : 1;
//Block to control o_data_r

/*always @(posedge clk)
begin
  if(i_valid_l)
  begin
    if(i_data_l[3:0]!=x_coord) 
	 begin  
          o_data_r <=i_data_l;
		    o_valid_r <=1'b1; 
	 end
  else if(i_valid_b) // i_valid_l == 0
  begin
    if(i_data_b[3:0]!=x_coord) 
	 begin  
          o_data_r <=i_data_b;
		    o_valid_r <=1'b1; 
	 end
  else if(i_valid_pe) //i_valid_l == 0, i_valid_b == 0
  begin
    if(i_data_pe[3:0]!=x_coord) 
	 begin  
          o_data_r <=i_data_pe;
		    o_valid_r <=1'b1; 
	 end
  else
  begin
    o_valid_r <= 1'b0;
  end
 end



always @(posedge clk)
begin
  if((i_valid_l & i_data_l[3:0]!=x_coord) & i_valid_b & (i_data_b[3:0]!=x_coord | i_data_l[7:4]!= y_coord))
  begin      
      o_data_t <= i_data_b;
		o_valid_t <= 1'b1;
  end
  else(i_valid_l & i_data_l[3:0]==x_coord & i_data_l[7:4]!= y_coord)
  begin
  end
      o_data_t <= i_data_b;
		o_valid_t <= 1'b1;




*/







always @(posedge clk)
begin
    if(i_ready_r & i_valid_l & i_data_l[`x_size-1:0]!=x_coord)     
	 begin
        o_data_r <=i_data_l;
		  o_valid_r <=1'b1;
	 end
	 else if(i_ready_r & i_valid_b & i_data_b[`x_size-1:0]!=x_coord)
	 begin
        o_data_r <=i_data_b;
		  o_valid_r <=1'b1;
	 end
     else if(i_ready_t & i_valid_b & i_data_b[`x_size-1:0]!=x_coord & i_ready_r & i_valid_l & i_data_l[`x_size-1:0]!=x_coord)// both going to right     
	 begin
        o_data_r <=i_data_l;
		  o_valid_r <=1'b1;	
     end		  
	 else if(i_ready_t & i_valid_b & i_data_b[`x_size-1:0]==x_coord & i_ready_r & i_valid_l & i_data_l[`x_size-1:0]==x_coord & i_data_b[`x_size+`y_size-1:`x_size]!=y_coord & i_data_l[`x_size+`y_size-1:`x_size]!=y_coord) //both going to top
	 begin
	     o_data_r <=i_data_b;
		  o_valid_r <=1'b1;
	 end
    
	 else if(i_ready_r & i_valid_l & i_data_l[`x_size-1:0]==x_coord & i_valid_b & i_data_b[`x_size-1:0]==x_coord & i_data_b[`x_size+`y_size-1:`x_size]==y_coord & i_data_l[`x_size+`y_size-1:`x_size]==y_coord)//both going to pe
	 begin
          o_data_r<=i_data_b;
          o_valid_r<=1'b1;		  
	 end
	 else if(i_ready_t & i_valid_b & i_data_b[`x_size-1:0]!=x_coord & i_ready_r & i_valid_pe & i_data_pe[`x_size-1:0]!=x_coord)////// pe and bottom going to right
	 begin
	    o_data_r<=i_data_b;
		o_valid_r<=1'b1;
	 end
    else if(i_ready_t & i_valid_l & i_data_l[`x_size-1:0]!=x_coord & i_ready_r & i_valid_pe & i_data_pe[`x_size-1:0]!=x_coord)//////pe and left going to right
	 begin
	    o_data_r<=i_data_l;
		o_valid_r<=1'b1;
	 end
   else if(o_ready_pe & i_valid_pe & i_data_pe[`x_size-1:0]!=x_coord)
    begin
          o_data_r <=i_data_pe;
		    o_valid_r <=1'b1;
	 end
    else if(i_ready_t & i_valid_l & i_data_l[`x_size-1:0]==x_coord & i_data_l[`x_size+`y_size-1:`x_size]!=y_coord & i_ready_r & i_valid_pe & i_data_pe[`x_size-1:0]==x_coord & i_data_pe[`x_size+`y_size-1:`x_size]!=y_coord)////// left and pe going to top
	 begin
	    o_data_r<=i_data_pe;
		o_valid_r<=1'b1;
	 end
    else if(i_ready_t & i_valid_b & i_data_b[`x_size-1:0]==x_coord & i_data_b[`x_size+`y_size-1:`x_size]!=y_coord & i_ready_r & i_valid_pe & i_data_pe[`x_size-1:0]==x_coord & i_data_pe[`x_size+`y_size-1:`x_size]!=y_coord)//////bottom and pe going to top
	 begin
	    o_data_r<=i_data_pe;
		o_valid_r<=1'b1;
	 end
	 else
	    o_valid_r <=1'b0;
end

always @(posedge clk)
begin
    if(i_ready_t & i_valid_b & i_data_b[`x_size-1:0]!=x_coord & i_ready_r & i_valid_l & i_data_l[`x_size-1:0]!=x_coord)// both going to right     
	 begin
        o_data_t <=i_data_b;
		  o_valid_t <=1'b1;
	 end
	 else if(i_ready_t & i_valid_b & i_data_b[`x_size-1:0]==x_coord & i_ready_r & i_valid_l & i_data_l[`x_size-1:0]==x_coord & i_data_b[`x_size+`y_size-1:`x_size]!=y_coord & i_data_l[`x_size+`y_size-1:`x_size]!=y_coord)//both going to top
	 begin
        o_data_t <=i_data_l;
		  o_valid_t <=1'b1;
	 end	 
	 else if(i_ready_t & i_valid_l & i_data_l[`x_size-1:0]==x_coord & i_data_l[`x_size+`y_size-1:`x_size] != y_coord)
	 begin
	     o_data_t <=i_data_l;
		  o_valid_t <=1'b1;
	 end
    else if(i_ready_t & i_valid_b & i_data_b[`x_size-1:0]==x_coord & i_data_b[`x_size+`y_size-1:`x_size] != y_coord)
    begin
          o_data_t <=i_data_b;
		    o_valid_t <=1'b1;
	 end
  
    else if(i_ready_t & i_valid_l & i_data_l[`x_size-1:0]==x_coord & i_data_l[`x_size+`y_size-1:`x_size]!=y_coord & i_ready_r & i_valid_pe & i_data_pe[`x_size-1:0]==x_coord & i_data_pe[`x_size+`y_size-1:`x_size]!=y_coord)//left and pe going to top
	 begin
	    o_data_t<=i_data_l;
		o_valid_t<=1'b1;
	 end
    else if(i_ready_t & i_valid_b & i_data_b[`x_size-1:0]==x_coord & i_data_b[`x_size+`y_size-1:`x_size]!=y_coord & i_ready_r & i_valid_pe & i_data_pe[`x_size-1:0]==x_coord & i_data_pe[`x_size+`y_size-1:`x_size]!=y_coord)//bottom and pe going to top
	 begin
	    o_data_t<=i_data_b;
		o_valid_t<=1'b1;
	 end
   	else if(o_ready_pe & i_valid_pe & i_data_pe[`x_size-1:0]==x_coord )
    begin
          o_data_t <=i_data_pe;
		    o_valid_t <=1'b1;
	 end
	else if(i_ready_t & i_valid_b & i_data_b[`x_size-1:0]!=x_coord & i_ready_r & i_valid_pe & i_data_pe[`x_size-1:0]!=x_coord)///bottom and pe going to right
	  begin
	    o_data_t<=i_data_pe;
		o_valid_t<=1'b1;
	  end
    else if(i_ready_t & i_valid_l & i_data_l[`x_size-1:0]!=x_coord & i_ready_r & i_valid_pe & i_data_pe[`x_size-1:0]!=x_coord)// left and pe going to right 
	 begin
	    o_data_t<=i_data_pe;
		o_valid_t<=1'b1;
	 end	 
	 else
	      o_valid_t <=1'b0;
end



/*
always @(posedge clk)
begin
     if(i_valid_b & i_valid_l)
	      o_ready_pe <= 1'b0;
	  else
	      o_ready_pe <= 1'b1;
end
*/

always @(posedge clk)
begin
     	
	if(i_valid_l & i_data_l[`x_size-1:0]==x_coord & i_data_l[`x_size+`y_size-1:`x_size] == y_coord  )
	  begin
	       o_data_pe <=i_data_l;
		    o_valid_pe <=1'b1;
      end
	  
	 else if(i_valid_b & i_data_b[`x_size-1:0]==x_coord & i_data_b[`x_size+`y_size-1:`x_size] == y_coord)
	  begin
	       o_data_pe <=i_data_b;
		    o_valid_pe <=1'b1;
     end

	 else if(i_ready_r & i_valid_l & i_data_l[`x_size-1:0]==x_coord & i_ready_t & i_valid_b & i_data_b[`x_size-1:0]==x_coord & i_data_b[`x_size+`y_size-1:`x_size]==y_coord & i_data_l[`x_size+`y_size-1:`x_size]==y_coord)//both going to pe 
	 begin
          o_data_pe<=i_data_l;
          o_valid_pe<=1'b1;		  
	 end
	  else
	       o_valid_pe <=1'b0;
end

/*


always @(posedge clk)
begin
if(o_ready_pe & i_valid_pe)
 begin
   
    if(i_data_pe[3:0]!=x_coord) 
	 begin  
       if(i_ready_r)
       begin
          o_data_r <=i_data_pe;
		    o_valid_r <=1'b1;
       end  
	 end

	 else if(i_data_pe[7:4]!=y_coord)
	 begin
        if(i_ready_t)
          begin
            o_data_t <=i_data_pe;
			o_valid_t <=1'b1;
          end  
	 end
	 

 end
 
 
 
 
 else if(o_ready_l & i_valid_l)
 begin
   

	if(i_data_l[3:0]!=x_coord)
	 begin
        if(i_ready_r)
          begin
            o_data_r <=i_data_l;
			o_valid_r <=1'b1;
          end  
	 end

	 else if(i_data_l[7:4]!=y_coord)
	 begin
        if(i_ready_t)
          begin
            o_data_t <=i_data_l;
			o_valid_t <=1'b1;
          end  
	 end
	 else
	  begin
        if(i_ready_pe)
          begin
           o_data_pe <=i_data_l;
		   o_valid_pe <=1'b1;
          end		
	  end
	 
	 
 end
 
 
 

 
 
 else if(o_ready_b & i_valid_b)
 begin
   
	
	 if(i_data_b[3:0]!=x_coord)
	 begin
        if(i_ready_r)
          begin
            o_data_r <=i_data_b;
			o_valid_r <=1'b1;
          end  
	 end

	 else if(i_data_b[7:4]!=y_coord)
	 begin
        if(i_ready_t)
          begin
            o_data_t <=i_data_b;
			o_valid_t <=1'b1;
          end  
	 end
	 else
	  begin
        if(i_ready_pe)
          begin
           o_data_pe <=i_data_b;
		   o_valid_pe <=1'b1;
          end		
	  end
 end
 
  
end

*/

endmodule
