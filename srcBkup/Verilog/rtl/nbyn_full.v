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
input  i_ready_pci


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
					 .i_valid_pci(i_valid_pci),
					 .i_data_pci(i_data_pci),
					 .o_ready_pci(o_ready_pci),
					 .o_data_pci(o_data_pci),
					 .o_valid_pci(o_valid_pci),
					 .i_ready_pci(i_ready_pci)
					 //.main_input(main_input),
					 //.main_valid_pe(main_valid_pe),
					 //.main_output(main_output),
					 //.o_ready_scheduler(o_ready_scheduler),
					 //.o_valid_scheduler(o_valid_scheduler)
					 );
		 end

       else if(x!=0 & y==0)
	     begin: instnce
              nbyn_block #(.x_coord(x),.y_coord(y))
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
                     .o_data_t(w_data_t[(x*`Y)+y]));
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
		 
		 
      /*else if(x==`X-1 & y==0 )
	     begin: instnce
		     nbyn_block #(.x_coord(x),.y_coord(y))               ///// z-1 = 255
			    nbyn_instance(
			         .clk(clk),      
                     .i_ready_r(o_ready_l[y]),     
			         .i_ready_t(i_ready_t[(x*`Y)+y]),
					 .i_valid_l(o_valid_r[(x*`X)+y-`X]),						  
					 .i_valid_b(o_valid_t[(x*`Y)+y+(`Y-1)]),						  
					 .o_ready_l(i_ready_r[(x*`X)+y-`X]),						  
					 .o_ready_b(i_ready_t[(x*`Y)+y+(`Y-1)]),						  
					 .o_valid_r(i_valid_l[y]),						  
					 .o_valid_t(o_valid_t[(x*`Y)+y]),						  
					 .i_data_l(o_data_r[(x*`X)+y-`X]),						 
                     .i_data_b(o_data_t[(x*`Y)+y+(`Y-1)]),
                     .o_data_r(i_data_l[y]),
                     .o_data_t(o_data_t[(x*`Y)+y]),
					 .main_input(16'd0),
					 .main_valid_pe(1'b0),
					 .main_output());
        
		
		end					 
		 
     // else if(x==`X-1 & y!=0)
	     begin: instnce
		     nbyn_block #(.x_coord(x),.y_coord(y))
			    nbyn_instance(
			         .clk(clk),      
                     .i_ready_r(o_ready_l[y]),     
			         .i_ready_t(i_ready_t[(x*`Y)+y]),
					 .i_valid_l(o_valid_r[(x*`X)+y-`X]),				  
					 .i_valid_b(o_valid_t[(x*`Y)+y-1]),						  
					 .o_ready_l(i_ready_r[(x*`X)+y-`X]),						  
					 .o_ready_b(i_ready_t[(x*`Y)+y-1]),						  
					 .o_valid_r(i_valid_l[y]),						  
					 .o_valid_t(o_valid_t[(x*`Y)+y]),						  
					 .i_data_l(o_data_r[(x*`X)+y-`X]),						 
                     .i_data_b(o_data_t[(x*`Y)+y-1]),
                     .o_data_r(i_data_l[y]),
                     .o_data_t(o_data_t[(x*`Y)+y]),
					 .main_input(16'd0),
					 .main_valid_pe(1'b0),
					 .main_output());
		 end*/


	  /*if(x==z-1 & y==z-1 )
         begin: instnce
		     nbyn_block #(.x_coord=x,.y_coord=y)
			    nbyn_instance(
			         .clk(clk),      
			         .//i_ready_l(//o_ready_r[(x*z)-y-z]), ////// 
                     .i_ready_r(o_ready_l[-y]),     
			         .i_ready_t(i_ready_t[(x*z)-y]),
			         .//i_ready_b(//o_ready_t[(x*z)-y+1]),                         
					 .i_valid_l(o_valid_r[(x*z)-y-z]),///						  
					 .//i_valid_r(//o_valid_l[-y]),						  
					 .//i_valid_t(//i_valid_t[(x*z)-y]),						  
					 .i_valid_b(o_valid_t[(x*z)-y+1]),						  
					 .o_ready_l(i_ready_r[(x*z)-y-z]),						  
					 .//o_ready_r(//i_ready_l[-y]),						  
					 .//o_ready_t(//o_ready_t[(x*z)-y]),						  
					 .o_ready_b(i_ready_t[(x*z)-y+1]),						  
					 .//o_valid_l(//i_valid_r[(x*z)-y-z]),						  
					 .o_valid_r(i_valid_l[-y]),						  
					 .o_valid_t(o_valid_t[(x*z)-y]),						  
					 .//o_valid_b(//i_valid_t[(x*z)-y+1]),						  
					 .i_data_l(o_data_r[(x*z)-y-z]),						 
                     .//i_data_r(//o_data_l[-y]),
                     .//i_data_t(//i_data_t[(x*z)-y]),
                     .i_data_b(o_data_t[(x*z)-y+1]),
                     .//o_data_l(//i_data_r[(x*z)-y-z]),
                     .o_data_r(i_data_l[-y]),
                     .o_data_t(o_data_t[(x*z)-y]),
                     .//o_data_b(//i_data_t[(x*z)-y+1]));
		 end*/
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
			end
     end			
endgenerate 
   

/*scheduler_noc scheduler_inst(

.clk(clk),
// PCI - Scheduler interface ////
.i_valid(i_valid_pci),
.i_data(i_data_pci),
.o_ready(o_ready_pci),

///From scheduler to PCI///

.o_data_pci(o_data_pci),
.o_valid_pci(o_valid_pci),
.i_ready_pci(i_ready_pci),

//from Scheduler to NOC interface////
.i_ready(o_ready_scheduler),
.o_valid(main_valid_pe),
.o_data(main_input),

//from NOC to Schedler////
.wea(o_valid_scheduler),
.i_data_pe(main_output)

);*/

















endmodule