//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//GOWIN Version: V1.9.8.10
//Part Number: GW2A-LV18EQ144C8/I7
//Device: GW2A-18
//Device Version: C
//Created Time: Sat May 11 16:49:56 2024

module Gowin_MULT_12b (dout, a, b, ce, clk, reset);

output [23:0] dout;
input [11:0] a;
input [11:0] b;
input ce;
input clk;
input reset;

wire [11:0] dout_w;
wire [17:0] soa_w;
wire [17:0] sob_w;
wire gw_gnd;

assign gw_gnd = 1'b0;

MULT18X18 mult18x18_inst (
    .DOUT({dout_w[11:0],dout[23:0]}),
    .SOA(soa_w),
    .SOB(sob_w),
    .A({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,a[11:0]}),
    .B({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,b[11:0]}),
    .ASIGN(gw_gnd),
    .BSIGN(gw_gnd),
    .SIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
    .SIB({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
    .CE(ce),
    .CLK(clk),
    .RESET(reset),
    .ASEL(gw_gnd),
    .BSEL(gw_gnd)
);

defparam mult18x18_inst.AREG = 1'b1;
defparam mult18x18_inst.BREG = 1'b1;
defparam mult18x18_inst.OUT_REG = 1'b1;
defparam mult18x18_inst.PIPE_REG = 1'b0;
defparam mult18x18_inst.ASIGN_REG = 1'b0;
defparam mult18x18_inst.BSIGN_REG = 1'b0;
defparam mult18x18_inst.SOA_REG = 1'b0;
defparam mult18x18_inst.MULT_RESET_MODE = "SYNC";

endmodule //Gowin_MULT_12b
