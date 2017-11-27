`include "include_file.v"

module openNocTop(
input wire clk,
input wire rst,
// PCI - Scheduler interface ////
input i_valid_pci,
input wire [`data_width-1:0] i_data_pci,
output o_ready_pci,

///From scheduler to PCI///

output wire [`data_width-1:0] o_data_pci,
output o_valid_pci,
input  i_ready_pci,
///To PEs
input  wire [`X*`Y-1:0] i_valid_pe,
output wire [`X*`Y-1:0] o_ready_pe,
output wire [`X*`Y-1:0] o_valid_pe,
input  wire [`X*`Y*`total_width-1:0] i_data_pe,
output wire [`X*`Y*`total_width-1:0] o_data_pe
);

/*wire   main_input;
wire main_valid_pe;
wire main_output;
wire o_ready_scheduler;
wire o_valid_scheduler;*/
wire  r_ready_r[`X*`Y-1:0];
wire  r_ready_t[`X*`Y-1:0];
wire  r_valid_l[`X*`Y-1:0];
wire  r_valid_b[`X*`Y-1:0];
wire  w_ready_l[`X*`Y-1:0];
wire  w_ready_b[`X*`Y-1:0];
wire  w_valid_r[`X*`Y-1:0];
wire  w_valid_t[`X*`Y-1:0];
//wire [15:0]  r_data_l[`X*`Y-1:0];
//wire [15:0]  r_data_b[`X*`Y-1:0];
wire [`total_width-1:0]  w_data_r[`X*`Y-1:0];
wire [`total_width-1:0]  w_data_t[`X*`Y-1:0];


generate
genvar x, y; 
for (x=0;x<`X;x=x+1) begin:xs
   for (y=0; y<`Y; y=y+1) begin:ys
      if(x==0 & y==0)
	     begin: instnce
		     nbyn_block_main #(.x_coord(x),.y_coord(y))
			   nbyn_main_instance(
			         .clk(clk),    
			         .rst(rst),  
                     .i_ready_r(r_ready_r[(x*`X)+y]),     
			         .i_ready_t(r_ready_t[(x*`Y)+y]),
					 .i_valid_l(w_valid_r[(x*`X)+y+(`X*(`X-1))]),						  
					 .i_valid_b(w_valid_t[(x*`Y)+y+(`Y-1)]),						  
					 .o_ready_l(r_ready_r[(x*`X)+y+(`X*(`X-1))]),						  
					 .o_ready_b(r_ready_t[(x*`Y)+y+(`Y-1)]),						  
					 .o_valid_r(w_valid_r[(x*`X)+y]),						  
					 .o_valid_t(w_valid_t[(x*`Y)+y]),						  
					 .i_data_l(w_data_r[(x*`X)+y+(`X*(`X-1))]),						 
                     .i_data_b(w_data_t[(x*`Y)+y+(`Y-1)]),
                     .o_data_r(w_data_r[(x*`X)+y]),
                     .o_data_t(w_data_t[(x*`Y)+y]),
					 .i_valid_pe(i_valid_pe[(y*`X)+x]),
                     .o_ready_pe(o_ready_pe[(y*`X)+x]),
                     .o_valid_pe(o_valid_pe[(y*`X)+x]),
                     .i_data_pe(i_data_pe[(((y*`X)+x)*`total_width)+:`total_width]),
                     .o_data_pe(o_data_pe[(((y*`X)+x)*`total_width)+:`total_width])
					 );
		 end

       else if(x!=0 & y==0)
	     begin: instnce
              nbyn #(.x_coord(x),.y_coord(y))
			     nbyn_instance(		  
			         .clk(clk),      
                     .i_ready_r(r_ready_r[(x*`X)+y]),     
			         .i_ready_t(r_ready_t[(x*`Y)+y]),
					 .i_valid_l(w_valid_r[(x*`X)+y-`X]),						  
					 .i_valid_b(w_valid_t[(x*`Y)+y+(`Y-1)]),						  
					 .o_ready_l(r_ready_r[(x*`X)+y-`X]),						  
					 .o_ready_b(r_ready_t[(x*`Y)+y+(`Y-1)]),						  
					 .o_valid_r(w_valid_r[(x*`X)+y]),						  
					 .o_valid_t(w_valid_t[(x*`Y)+y]),						  
					 .i_data_l(w_data_r[(x*`X)+y-`X]),						 
                     .i_data_b(w_data_t[(x*`Y)+y+(`Y-1)]),
                     .o_data_r(w_data_r[(x*`X)+y]),
                     .o_data_t(w_data_t[(x*`Y)+y]),
                     .i_valid_pe(i_valid_pe()),
                     .o_ready_pe(),
                     .o_valid_pe(),
                     .i_data_pe(),
                     .o_data_pe()
                     );
		 end

      else if(x==0 & y!=0 )
	     begin: instnce
		     nbyn_block #(.x_coord(x),.y_coord(y))
			    nbyn_instance(
			         .clk(clk),      
                     .i_ready_r(r_ready_r[(x*`X)+y]),     
			         .i_ready_t(r_ready_t[(x*`Y)+y]),
					 .i_valid_l(w_valid_r[(x*`X)+y+(`X*(`X-1))]),						  
					 .i_valid_b(w_valid_t[(x*`Y)+y-1]),						  
					 .o_ready_l(r_ready_r[(x*`X)+y+(`X*(`X-1))]),						  
					 .o_ready_b(r_ready_t[(x*`Y)+y-1]),						  
					 .o_valid_r(w_valid_r[(x*`X)+y]),						  
					 .o_valid_t(w_valid_t[(x*`Y)+y]),						  
					 .i_data_l(w_data_r[(x*`X)+y+(`X*(`X-1))]),						 
                     .i_data_b(w_data_t[(x*`Y)+y-1]),
                     .o_data_r(w_data_r[(x*`X)+y]),
                     .o_data_t(w_data_t[(x*`Y)+y]));
		 end		 

      else if(x!=0 & y!=0)
	     begin: instnce
		     nbyn_block #(.x_coord(x),.y_coord(y))
			    nbyn_instance(
			         .clk(clk),      
                     .i_ready_r(r_ready_r[(x*`X)+y]),     
			         .i_ready_t(r_ready_t[(x*`Y)+y]),
					 .i_valid_l(w_valid_r[(x*`X)+y-`X]),						  
					 .i_valid_b(w_valid_t[(x*`Y)+y-1]),						  
					 .o_ready_l(r_ready_r[(x*`X)+y-`X]),						  
					 .o_ready_b(r_ready_t[(x*`Y)+y-1]),						  
					 .o_valid_r(w_valid_r[(x*`X)+y]),						  
					 .o_valid_t(w_valid_t[(x*`Y)+y]),						  
					 .i_data_l(w_data_r[(x*`X)+y-`X]),						 
                     .i_data_b(w_data_t[(x*`Y)+y-1]),
                     .o_data_r(w_data_r[(x*`X)+y]),
                     .o_data_t(w_data_t[(x*`Y)+y]));
		 end
	end
 end			
endgenerate 
   

endmodule