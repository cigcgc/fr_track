//Copyright (C)2014-2024 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.10 (64-bit)
//Part Number: GW2A-LV18EQ144C8/I7
//Device: GW2A-18
//Device Version: C
//Created Time: Wed Sep 11 17:09:10 2024

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	CORDIC_Top_fft_11 your_instance_name(
		.clk(clk), //input clk
		.rst(rst), //input rst
		.x_i(x_i), //input [19:0] x_i
		.y_i(y_i), //input [19:0] y_i
		.theta_i(theta_i), //input [16:0] theta_i
		.x_o(x_o), //output [19:0] x_o
		.y_o(y_o), //output [19:0] y_o
		.theta_o(theta_o) //output [16:0] theta_o
	);

//--------Copy end-------------------
