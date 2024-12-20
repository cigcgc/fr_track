//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: V1.9.8.10
//Part Number: GW2A-LV18EQ144C8/I7
//Device: GW2A-18
//Device Version: C
//Created Time: Wed Aug 16 10:10:20 2023

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    Gowin_rPLL_100M your_instance_name(
        .clkout(clkout_o), //output clkout
        .lock(lock_o), //output lock
        .reset(reset_i), //input reset
        .clkin(clkin_i) //input clkin
    );

//--------Copy end-------------------
