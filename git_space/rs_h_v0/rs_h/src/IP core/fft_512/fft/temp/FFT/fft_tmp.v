//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: GowinSynthesis V1.9.8.10
//Part Number: GW2A-LV18EQ144C8/I7
//Device: GW2A-18
//Device Version: C
//Created Time: Thu Sep 05 10:05:31 2024

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	FFT_Top_512 your_instance_name(
		.idx(idx_o), //output [8:0] idx
		.xk_re(xk_re_o), //output [15:0] xk_re
		.xk_im(xk_im_o), //output [15:0] xk_im
		.sod(sod_o), //output sod
		.ipd(ipd_o), //output ipd
		.eod(eod_o), //output eod
		.busy(busy_o), //output busy
		.soud(soud_o), //output soud
		.opd(opd_o), //output opd
		.eoud(eoud_o), //output eoud
		.xn_re(xn_re_i), //input [11:0] xn_re
		.xn_im(xn_im_i), //input [11:0] xn_im
		.start(start_i), //input start
		.clk(clk_i), //input clk
		.rst(rst_i) //input rst
	);

//--------Copy end-------------------
