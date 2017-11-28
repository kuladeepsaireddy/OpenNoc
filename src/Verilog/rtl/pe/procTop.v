`include "include_file.v"

module procTop (
input  wire clk,
input  wire rstn,
//PE interfaces
output wire [(`X*`Y)-1:0]              r_valid_pe,
output wire [(`total_width*`X*`Y)-1:0] r_data_pe,
input  wire [(`X*`Y)-1:0]              r_ready_pe,
input wire [(`X*`Y)-1:0]               w_valid_pe,
input wire [(`total_width*`X*`Y)-1:0]  w_data_pe,
//PCIe interfaces
input               i_valid_pci,
input wire [255:0]  i_data_pci,
output              o_ready_pci,
output wire [255:0] o_data_pci,
output              o_valid_pci,
input               i_ready_pci
);


generate
genvar x, y; 
for (x=0;x<`X;x=x+1) begin:xs
    for (y=0; y<`Y; y=y+1) begin:ys
        if(x==0 & y==0)
	    begin: instnce
				nbyn_pe_main main_pe(

				.clk(clk),
				.rst(rstn),
				.i_data(w_data_pe[(`total_width*x)+(`total_width*`X*y)+:`total_width]),
				.i_ready(r_ready_pe[x+`X*y]),
				.i_valid(w_valid_pe[x+`X*y]),
				.o_data(r_data_pe[(`total_width*x)+(`total_width*`X*y)+:`total_width]),
				.o_valid(r_valid_pe[x+`X*y]),

				.i_valid_pci(i_valid_pci),
				.i_data_pci(i_data_pci),
				.o_ready_pci(o_ready_pci),
				.o_data_pci(o_data_pci),
				.o_valid_pci(o_valid_pci),
				.i_ready_pci(i_ready_pci)
			);
		end
        else
        begin: instnce
		nbyn_pe pe(
			.clk(clk),
			.i_data(w_data_pe[(`total_width*x)+(`total_width*`X*y)+:`total_width]),
			.i_ready(r_ready_pe[x+`X*y]),
			.i_valid(w_valid_pe[x+`X*y]),
			.o_data(r_data_pe[(`total_width*x)+(`total_width*`X*y)+:`total_width]),
			.o_valid(r_valid_pe[x+`X*y])
		);
        end
	end
end			
endgenerate 

endmodule