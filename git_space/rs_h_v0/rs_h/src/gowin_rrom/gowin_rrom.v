//Copyright (C)2014-2024 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//Tool Version: V1.9.10 (64-bit)
//Part Number: GW2A-LV18EQ144C8/I7
//Device: GW2A-18
//Device Version: C
//Created Time: Tue Aug 20 17:01:45 2024

module Gowin_rROM (dout, clk, oce, ce, reset, ad);

output [15:0] dout;
input clk;
input oce;
input ce;
input reset;
input [8:0] ad;

wire [15:0] rrom_inst_0_dout_w;
wire gw_gnd;

assign gw_gnd = 1'b0;

rROM rrom_inst_0 (
    .DO({rrom_inst_0_dout_w[15:0],dout[15:0]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .BLKSEL({gw_gnd,gw_gnd,gw_gnd}),
    .AD({gw_gnd,ad[8:0],gw_gnd,gw_gnd,gw_gnd,gw_gnd})
);

defparam rrom_inst_0.READ_MODE = 1'b0;
defparam rrom_inst_0.BIT_WIDTH = 16;
defparam rrom_inst_0.BLK_SEL = 3'b000;
defparam rrom_inst_0.RESET_MODE = "SYNC";

endmodule //Gowin_rROM
