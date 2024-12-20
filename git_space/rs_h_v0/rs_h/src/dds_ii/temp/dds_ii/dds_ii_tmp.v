//Copyright (C)2014-2024 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.10 (64-bit)
//Part Number: GW2A-LV18EQ144C8/I7
//Device: GW2A-18
//Device Version: C
//Created Time: Wed Sep 18 15:29:06 2024

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	DDS_II_Top your_instance_name(
		.clk_i(clk_i), //input clk_i
		.rst_n_i(rst_n_i), //input rst_n_i
		.phase_valid_i(phase_valid_i), //input phase_valid_i
		.phase_inc_i(phase_inc_i), //input [26:0] phase_inc_i
		.phase_off_i(phase_off_i), //input [26:0] phase_off_i
		.phase_out_o(phase_out_o), //output [26:0] phase_out_o
		.sine_o(sine_o), //output [11:0] sine_o
		.data_valid_o(data_valid_o) //output data_valid_o
	);

//--------Copy end-------------------
