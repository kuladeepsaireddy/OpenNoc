`define X 4
`define Y 4
`define data_width 256
`define total_width `x_size+`y_size+`pck_num+`data_width
`define sw_no `X*`Y  //number of swithces 
`define x_size $clog2(`X)
`define y_size $clog2(`Y)
`define pck_num $clog2(`sw_no)
`define iter `data_width/8