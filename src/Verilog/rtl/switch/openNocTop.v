module openNocTop #(parameter X=4,Y=4,data_width=256, x_size=2, y_size=2,total_width=(x_size+y_size+data_width),sw_no=X*Y)
(
input wire clk,
input wire rstn,
input wire [(X*Y)-1:0] r_valid_pe,
input wire [(total_width*X*Y)-1:0] r_data_pe,
output wire [(X*Y)-1:0] r_ready_pe,
output wire [(X*Y)-1:0] w_valid_pe,
output wire [(total_width*X*Y)-1:0] w_data_pe
);

wire  r_ready_r[X*Y-1:0];
wire  r_ready_t[X*Y-1:0];
wire  r_valid_l[X*Y-1:0];
wire  r_valid_b[X*Y-1:0];
wire  w_ready_l[X*Y-1:0];
wire  w_ready_b[X*Y-1:0];
wire  w_valid_r[X*Y-1:0];
wire  w_valid_t[X*Y-1:0];
wire [total_width-1:0]  w_data_r[X*Y-1:0];
wire [total_width-1:0]  w_data_t[X*Y-1:0];


generate
genvar x, y; 
for (x=0;x<X;x=x+1) begin:xs
   for (y=0; y<Y; y=y+1) begin:ys
      if(x==0 & y==0)
	     begin: instnce
		     nbyn #(.x_coord(x),.y_coord(y),.X(X),.Y(Y),.data_width(data_width), .x_size(x_size), .y_size(y_size),.total_width(total_width))
			   nbyn_instance(
			         .clk(clk), 
			         .rstn(rstn),     
                     .i_ready_r(r_ready_r[(x*X)+y]),     
			         .i_ready_t(r_ready_t[(x*Y)+y]),
					 .i_valid_l(w_valid_r[(x*X)+y+(X*(X-1))]),						  
					 .i_valid_b(w_valid_t[(x*Y)+y+(Y-1)]),
					 .i_valid_pe(r_valid_pe[x+X*y:x+X*y]),
					 .o_ready_l(r_ready_r[(x*X)+y+(X*(X-1))]),						  
					 .o_ready_b(r_ready_t[(x*Y)+y+(Y-1)]),
                     .o_ready_pe(r_ready_pe[x+X*y:x+X*y]),					 
					 .o_valid_r(w_valid_r[(x*X)+y]),						  
					 .o_valid_t(w_valid_t[(x*Y)+y]),
					 .o_valid_pe(w_valid_pe[x+X*y:x+X*y]),
					 .i_data_l(w_data_r[(x*X)+y+(X*(X-1))]),						 
                     .i_data_b(w_data_t[(x*Y)+y+(Y-1)]),
                     .o_data_r(w_data_r[(x*X)+y]),
                     .o_data_t(w_data_t[(x*Y)+y]),
					 .i_data_pe(r_data_pe[(total_width*x)+(total_width*X*y)+:total_width]),
					 .o_data_pe(w_data_pe[(total_width*x)+(total_width*X*y)+:total_width])
					 );
		 end

       else if(x!=0 & y==0)
	     begin: instnce
              nbyn #(.x_coord(x),.y_coord(y),.X(X),.Y(Y),.data_width(data_width), .x_size(x_size), .y_size(y_size),.total_width(total_width))
			     nbyn_instance(		  
			         .clk(clk), 
			         .rstn(rstn),     
                     .i_ready_r(r_ready_r[(x*X)+y]),     
			         .i_ready_t(r_ready_t[(x*Y)+y]),
					 .i_valid_l(w_valid_r[(x*X)+y-X]),						  
					 .i_valid_b(w_valid_t[(x*Y)+y+(Y-1)]),
					 .i_valid_pe(r_valid_pe[x+X*y:x+X*y]),
					 .o_ready_l(r_ready_r[(x*X)+y-X]),						  
					 .o_ready_b(r_ready_t[(x*Y)+y+(Y-1)]),
					 .o_ready_pe(r_ready_pe[x+X*y:x+X*y]),
					 .o_valid_r(w_valid_r[(x*X)+y]),						  
					 .o_valid_t(w_valid_t[(x*Y)+y]),
                     .o_valid_pe(w_valid_pe[x+X*y:x+X*y]),					 
					 .i_data_l(w_data_r[(x*X)+y-X]),						 
                     .i_data_b(w_data_t[(x*Y)+y+(Y-1)]),
                     .o_data_r(w_data_r[(x*X)+y]),
                     .o_data_t(w_data_t[(x*Y)+y]),
					 .i_data_pe(r_data_pe[(total_width*x)+(total_width*X*y)+:total_width]),
					 .o_data_pe(w_data_pe[(total_width*x)+(total_width*X*y)+:total_width]));
		 end

      else if(x==0 & y!=0 )
	     begin: instnce
		     nbyn #(.x_coord(x),.y_coord(y),.X(X),.Y(Y),.data_width(data_width), .x_size(x_size), .y_size(y_size),.total_width(total_width))
			    nbyn_instance(
			         .clk(clk),   
			         .rstn(rstn),   
                     .i_ready_r(r_ready_r[(x*X)+y]),     
			         .i_ready_t(r_ready_t[(x*Y)+y]),
					 .i_valid_l(w_valid_r[(x*X)+y+(X*(X-1))]),						  
					 .i_valid_b(w_valid_t[(x*Y)+y-1]),
                     .i_valid_pe(r_valid_pe[x+X*y:x+X*y]),					 
					 .o_ready_l(r_ready_r[(x*X)+y+(X*(X-1))]),						  
					 .o_ready_b(r_ready_t[(x*Y)+y-1]),
					 .o_ready_pe(r_ready_pe[x+X*y:x+X*y]),
					 .o_valid_r(w_valid_r[(x*X)+y]),						  
					 .o_valid_t(w_valid_t[(x*Y)+y]),
					   .o_valid_pe(w_valid_pe[x+X*y:x+X*y]),	
					 .i_data_l(w_data_r[(x*X)+y+(X*(X-1))]),						 
                     .i_data_b(w_data_t[(x*Y)+y-1]),
                     .o_data_r(w_data_r[(x*X)+y]),
                     .o_data_t(w_data_t[(x*Y)+y]),
					 .i_data_pe(r_data_pe[(total_width*x)+(total_width*X*y)+:total_width]),
					 .o_data_pe(w_data_pe[(total_width*x)+(total_width*X*y)+:total_width]))
					 ;
		 end		 

      else if(x!=0 & y!=0)
	     begin: instnce
		     nbyn #(.x_coord(x),.y_coord(y),.X(X),.Y(Y),.data_width(data_width), .x_size(x_size), .y_size(y_size),.total_width(total_width))
			    nbyn_instance(
			         .clk(clk),
			         .rstn(rstn),      
                     .i_ready_r(r_ready_r[(x*X)+y]),     
			         .i_ready_t(r_ready_t[(x*Y)+y]),
					 .i_valid_l(w_valid_r[(x*X)+y-X]),						  
					 .i_valid_b(w_valid_t[(x*Y)+y-1]),
					 .i_valid_pe(r_valid_pe[x+X*y:x+X*y]),	
					 .o_ready_l(r_ready_r[(x*X)+y-X]),						  
					 .o_ready_b(r_ready_t[(x*Y)+y-1]),
					 .o_ready_pe(r_ready_pe[x+X*y:x+X*y]),
					 .o_valid_r(w_valid_r[(x*X)+y]),						  
					 .o_valid_t(w_valid_t[(x*Y)+y]),
				     .o_valid_pe(w_valid_pe[x+X*y:x+X*y]),
					 .i_data_l(w_data_r[(x*X)+y-X]),						 
                     .i_data_b(w_data_t[(x*Y)+y-1]),
                     .o_data_r(w_data_r[(x*X)+y]),
                     .o_data_t(w_data_t[(x*Y)+y]),
					 .i_data_pe(r_data_pe[(total_width*x)+(total_width*X*y)+:total_width]),
					 .o_data_pe(w_data_pe[(total_width*x)+(total_width*X*y)+:total_width]));
		    end
	    end
      end			
endgenerate 

endmodule