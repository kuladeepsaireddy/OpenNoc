`define X 4
`define Y 4
`define x_size $clog2(`X)
`define y_size $clog2(`Y)
`define sw_no 512//maximum packet number
`define pck_num 10
`define data_width 256
`define iter `data_width/8
`define total_width (`x_size+`y_size+`data_width)