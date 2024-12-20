//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: GowinSynthesis V1.9.8.10
//Part Number: GW2A-LV18EQ144C8/I7
//Device: GW2A-18
//Device Version: C
//Created Time: Tue Sep 03 11:09:57 2024

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	PID_Controller_3p3z_Top your_instance_name(
		.clk(clk_i), //input clk
		.rstn(rstn_i), //input rstn
		.param_valid_i(param_valid_i_i), //input param_valid_i
		.param_chn_i(param_chn_i_i), //input [0:0] param_chn_i
		.param_a1_i(param_a1_i_i), //input [15:0] param_a1_i
		.param_a2_i(param_a2_i_i), //input [15:0] param_a2_i
		.param_a3_i(param_a3_i_i), //input [15:0] param_a3_i
		.param_b0_i(param_b0_i_i), //input [15:0] param_b0_i
		.param_b1_i(param_b1_i_i), //input [15:0] param_b1_i
		.param_b2_i(param_b2_i_i), //input [15:0] param_b2_i
		.param_max_i(param_max_i_i), //input [15:0] param_max_i
		.param_min_i(param_min_i_i), //input [15:0] param_min_i
		.data_valid_i(data_valid_i_i), //input data_valid_i
		.data_chn_i(data_chn_i_i), //input [0:0] data_chn_i
		.data_fdb_i(data_fdb_i_i), //input [15:0] data_fdb_i
		.data_ref_i(data_ref_i_i), //input [15:0] data_ref_i
		.tready_o(tready_o_o), //output tready_o
		.u_valid_o(u_valid_o_o), //output u_valid_o
		.u_chn_o(u_chn_o_o), //output [0:0] u_chn_o
		.u_data_o(u_data_o_o) //output [15:0] u_data_o
	);

//--------Copy end-------------------
