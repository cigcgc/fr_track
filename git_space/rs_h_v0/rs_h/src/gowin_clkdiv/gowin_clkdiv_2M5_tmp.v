//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: V1.9.8.10
//Part Number: GW2A-LV18EQ144C8/I7
//Device: GW2A-18
//Device Version: C
//Created Time: Tue Jun 13 15:25:03 2023

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    Gowin_CLKDIV_2M5 your_instance_name(
        .clkout(clkout_o), //output clkout
        .hclkin(hclkin_i), //input hclkin
        .resetn(resetn_i) //input resetn
    );

//--------Copy end-------------------
