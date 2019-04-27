module interfacePE #(parameter X=0,Y=0,total_width=0,x_size=0,y_size=0,pck_num=0,data_width=0)(
input wire                    clk,
input wire                    rst,
//from switch
input wire [total_width-1:0] i_data,
input wire                    i_valid,
output wire                   o_ready,
//to switch
output  [total_width-1:0] o_data,
output wire                o_valid,
input  wire                i_ready,
// PCI - Scheduler interface
input                      i_valid_pci,
input wire [data_width-1:0]         i_data_pci,
output                     o_ready_pci,
///From scheduler to PCI
output wire [data_width-1:0]        o_data_pci,
output                     o_valid_pci,
input                      i_ready_pci
);


wire [total_width-1:0]  main_input;
wire main_valid_pe;
reg [total_width-1:0] main_output;
wire o_ready_scheduler;
reg o_valid_scheduler;

assign o_ready = 1'b1;

myFifo fifo (

  .s_axis_aresetn(rst),          // input wire s_axis_aresetn
  .s_axis_aclk(clk),                // input wire s_axis_aclk
  .s_axis_tvalid(main_valid_pe),            // input wire s_axis_tvalid
  .s_axis_tready(o_ready_scheduler),            // output wire s_axis_tready
  .s_axis_tdata(main_input),              // input wire [15 : 0] s_axis_tdata
  .m_axis_tvalid(o_valid),            // output wire m_axis_tvalid
  .m_axis_tready(i_ready),            // input wire m_axis_tready
  .m_axis_tdata(o_data),              // output wire [15 : 0] m_axis_tdata
  .axis_data_count(),        // output wire [31 : 0] axis_data_count
  .axis_wr_data_count(),  // output wire [31 : 0] axis_wr_data_count
  .axis_rd_data_count()  // output wire [31 : 0] axis_rd_data_count
);

integer FifoCounter=0; 

always @(posedge clk)
begin
    if(main_valid_pe&o_ready_scheduler)
		FifoCounter <= FifoCounter + 1;
end

scheduler #(.X(X),.Y(Y),.total_width(total_width),.x_size(x_size),.y_size(y_size),.pck_num(pck_num),.data_width(data_width))scheduler_inst(
.clk(clk),
//PCI - Scheduler interface ////
.i_valid_pci(i_valid_pci),
.i_data_pci(i_data_pci),
.o_ready_pci(o_ready_pci),
//From scheduler to PCI///
.o_data_pci(o_data_pci),
.o_valid_pci(o_valid_pci),
.i_ready_pci(i_ready_pci),
//from Scheduler to NOC interface////
.i_ready(o_ready_scheduler),
.o_valid(main_valid_pe),
.o_data(main_input),
//from NOC to Schedler////
.wea(i_valid),
.i_data_pe(i_data)
);


endmodule