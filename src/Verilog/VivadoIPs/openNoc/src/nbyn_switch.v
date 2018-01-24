module nbyn #(parameter x_coord ='d0,parameter y_coord='d0,X=2,Y=2,data_width=32, x_size=1, y_size=1,total_width=(x_size+y_size+data_width),sw_no=X*Y) //parameter pck_no=16'd0)
(
input wire clk,
input wire rstn,
input wire i_ready_r,
input wire i_ready_t,
//input wire i_ready_pe,
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
reg  leftToRight;
reg leftToTop;
reg bottomToRight;
reg bottomToTop;
wire peToTop;
wire peToRight;

assign  o_ready_l = 1'b1;
assign  o_ready_b = 1'b1;

assign leftToPe = ((i_data_l[x_size-1:0]==x_coord) & (i_data_l[x_size+y_size-1:x_size]==y_coord) & i_valid_l);
//assign leftToRight = ((i_data_l[x_size-1:0]!=x_coord) & i_valid_l);
//assign leftToTop = (~leftToRight & (i_data_l[x_size+y_size-1:x_size]!=y_coord) & i_valid_l);

always @(*)
begin
    if(i_valid_l)
    begin
        if(i_data_l[x_size-1:0]!=x_coord)
        begin
            leftToTop = 1'b0;
            leftToRight = 1'b1;
        end
        else if(i_data_l[x_size+y_size-1:x_size]!=y_coord)
        begin
            leftToTop   = 1'b1;
            leftToRight = 1'b0;
        end
        else
        begin
            leftToTop   = 1'b0;
            leftToRight = 1'b0;
        end
    end
    else
    begin
         leftToTop = 1'b0;
         leftToRight = 1'b0;
    end
end


always @(*)
begin
    if(i_valid_b)
    begin
        if(i_data_b[x_size+y_size-1:x_size]!=y_coord)
        begin
            bottomToTop   = 1'b1;
            bottomToRight = 1'b0;
        end
        else if(i_data_b[x_size-1:0]!=x_coord)
        begin
            bottomToTop = 1'b0;
            bottomToRight = 1'b1;
        end
        else
        begin
            bottomToTop   = 1'b0;
            bottomToRight = 1'b0;
        end
    end
    else
    begin
         bottomToTop = 1'b0;
         bottomToRight = 1'b0;
    end
end

assign bottomToPe = ((i_data_b[x_size-1:0]==x_coord) & (i_data_b[x_size+y_size-1:x_size]==y_coord) & i_valid_b);
//assign bottomToTop = (~bottomToRight & (i_data_b[x_size+y_size-1:x_size]!=y_coord ) & i_valid_b);
//assign bottomToRight = ((i_data_b[x_size-1:0]!=x_coord) & i_valid_b);// ? 1'b1 : 1'b0;

assign peTope = ((i_data_pe[x_size-1:0]==x_coord) & (i_data_pe[x_size+y_size-1:x_size]==y_coord) & i_valid_pe & o_ready_pe);
assign peToRight = ((i_data_pe[x_size-1:0]!=x_coord) & i_valid_pe & o_ready_pe);
assign peToTop = (~peToRight & (i_data_pe[x_size+y_size-1:x_size]!=y_coord) & i_valid_pe & o_ready_pe);


always @(*)
begin
	//If there are no packets to either right or top, we can accept data from PE
	//If packets have to be sent to both out ports, will have to back pressure the PE
	if((~leftToRight & ~leftToTop) | (~bottomToTop & ~bottomToRight))
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
	if(bottomToRight) 
	begin
		o_data_r  <= i_data_b;
		o_valid_r <= 1'b1;
	end
	else if(leftToTop)
	begin
		if(bottomToTop)
		begin
			o_data_r <= i_data_b;
			o_valid_r <= 1'b1;
		end
		else if(peToTop|peToRight)
		begin
			o_data_r <= i_data_pe;
			o_valid_r <= 1'b1;
		end
		else if(bottomToPe & peTope)
		begin
			o_data_r <= i_data_b;
			o_valid_r <= 1'b1;
		end
		else
			o_valid_r <= 1'b0;
	end
	else if(peToTop)
	begin
		if(bottomToTop)
		begin
			o_data_r  <= i_data_b;
			o_valid_r <= 1'b1;
		end
		else if(leftToRight)
		begin
			o_data_r  <= i_data_l;
			o_valid_r <= 1'b1;
		end
		else if(bottomToPe & leftToPe)
		begin
			o_data_r  <= i_data_l;
			o_valid_r <= 1'b1;
		end
		else
			o_valid_r <= 1'b0;
	end
	else if(leftToPe & bottomToPe)
	begin
		o_data_r  <= i_data_l;
		o_valid_r <= 1'b1;
	end
	else if(leftToPe & peTope)
	begin
		o_data_r <= i_data_l;
		o_valid_r <= 1'b1;
	end
	else if(leftToRight)
	begin
		o_data_r  <= i_data_l;
		o_valid_r <= 1'b1;
	end
	else if(peToRight)
	begin
		o_data_r <=i_data_pe;
		o_valid_r <=1'b1;
	end
	else
	begin
		o_valid_r <=1'b0;
	end
end

always @(posedge clk)
begin
	if(!rstn)
		o_valid_t <= 1'b0;
		
	else if(bottomToRight) 
	begin
		if(leftToRight|leftToTop)
		begin
			o_data_t <= i_data_l;
			o_valid_t <= 1'b1;
		end
		else if(peToRight|peToTop) //This and prev case mutually exclusive
		begin
			o_data_t <= i_data_pe;
			o_valid_t <= 1'b1;
		end
		else if(leftToPe & peTope)
		begin
			o_data_t <= i_data_l;
			o_valid_t <= 1'b1;
		end
		else
			o_valid_t <= 1'b0;
	end
	else if(leftToTop)
	begin
		o_data_t <= i_data_l;
		o_valid_t <= 1'b1;
	end
	else if(peToTop)
	begin
		o_data_t  <= i_data_pe;
		o_valid_t <= 1'b1;
	end
	else if(leftToRight)
	begin
		if(bottomToTop)
		begin
			o_data_t <= i_data_b;
			o_valid_t <= 1'b1;
		end
		else if(peToRight)
		begin
			o_data_t <= i_data_pe;
			o_valid_t <= 1'b1;
		end
		else if(bottomToPe & peTope)
		begin
			o_data_t <= i_data_b;
			o_valid_t <= 1'b1;
		end
		else
			o_valid_t <= 1'b0;
	end
	else if(leftToPe & bottomToPe)//check
	begin
		if(peToRight|peToTop)
		begin
			o_data_t <= i_data_pe;
			o_valid_t <= 1'b1;
		end
		else if(peTope)
		begin
			o_data_t <= i_data_b;
			o_valid_t <= 1'b1;
		end
		else
			o_valid_t <= 1'b0;
	end
	else if(bottomToPe & peTope)
	begin
		o_data_t <= i_data_b;
		o_valid_t <= 1'b1;
	end
	else if(bottomToTop)
	begin
		o_data_t <=i_data_b;
		o_valid_t <=1'b1;
	end
	else if(peToTop)
	begin
		o_data_t <= i_data_pe;
		o_valid_t <= 1'b1;
	end
	else
		o_valid_t <= 1'b0;
end

always @(posedge clk)
begin
	if(!rstn)
		o_valid_pe <= 1'b0; 
		
	else if(peTope)
	begin
		o_data_pe <= i_data_pe;
		o_valid_pe <=1'b1;
	end
	else if(bottomToPe)
	begin
		o_data_pe  <= i_data_b;
		o_valid_pe <= 1'b1;
	end
	else if(leftToPe)
	begin
		o_data_pe <= i_data_l;
		o_valid_pe <= 1'b1;
	end
	else
		o_valid_pe <=1'b0;
end


endmodule
