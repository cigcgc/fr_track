//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: V1.9.8.10
//Part Number: GW2A-LV18EQ144C8/I7
//Device: GW2A-18
//Device Version: C
//Created Time: Thu Apr 18 14:35:00 2024

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    Gowin_SDPB_4096 your_instance_name(
        .dout(dout_o), //output [15:0] dout
        .clka(clka_i), //input clka
        .cea(cea_i), //input cea
        .reseta(reseta_i), //input reseta
        .clkb(clkb_i), //input clkb
        .ceb(ceb_i), //input ceb
        .resetb(resetb_i), //input resetb
        .oce(oce_i), //input oce
        .ada(ada_i), //input [11:0] ada
        .din(din_i), //input [15:0] din
        .adb(adb_i) //input [11:0] adb
    );

//--------Copy end-------------------
