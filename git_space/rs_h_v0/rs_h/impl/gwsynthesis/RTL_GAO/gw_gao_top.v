module gw_gao(
    flag_test,
    \sine_o[11] ,
    \sine_o[10] ,
    \sine_o[9] ,
    \sine_o[8] ,
    \sine_o[7] ,
    \sine_o[6] ,
    \sine_o[5] ,
    \sine_o[4] ,
    \sine_o[3] ,
    \sine_o[2] ,
    \sine_o[1] ,
    \sine_o[0] ,
    clk_1M,
    tms_pad_i,
    tck_pad_i,
    tdi_pad_i,
    tdo_pad_o
);

input flag_test;
input \sine_o[11] ;
input \sine_o[10] ;
input \sine_o[9] ;
input \sine_o[8] ;
input \sine_o[7] ;
input \sine_o[6] ;
input \sine_o[5] ;
input \sine_o[4] ;
input \sine_o[3] ;
input \sine_o[2] ;
input \sine_o[1] ;
input \sine_o[0] ;
input clk_1M;
input tms_pad_i;
input tck_pad_i;
input tdi_pad_i;
output tdo_pad_o;

wire flag_test;
wire \sine_o[11] ;
wire \sine_o[10] ;
wire \sine_o[9] ;
wire \sine_o[8] ;
wire \sine_o[7] ;
wire \sine_o[6] ;
wire \sine_o[5] ;
wire \sine_o[4] ;
wire \sine_o[3] ;
wire \sine_o[2] ;
wire \sine_o[1] ;
wire \sine_o[0] ;
wire clk_1M;
wire tms_pad_i;
wire tck_pad_i;
wire tdi_pad_i;
wire tdo_pad_o;
wire tms_i_c;
wire tck_i_c;
wire tdi_i_c;
wire tdo_o_c;
wire [9:0] control0;
wire gao_jtag_tck;
wire gao_jtag_reset;
wire run_test_idle_er1;
wire run_test_idle_er2;
wire shift_dr_capture_dr;
wire update_dr;
wire pause_dr;
wire enable_er1;
wire enable_er2;
wire gao_jtag_tdi;
wire tdo_er1;

IBUF tms_ibuf (
    .I(tms_pad_i),
    .O(tms_i_c)
);

IBUF tck_ibuf (
    .I(tck_pad_i),
    .O(tck_i_c)
);

IBUF tdi_ibuf (
    .I(tdi_pad_i),
    .O(tdi_i_c)
);

OBUF tdo_obuf (
    .I(tdo_o_c),
    .O(tdo_pad_o)
);

GW_JTAG  u_gw_jtag(
    .tms_pad_i(tms_i_c),
    .tck_pad_i(tck_i_c),
    .tdi_pad_i(tdi_i_c),
    .tdo_pad_o(tdo_o_c),
    .tck_o(gao_jtag_tck),
    .test_logic_reset_o(gao_jtag_reset),
    .run_test_idle_er1_o(run_test_idle_er1),
    .run_test_idle_er2_o(run_test_idle_er2),
    .shift_dr_capture_dr_o(shift_dr_capture_dr),
    .update_dr_o(update_dr),
    .pause_dr_o(pause_dr),
    .enable_er1_o(enable_er1),
    .enable_er2_o(enable_er2),
    .tdi_o(gao_jtag_tdi),
    .tdo_er1_i(tdo_er1),
    .tdo_er2_i(1'b0)
);

gw_con_top  u_icon_top(
    .tck_i(gao_jtag_tck),
    .tdi_i(gao_jtag_tdi),
    .tdo_o(tdo_er1),
    .rst_i(gao_jtag_reset),
    .control0(control0[9:0]),
    .enable_i(enable_er1),
    .shift_dr_capture_dr_i(shift_dr_capture_dr),
    .update_dr_i(update_dr)
);

ao_top_0  u_la0_top(
    .control(control0[9:0]),
    .trig0_i(flag_test),
    .data_i({flag_test,\sine_o[11] ,\sine_o[10] ,\sine_o[9] ,\sine_o[8] ,\sine_o[7] ,\sine_o[6] ,\sine_o[5] ,\sine_o[4] ,\sine_o[3] ,\sine_o[2] ,\sine_o[1] ,\sine_o[0] }),
    .clk_i(clk_1M)
);

endmodule
