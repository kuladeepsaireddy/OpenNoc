//`include "include_file.v"

module procTop #(parameter X=8, Y=8,pck_num=12,data_width=256,x_size=$clog2(X),y_size=$clog2(Y),total_width=(x_size+y_size+pck_num+data_width))(
input  wire clk,
input  wire rstn,
//PE interfaces
output wire [(X*Y)-1:0]              r_valid_pe,
output wire [(total_width*X*Y)-1:0] r_data_pe,
input  wire [(X*Y)-1:0]              r_ready_pe,
input wire [(X*Y)-1:0]               w_valid_pe,
input wire [(total_width*X*Y)-1:0]  w_data_pe,
output wire [(X*Y)-1:0]              w_ready_pe,
//PCIe interfaces
input               i_valid,
input wire [data_width-1:0]  i_data,
output              o_ready,
output wire [data_width-1:0] o_data,
output              o_valid,
input               i_ready
);


generate
genvar x, y; 
for (x=0;x<X;x=x+1) begin:xs
    for (y=0; y<Y; y=y+1) begin:ys
        if(x==0 & y==0)
	    begin: instnce
				interfacePE #(.X(X),.Y(Y),.total_width(total_width),.x_size(x_size),.y_size(y_size),.pck_num(pck_num),.data_width(data_width))iPE(
				.clk(clk),
				.rst(rstn),
				.i_data(w_data_pe[(total_width*x)+(total_width*X*y)+:total_width]),
				.i_ready(r_ready_pe[x+X*y]),
				.i_valid(w_valid_pe[x+X*y]),
				.o_data(r_data_pe[(total_width*x)+(total_width*X*y)+:total_width]),
				.o_valid(r_valid_pe[x+X*y]),
                .o_ready(w_ready_pe[x+X*y]),
				.i_valid_pci(i_valid),
				.i_data_pci(i_data),
				.o_ready_pci(o_ready),
				.o_data_pci(o_data),
				.o_valid_pci(o_valid),
				.i_ready_pci(i_ready)
			);
		end
        else
        begin: instnce
		inverter #(.total_width(total_width),.x_size(x_size),.y_size(y_size),.pck_num(pck_num),.iter(data_width/8))pe(
			.clk(clk),
			.rst(rstn),
			.i_data(w_data_pe[(total_width*x)+(total_width*X*y)+:total_width]),
			.i_ready(r_ready_pe[x+X*y]),
			.i_valid(w_valid_pe[x+X*y]),
			.o_data(r_data_pe[(total_width*x)+(total_width*X*y)+:total_width]),
			.o_valid(r_valid_pe[x+X*y]),
			.o_ready(w_ready_pe[x+X*y])
		);
        end
	end
end			
endgenerate 

endmodule