`define X 2
`define Y 2
`define x_size 1
`define y_size 1
`define sw_no `X*`Y  //number of swithces 
`define pck_num 4
`define data_width (256-`pck_num)
`define iter `data_width/8
`define total_width (`x_size+`y_size+`pck_num+`data_width)