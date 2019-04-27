
module inverter #(parameter total_width=0,x_size=0,y_size=0,pck_num=0,iter=0)(
input wire clk,
input wire rst,
input wire [total_width-1:0] i_data,
input wire i_valid,
output  wire [total_width-1:0] o_data,
output wire o_valid,
input wire i_ready,
output wire o_ready
);
integer x;
integer recvCounter=0;
reg fifoWrEn;
reg [total_width-1:0] inv_data;
assign o_ready = 1'b1;
myFifo fifo (
  .s_axis_aresetn(rst),          // input wire s_axis_aresetn
  .s_axis_aclk(clk),                // input wire s_axis_aclk
  .s_axis_tvalid(fifoWrEn),            // input wire s_axis_tvalid
  .s_axis_tready(),            // output wire s_axis_tready
  .s_axis_tdata(inv_data),              // input wire [15 : 0] s_axis_tdata
  .m_axis_tvalid(o_valid),            // output wire m_axis_tvalid
  .m_axis_tready(i_ready),            // input wire m_axis_tready
  .m_axis_tdata(o_data),              // output wire [15 : 0] m_axis_tdata
  .axis_data_count(),        // output wire [31 : 0] axis_data_count
  .axis_wr_data_count(),  // output wire [31 : 0] axis_wr_data_count
  .axis_rd_data_count()  // output wire [31 : 0] axis_rd_data_count
);



always @(posedge clk)
begin 
    if(i_valid & o_ready)
    begin
       recvCounter <= recvCounter+1;
       fifoWrEn <= 1'b1;
       for(x=0;x<iter;x=x+1)
       begin
           inv_data[x_size+y_size+pck_num+x*8+:8]<=8'hff-i_data[x_size+y_size+pck_num+x*8+:8];
       end
       inv_data[x_size+y_size-1:0] <= 'h0;
       inv_data[x_size+y_size+pck_num-1:y_size+x_size]<=i_data[x_size+y_size+pck_num-1:y_size+x_size];
    end
    else if(fifoWrEn & ~o_ready)
       fifoWrEn <= 1'b1;
    else
       fifoWrEn <= 1'b0;
end

endmodule