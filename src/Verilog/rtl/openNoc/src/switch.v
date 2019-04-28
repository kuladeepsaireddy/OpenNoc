/////////////////////////////////////////////////////////////////////////////////////////////
//File Name : switch.v                                                                     //
//Description : Bufferless router following XY routing                                     //
/////////////////////////////////////////////////////////////////////////////////////////////


module switch #(parameter x_coord ='d0,parameter y_coord='d0,X=2,Y=2,data_width=32, x_size=1, y_size=1,total_width=(x_size+y_size+data_width),sw_no=X*Y)
(
input wire clk,
input wire rstn,
input wire i_ready_r,
input wire i_ready_t,
input wire i_ready_pe,
input wire i_valid_l,
input wire i_valid_b,
input wire i_valid_pe,
output wire o_ready_l,
output wire o_ready_b,
output reg  o_ready_pe,
output reg o_valid_r,
output reg o_valid_t,
output reg o_valid_pe,
input wire [total_width-1:0] i_data_l,
input wire [total_width-1:0] i_data_b,
input wire [total_width-1:0] i_data_pe,
output reg [total_width-1:0] o_data_r,
output reg [total_width-1:0] o_data_t,
output reg [total_width-1:0] o_data_pe

);
wire leftToPe;
wire bottomToPe;
wire peTope;
wire leftToRight;
wire leftToTop;
wire bottomToRight;
wire bottomToTop;
wire peToTop;
wire peToRight;

assign  o_ready_l = 1'b1;
assign  o_ready_b = 1'b1;

assign leftToPe = ((i_data_l[x_size-1:0]==x_coord) & (i_data_l[x_size+y_size-1:x_size]==y_coord) & i_valid_l);
assign leftToRight = ((i_data_l[x_size-1:0]!=x_coord) & i_valid_l);
assign leftToTop = (i_data_l[x_size-1:0]==x_coord) & (i_data_l[x_size+y_size-1:x_size]!=y_coord) & i_valid_l;
assign bottomToPe = (i_data_b[x_size-1:0]==x_coord) & (i_data_b[x_size+y_size-1:x_size]==y_coord) & i_valid_b;
assign bottomToRight = (i_data_b[x_size+y_size-1:x_size]==y_coord) & (i_data_b[x_size-1:0]!=x_coord) & i_valid_b;// ? 1'b1 : 1'b0;
assign bottomToTop = (i_data_b[x_size+y_size-1:x_size]!=y_coord ) & i_valid_b;
assign peTope = ((i_data_pe[x_size-1:0]==x_coord) & (i_data_pe[x_size+y_size-1:x_size]==y_coord) & i_valid_pe & o_ready_pe);
assign peToRight = ((i_data_pe[x_size-1:0]!=x_coord) & i_valid_pe & o_ready_pe);
assign peToTop = (~peToRight & (i_data_pe[x_size+y_size-1:x_size]!=y_coord) & i_valid_pe & o_ready_pe);


always @(*)
begin
	//If there are no packets to either right or top, we can accept data from PE
	//If packets have to be sent to both out ports, will have to back pressure the PE
	if((~leftToRight & ~leftToTop & ~leftToPe) | (~bottomToTop & ~bottomToRight & ~bottomToPe))
	begin
		o_ready_pe = 1'b1;
	end
	else
	begin
		o_ready_pe = 1'b0;
	end
end

always @(posedge clk)
begin
	if(!rstn)
		o_valid_r <=1'b0;
	//Whenever data from left wants to go right, it will be given preference
	else
	begin
		casex({leftToRight,leftToTop,leftToPe,bottomToRight,bottomToTop,bottomToPe,peTope,peToRight,peToTop,i_ready_pe})
			10'bxxx_1xx_xxx_x:begin //bottomToRight
				o_data_r  <= i_data_b;
				o_valid_r <= 1'b1;
			end
			10'b1xx_xxx_xxx_x:begin//leftToRight
				o_data_r  <= i_data_l;
				o_valid_r <= 1'b1;
			end
			10'b0xx_xxx_x1x_x:begin//peToRight
				o_data_r  <= i_data_pe;
				o_valid_r <= 1'b1;
			end
			10'bx1x_x1x_xxx_x:begin //leftToTop & bottomToTop
				o_data_r <= i_data_l;
				o_valid_r <= 1'b1;
			end
			10'bx1x_xxx_xx1_x:begin //leftToTop & peToTop
				o_data_r <= i_data_pe;
				o_valid_r <= 1'b1;
			end
			10'bxxx_x1x_xx1_x:begin//peToTop & bottomToTop
				o_data_r  <= i_data_pe;
				o_valid_r <= 1'b1;
			end
			10'bxx1_xxx_1xx_x:begin//leftToPe & peTope
				o_data_r  <= i_data_l;
				o_valid_r <= 1'b1;
			end
			10'bxx1_xx1_xxx_x:begin//leftToPe & bottomToPe
				o_data_r  <= i_data_l;
				o_valid_r <= 1'b1;
			end
			10'bxxx_xx1_1xx_x:begin//peTope & bottomToPe
				o_data_r  <= i_data_b;
				o_valid_r <= 1'b1;
			end
			10'bxx1_xxx_xxx_0:begin//leftToPe & !i_ready_pe
				o_data_r  <= i_data_l;
				o_valid_r <= 1'b1;
			end
			10'bxxx_xxx_1xx_0:begin//peTope & !i_ready_pe
				o_data_r <= i_data_pe;
				o_valid_r <= 1'b1;
			end
			10'bx1x_xx1_xxx_0:begin//leftToTop & bottomToPe & !i_ready_pe
				o_data_r <= i_data_b;
				o_valid_r <= 1'b1;
			end
			10'bxxx_xx1_xx1_0:begin//peToTop & bottomToPe & !i_ready_pe
				o_data_r  <= i_data_b;
				o_valid_r <= 1'b1;
			end
			default:begin
				o_valid_r <= 1'b0;
			end
		endcase
	end
end


always @(posedge clk)
begin
	if(!rstn)
		o_valid_t <= 1'b0;
	else
	begin
		casex({leftToRight,leftToTop,leftToPe,bottomToRight,bottomToTop,bottomToPe,peTope,peToRight,peToTop,i_ready_pe})
			10'bxxx_x1x_xxx_x:begin//bottomToTop
				o_data_t <= i_data_b;
				o_valid_t <= 1'b1;
			end
			10'bx1x_xxx_xxx_x:begin //leftToTop
				o_data_t <= i_data_l;
				o_valid_t <= 1'b1;
			end
			10'bxxx_xxx_xx1_x:begin //peToTop
				o_data_t <= i_data_pe;
				o_valid_t <= 1'b1;
			end
			10'b1xx_1xx_xxx_x:begin //bottomToRight & leftToRight
				o_data_t <= i_data_l;
				o_valid_t <= 1'b1;
			end
			10'bxxx_1xx_x1x_x:begin //bottomToRight & peToRight
				o_data_t <= i_data_pe;
				o_valid_t <= 1'b1;
			end
			10'bxx1_1xx_xxx_0:begin//bottomToRight & leftToPe & ~i_ready_pe
				o_data_t <= i_data_l;
				o_valid_t <= 1'b1;
			end
			10'bxxx_1xx_1xx_0:begin//bottomToRight & peTope & ~i_ready_pe
				o_data_t <= i_data_pe;
				o_valid_t <= 1'b1;
			end
			10'b1xx_xxx_x1x_x:begin //leftToRight & peToRight
				o_data_t <= i_data_pe;
				o_valid_t <= 1'b1;
			end
			10'b1xx_xxx_1xx_0:begin //leftToRight & peTope & ~i_ready_pe
				o_data_t <= i_data_pe;
				o_valid_t <= 1'b1;
			end
			10'bxx1_xxx_x1x_0:begin//leftToPe & peToRight & ~i_ready_pe
				o_data_t <= i_data_l;
				o_valid_t <= 1'b1;
			end
			10'bxx1_xxx_1xx_0:begin //leftToPe & peTope & ~i_ready_pe
				o_data_t <= i_data_pe;
				o_valid_t <= 1'b1;
			end
			10'bxxx_xx1_1xx_0:begin//bottomToPe & peTope & ~i_ready_pe
				o_data_t <= i_data_pe;
				o_valid_t <= 1'b1;
			end
			10'bxxx_xx1_xxx_0:begin//bottomToPe & ~i_ready_pe
				o_data_t <= i_data_b;
				o_valid_t <= 1'b1;
			end
			default:begin
				o_valid_t <= 1'b0;
			end
		endcase
	end
end

always @(posedge clk)
begin
	if(!rstn)
		o_valid_pe <= 1'b0; 
		
	else if(peTope & i_ready_pe)
	begin
		o_data_pe <= i_data_pe;
		o_valid_pe <=1'b1;
	end
	else if(bottomToPe & i_ready_pe)
	begin
		o_data_pe  <= i_data_b;
		o_valid_pe <= 1'b1;
	end
	else if(leftToPe & i_ready_pe)
	begin
		o_data_pe <= i_data_l;
		o_valid_pe <= 1'b1;
	end
	else if(o_valid_pe & ~i_ready_pe)
		o_valid_pe <=1'b1;
	else
		o_valid_pe <=1'b0;
end


endmodule
