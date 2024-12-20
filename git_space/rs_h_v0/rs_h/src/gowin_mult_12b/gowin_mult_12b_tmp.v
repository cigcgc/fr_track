//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: V1.9.8.10
//Part Number: GW2A-LV18EQ144C8/I7
//Device: GW2A-18
//Device Version: C
//Created Time: Sat May 11 16:49:56 2024

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    Gowin_MULT_12b your_instance_name(
        .dout(dout_o), //output [23:0] dout
        .a(a_i), //input [11:0] a
        .b(b_i), //input [11:0] b
        .ce(ce_i), //input ce
        .clk(clk_i), //input clk
        .reset(reset_i) //input reset
    );

//--------Copy end-------------------
