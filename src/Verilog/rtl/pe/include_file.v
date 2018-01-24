`define X 2
`define Y 1
`define x_size $clog2(`X)
`define y_size 1//$clog2(`Y)
`define sw_no 256//`X*`Y  //number of swithces 
`define pck_num 8
`define data_width 256
`define iter `data_width/8
`define total_width (`x_size+`y_size+`data_width)