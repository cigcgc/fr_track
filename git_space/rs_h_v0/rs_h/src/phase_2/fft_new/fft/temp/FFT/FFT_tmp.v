//Copyright (C)2014-2024 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.10 (64-bit)
//Part Number: GW2A-LV18EQ144C8/I7
//Device: GW2A-18
//Device Version: C
//Created Time: Thu Sep 12 14:22:43 2024

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	FFT_Top_new your_instance_name(
		.idx(idx), //output [9:0] idx
		.xk_re(xk_re), //output [26:0] xk_re
		.xk_im(xk_im), //output [26:0] xk_im
		.sod(sod), //output sod
		.ipd(ipd), //output ipd
		.eod(eod), //output eod
		.busy(busy), //output busy
		.soud(soud), //output soud
		.opd(opd), //output opd
		.eoud(eoud), //output eoud
		.xn_re(xn_re), //input [23:0] xn_re
		.xn_im(xn_im), //input [23:0] xn_im
		.start(start), //input start
		.clk(clk), //input clk
		.rst(rst) //input rst
	);

//--------Copy end-------------------
