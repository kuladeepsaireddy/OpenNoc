
module scheduler #(parameter X=0,Y=0,total_width=0,x_size=0,y_size=0,pck_num=0,data_width=0)(
input            clk,
// PCI - Scheduler interface 
input            i_valid_pci,
input [data_width-1:0]    i_data_pci,
output           o_ready_pci,
// From scheduler to PCI
output reg [data_width-1:0] o_data_pci,
output reg o_valid_pci,
input i_ready_pci,
//Scheduler-NOC interfaces
input i_ready,
output reg o_valid,
output reg [total_width-1:0] o_data,
//from NOC to Schedler
input wea,
input [total_width-1:0] i_data_pe
//output o_ready_pe
);

reg [pck_num-1:0]rd_addr;
wire [pck_num-1:0] wr_addr;
reg [x_size-1:0] x_coord;
reg [y_size-1:0] y_coord;
reg [pck_num-1:0] pck_no;
wire valid_flag;



reg [data_width:0] my_mem [(2**pck_num)-1:0];

initial
begin
  x_coord = 'd0;
  y_coord = 'd1;
  pck_no = 'd0;
  rd_addr<='d0;
end


always @(posedge clk)
begin
    if(i_valid_pci & o_ready_pci)
    begin
        o_data[total_width-1:y_size+x_size+pck_num]<=i_data_pci;
        o_data[x_size+y_size+pck_num-1:y_size+x_size]<=pck_no;
        o_data[x_size+y_size-1:x_size]<=y_coord;
        o_data[x_size-1:0]<=x_coord;
        o_valid<=1'b1;
        pck_no<=pck_no+1;
        if(y_coord < Y-1)
        begin
           y_coord<=y_coord+1;
        end
        else
        begin
            if(x_coord < X-1)
            begin
              x_coord <= x_coord+1;
              y_coord<='b0;
            end
            else
            begin
              x_coord <= 'd0;
              y_coord <= 'd1;   
            end
        end      
    end
    else if(o_valid & !i_ready)
    begin
        o_valid <= 1'b1;
    end
    else
    begin
        o_valid <= 1'b0;
    end
end

assign o_ready_pci = i_ready;
assign valid_flag = my_mem[rd_addr][data_width];
assign wr_addr = i_data_pe[x_size+y_size+pck_num-1:y_size+x_size];

always@(posedge clk)
begin
    if(wea)
    begin 
        my_mem[wr_addr]<=i_data_pe[total_width-1:y_size+x_size+pck_num];
        my_mem[wr_addr][data_width]<=1'b1;
    end
    if(valid_flag & i_ready_pci )
    begin
       my_mem[rd_addr][data_width]<=1'b0;
    end       
end

always@(posedge clk)
 begin
  if(valid_flag & i_ready_pci )
   begin
     o_data_pci <=my_mem[rd_addr];
     o_valid_pci<=1'b1;
     rd_addr<=rd_addr+1;
   end
  else 
   begin
     o_valid_pci<=1'b0;
   end   
 end
 

endmodule

