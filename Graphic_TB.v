`timescale 1ns/1ns

module Graphic_TB;

//module graphic(clock, reset, pos_x, pos_y, o_red, o_blue, o_green);
reg clock; 
reg reset;
wire [3:0] red;
wire [3:0] green;
wire [3:0] blue;
reg pos_x = 0;
reg pos_y = 0;

graphic DUV (clock, reset, pos_x, pos_y, red, blue, green);

always #50 clock = !clock;

endmodule
