//Copyright (C)2014-2024 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.10 (64-bit)
//Part Number: GW2A-LV18EQ144C8/I7
//Device: GW2A-18
//Device Version: C
//Created Time: Tue Aug 20 17:01:45 2024

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    Gowin_rROM your_instance_name(
        .dout(dout), //output [15:0] dout
        .clk(clk), //input clk
        .oce(oce), //input oce
        .ce(ce), //input ce
        .reset(reset), //input reset
        .ad(ad) //input [8:0] ad
    );

//--------Copy end-------------------
