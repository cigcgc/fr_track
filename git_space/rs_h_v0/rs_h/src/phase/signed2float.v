
//`timescale 1 ps / 1 ps
/*
module  signed2float_altbarrel_shift_gof
	( 
	aclr,
	clk_en,
	clock,
	data,
	distance,
	result) ;
	input   aclr;
	input   clk_en;
	input   clock;
	input   [15:0]  data;
	input   [3:0]  distance;
	output   [15:0]  result;

	tri0   aclr;
	tri1   clk_en;
	tri0   clock;


	reg	[1:0]	dir_pipe;
	reg	[15:0]	sbit_piper1d;
	reg	[15:0]	sbit_piper2d;
	reg	sel_pipec2r1d;
	reg	sel_pipec3r1d;
	wire  [4:0]  dir_w;
	wire  direction_w;
	wire  [7:0]  pad_w;
	wire  [79:0]  sbit_w;
	wire  [3:0]  sel_w;
	wire  [63:0]  smux_w;

	// synopsys translate_off
	initial
		dir_pipe = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr)
		if (aclr == 1'b1) dir_pipe <= 2'b0;
		else if  (clk_en == 1'b1)   dir_pipe <= {dir_w[3], dir_w[1]};
	// synopsys translate_off
	initial
		sbit_piper1d = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr)
		if (aclr == 1'b1) sbit_piper1d <= 16'b0;
		else if  (clk_en == 1'b1)   sbit_piper1d <= smux_w[31:16];
	// synopsys translate_off
	initial
		sbit_piper2d = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr)
		if (aclr == 1'b1) sbit_piper2d <= 16'b0;
		else if  (clk_en == 1'b1)   sbit_piper2d <= smux_w[63:48];
	// synopsys translate_off
	initial
		sel_pipec2r1d = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr)
		if (aclr == 1'b1) sel_pipec2r1d <= 1'b0;
		else if  (clk_en == 1'b1)   sel_pipec2r1d <= distance[2];
	// synopsys translate_off
	initial
		sel_pipec3r1d = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr)
		if (aclr == 1'b1) sel_pipec3r1d <= 1'b0;
		else if  (clk_en == 1'b1)   sel_pipec3r1d <= distance[3];
	assign
		dir_w = {dir_pipe[1], dir_w[2], dir_pipe[0], dir_w[0], direction_w},
		direction_w = 1'b0,
		pad_w = {8{1'b0}},
		result = sbit_w[79:64],
		sbit_w = {sbit_piper2d, smux_w[47:32], sbit_piper1d, smux_w[15:0], data},
		sel_w = {sel_pipec3r1d, sel_pipec2r1d, distance[1:0]},
		smux_w = {((({16{(sel_w[3] & (~ dir_w[3]))}} & {sbit_w[55:48], pad_w[7:0]}) | ({16{(sel_w[3] & dir_w[3])}} & {pad_w[7:0], sbit_w[63:56]})) | ({16{(~ sel_w[3])}} & sbit_w[63:48])), ((({16{(sel_w[2] & (~ dir_w[2]))}} & {sbit_w[43:32], pad_w[3:0]}) | ({16{(sel_w[2] & dir_w[2])}} & {pad_w[3:0], sbit_w[47:36]})) | ({16{(~ sel_w[2])}} & sbit_w[47:32])), ((({16{(sel_w[1] & (~ dir_w[1]))}} & {sbit_w[29:16], pad_w[1:0]}) | ({16{(sel_w[1] & dir_w[1])}} & {pad_w[1:0], sbit_w[31:18]})) | ({16{(~ sel_w[1])}} & sbit_w[31:16])), ((({16{(sel_w[0] & (~ dir_w[0]))}} & {sbit_w[14:0], pad_w[0]}) | ({16{(sel_w[0] & dir_w[0])}} & {pad_w[0], sbit_w[15:1]})) | ({16{(~ sel_w[0])}} & sbit_w[15:0]))};
endmodule //signed2float_altbarrel_shift_gof



module  signed2float_altpriority_encoder_3v7
	( 
	data,
	q) ;
	input   [1:0]  data;
	output   [0:0]  q;


	assign
		q = {data[1]};
endmodule 
module  signed2float_altpriority_encoder_3e8
	( 
	data,
	q,
	zero) ;
	input   [1:0]  data;
	output   [0:0]  q;
	output   zero;


	assign
		q = {data[1]},
		zero = (~ (data[0] | data[1]));
endmodule //signed2float_altpriority_encoder_3e8


module  signed2float_altpriority_encoder_6v7
	( 
	data,
	q) ;
	input   [3:0]  data;
	output   [1:0]  q;

	wire  [0:0]   wire_altpriority_encoder10_q;
	wire  [0:0]   wire_altpriority_encoder11_q;
	wire  wire_altpriority_encoder11_zero;

	signed2float_altpriority_encoder_3v7   altpriority_encoder10
	( 
	.data(data[1:0]),
	.q(wire_altpriority_encoder10_q));
	signed2float_altpriority_encoder_3e8   altpriority_encoder11
	( 
	.data(data[3:2]),
	.q(wire_altpriority_encoder11_q),
	.zero(wire_altpriority_encoder11_zero));
	assign
		q = {(~ wire_altpriority_encoder11_zero), ((wire_altpriority_encoder11_zero & wire_altpriority_encoder10_q) | ((~ wire_altpriority_encoder11_zero) & wire_altpriority_encoder11_q))};
endmodule 
module  signed2float_altpriority_encoder_6e8
	( 
	data,
	q,
	zero) ;
	input   [3:0]  data;
	output   [1:0]  q;
	output   zero;

	wire  [0:0]   wire_altpriority_encoder12_q;
	wire  wire_altpriority_encoder12_zero;
	wire  [0:0]   wire_altpriority_encoder13_q;
	wire  wire_altpriority_encoder13_zero;

	signed2float_altpriority_encoder_3e8   altpriority_encoder12
	( 
	.data(data[1:0]),
	.q(wire_altpriority_encoder12_q),
	.zero(wire_altpriority_encoder12_zero));
	signed2float_altpriority_encoder_3e8   altpriority_encoder13
	( 
	.data(data[3:2]),
	.q(wire_altpriority_encoder13_q),
	.zero(wire_altpriority_encoder13_zero));
	assign
		q = {(~ wire_altpriority_encoder13_zero), ((wire_altpriority_encoder13_zero & wire_altpriority_encoder12_q) | ((~ wire_altpriority_encoder13_zero) & wire_altpriority_encoder13_q))},
		zero = (wire_altpriority_encoder12_zero & wire_altpriority_encoder13_zero);
endmodule //signed2float_altpriority_encoder_6e8


module  signed2float_altpriority_encoder_bv7
	( 
	data,
	q) ;
	input   [7:0]  data;
	output   [2:0]  q;

	wire  [1:0]   wire_altpriority_encoder8_q;
	wire  [1:0]   wire_altpriority_encoder9_q;
	wire  wire_altpriority_encoder9_zero;

	signed2float_altpriority_encoder_6v7   altpriority_encoder8
	( 
	.data(data[3:0]),
	.q(wire_altpriority_encoder8_q));
	signed2float_altpriority_encoder_6e8   altpriority_encoder9
	( 
	.data(data[7:4]),
	.q(wire_altpriority_encoder9_q),
	.zero(wire_altpriority_encoder9_zero));
	assign
		q = {(~ wire_altpriority_encoder9_zero), (({2{wire_altpriority_encoder9_zero}} & wire_altpriority_encoder8_q) | ({2{(~ wire_altpriority_encoder9_zero)}} & wire_altpriority_encoder9_q))};
endmodule //signed2float_altpriority_encoder_bv7



module  signed2float_altpriority_encoder_be8
	( 
	data,
	q,
	zero) ;
	input   [7:0]  data;
	output   [2:0]  q;
	output   zero;

	wire  [1:0]   wire_altpriority_encoder14_q;
	wire  wire_altpriority_encoder14_zero;
	wire  [1:0]   wire_altpriority_encoder15_q;
	wire  wire_altpriority_encoder15_zero;

	signed2float_altpriority_encoder_6e8   altpriority_encoder14
	( 
	.data(data[3:0]),
	.q(wire_altpriority_encoder14_q),
	.zero(wire_altpriority_encoder14_zero));
	signed2float_altpriority_encoder_6e8   altpriority_encoder15
	( 
	.data(data[7:4]),
	.q(wire_altpriority_encoder15_q),
	.zero(wire_altpriority_encoder15_zero));
	assign
		q = {(~ wire_altpriority_encoder15_zero), (({2{wire_altpriority_encoder15_zero}} & wire_altpriority_encoder14_q) | ({2{(~ wire_altpriority_encoder15_zero)}} & wire_altpriority_encoder15_q))},
		zero = (wire_altpriority_encoder14_zero & wire_altpriority_encoder15_zero);
endmodule //signed2float_altpriority_encoder_be8


module  signed2float_altpriority_encoder_rb6
	( 
	data,
	q) ;
	input   [15:0]  data;
	output   [3:0]  q;

	wire  [2:0]   wire_altpriority_encoder6_q;
	wire  [2:0]   wire_altpriority_encoder7_q;
	wire  wire_altpriority_encoder7_zero;

	signed2float_altpriority_encoder_bv7   altpriority_encoder6
	( 
	.data(data[7:0]),
	.q(wire_altpriority_encoder6_q));
	signed2float_altpriority_encoder_be8   altpriority_encoder7
	( 
	.data(data[15:8]),
	.q(wire_altpriority_encoder7_q),
	.zero(wire_altpriority_encoder7_zero));
	assign
		q = {(~ wire_altpriority_encoder7_zero), (({3{wire_altpriority_encoder7_zero}} & wire_altpriority_encoder6_q) | ({3{(~ wire_altpriority_encoder7_zero)}} & wire_altpriority_encoder7_q))};
endmodule //signed2float_altpriority_encoder_rb6


module  signed2float_altfp_convert_psn
	( 
	aclr,
	clk_en,
	clock,
	dataa,
	result) ;
	input   aclr;
	input   clk_en;
	input   clock;
	input   [15:0]  dataa;
	output   [31:0]  result;

	tri0   aclr;
	tri1   clk_en;


	wire  [15:0]   wire_altbarrel_shift5_result;
	wire  [3:0]   wire_altpriority_encoder2_q;
	reg	[7:0]	exponent_bus_pre_reg;
	reg	[7:0]	exponent_bus_pre_reg2;
	reg	[7:0]	exponent_bus_pre_reg3;
	reg	[14:0]	mag_int_a_reg;
	reg	[14:0]	mag_int_a_reg2;
	reg	[23:0]	mantissa_pre_round_reg;
	reg	[3:0]	priority_encoder_reg;
	reg	[31:0]	result_reg;
	reg	sign_int_a_reg1;
	reg	sign_int_a_reg2;
	reg	sign_int_a_reg3;
	reg	sign_int_a_reg4;
	reg	sign_int_a_reg5;
	wire  [14:0]   wire_add_sub1_result;
	wire  [7:0]   wire_add_sub3_result;
	wire  wire_cmpr4_alb;
	wire  [7:0]  bias_value_w;
	wire  [7:0]  const_bias_value_add_width_int_w;
	wire  [7:0]  exceptions_value;
	wire  [7:0]  exponent_bus;
	wire  [7:0]  exponent_bus_pre;
	wire  [7:0]  exponent_output_w;
	wire  [7:0]  exponent_rounded;
	wire  [7:0]  exponent_zero_w;
	wire  [14:0]  int_a;
	wire  [14:0]  int_a_2s;
	wire  [14:0]  invert_int_a;
	wire  [3:0]  leading_zeroes;
	wire  [14:0]  mag_int_a;
	wire  [22:0]  mantissa_bus;
	wire  [23:0]  mantissa_pre_round;
	wire  [23:0]  mantissa_rounded;
	wire  max_neg_value_selector;
	wire  [7:0]  max_neg_value_w;
	wire  [7:0]  minus_leading_zero;
	wire  [15:0]  prio_mag_int_a;
	wire  [31:0]  result_w;
	wire  [14:0]  shifted_mag_int_a;
	wire  sign_bus;
	wire  sign_int_a;
	wire  [3:0]  zero_padding_w;

	signed2float_altbarrel_shift_gof   altbarrel_shift5
	( 
	.aclr(aclr),
	.clk_en(clk_en),
	.clock(clock),
	.data({1'b0, mag_int_a_reg2}),
	.distance(leading_zeroes),
	.result(wire_altbarrel_shift5_result));
	signed2float_altpriority_encoder_rb6   altpriority_encoder2
	( 
	.data(prio_mag_int_a),
	.q(wire_altpriority_encoder2_q));
	// synopsys translate_off
	initial
		exponent_bus_pre_reg = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr)
		if (aclr == 1'b1) exponent_bus_pre_reg <= 8'b0;
		else if  (clk_en == 1'b1)   exponent_bus_pre_reg <= exponent_bus_pre_reg2;
	// synopsys translate_off
	initial
		exponent_bus_pre_reg2 = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr)
		if (aclr == 1'b1) exponent_bus_pre_reg2 <= 8'b0;
		else if  (clk_en == 1'b1)   exponent_bus_pre_reg2 <= exponent_bus_pre_reg3;
	// synopsys translate_off
	initial
		exponent_bus_pre_reg3 = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr)
		if (aclr == 1'b1) exponent_bus_pre_reg3 <= 8'b0;
		else if  (clk_en == 1'b1)   exponent_bus_pre_reg3 <= exponent_bus_pre;
	// synopsys translate_off
	initial
		mag_int_a_reg = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr)
		if (aclr == 1'b1) mag_int_a_reg <= 15'b0;
		else if  (clk_en == 1'b1)   mag_int_a_reg <= mag_int_a;
	// synopsys translate_off
	initial
		mag_int_a_reg2 = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr)
		if (aclr == 1'b1) mag_int_a_reg2 <= 15'b0;
		else if  (clk_en == 1'b1)   mag_int_a_reg2 <= mag_int_a_reg;
	// synopsys translate_off
	initial
		mantissa_pre_round_reg = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr)
		if (aclr == 1'b1) mantissa_pre_round_reg <= 24'b0;
		else if  (clk_en == 1'b1)   mantissa_pre_round_reg <= mantissa_pre_round;
	// synopsys translate_off
	initial
		priority_encoder_reg = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr)
		if (aclr == 1'b1) priority_encoder_reg <= 4'b0;
		else if  (clk_en == 1'b1)   priority_encoder_reg <= wire_altpriority_encoder2_q;
	// synopsys translate_off
	initial
		result_reg = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr)
		if (aclr == 1'b1) result_reg <= 32'b0;
		else if  (clk_en == 1'b1)   result_reg <= result_w;
	// synopsys translate_off
	initial
		sign_int_a_reg1 = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr)
		if (aclr == 1'b1) sign_int_a_reg1 <= 1'b0;
		else if  (clk_en == 1'b1)   sign_int_a_reg1 <= sign_int_a;
	// synopsys translate_off
	initial
		sign_int_a_reg2 = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr)
		if (aclr == 1'b1) sign_int_a_reg2 <= 1'b0;
		else if  (clk_en == 1'b1)   sign_int_a_reg2 <= sign_int_a_reg1;
	// synopsys translate_off
	initial
		sign_int_a_reg3 = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr)
		if (aclr == 1'b1) sign_int_a_reg3 <= 1'b0;
		else if  (clk_en == 1'b1)   sign_int_a_reg3 <= sign_int_a_reg2;
	// synopsys translate_off
	initial
		sign_int_a_reg4 = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr)
		if (aclr == 1'b1) sign_int_a_reg4 <= 1'b0;
		else if  (clk_en == 1'b1)   sign_int_a_reg4 <= sign_int_a_reg3;
	// synopsys translate_off
	initial
		sign_int_a_reg5 = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr)
		if (aclr == 1'b1) sign_int_a_reg5 <= 1'b0;
		else if  (clk_en == 1'b1)   sign_int_a_reg5 <= sign_int_a_reg4;
	lpm_add_sub   add_sub1
	( 
	.cout(),
	.dataa(invert_int_a),
	.datab(15'b000000000000001),
	.overflow(),
	.result(wire_add_sub1_result)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.aclr(1'b0),
	.add_sub(1'b1),
	.cin(),
	.clken(1'b1),
	.clock(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
	defparam
		add_sub1.lpm_direction = "ADD",
		add_sub1.lpm_width = 15,
		add_sub1.lpm_type = "lpm_add_sub",
		add_sub1.lpm_hint = "ONE_INPUT_IS_CONSTANT=YES";
	lpm_add_sub   add_sub3
	( 
	.cout(),
	.dataa(const_bias_value_add_width_int_w),
	.datab(minus_leading_zero),
	.overflow(),
	.result(wire_add_sub3_result)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.aclr(1'b0),
	.add_sub(1'b1),
	.cin(),
	.clken(1'b1),
	.clock(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
	defparam
		add_sub3.lpm_direction = "SUB",
		add_sub3.lpm_width = 8,
		add_sub3.lpm_type = "lpm_add_sub",
		add_sub3.lpm_hint = "ONE_INPUT_IS_CONSTANT=YES";
	lpm_compare   cmpr4
	( 
	.aeb(),
	.agb(),
	.ageb(),
	.alb(wire_cmpr4_alb),
	.aleb(),
	.aneb(),
	.dataa(exponent_output_w),
	.datab(bias_value_w)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.aclr(1'b0),
	.clken(1'b1),
	.clock(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
	defparam
		cmpr4.lpm_representation = "UNSIGNED",
		cmpr4.lpm_width = 8,
		cmpr4.lpm_type = "lpm_compare";
	assign
		bias_value_w = 8'b01111111,
		const_bias_value_add_width_int_w = 8'b10001101,
		exceptions_value = (({8{(~ max_neg_value_selector)}} & exponent_zero_w) | ({8{max_neg_value_selector}} & max_neg_value_w)),
		exponent_bus = exponent_rounded,
		exponent_bus_pre = (({8{(~ wire_cmpr4_alb)}} & exponent_output_w) | ({8{wire_cmpr4_alb}} & exceptions_value)),
		exponent_output_w = wire_add_sub3_result,
		exponent_rounded = exponent_bus_pre_reg,
		exponent_zero_w = {8{1'b0}},
		int_a = dataa[14:0],
		int_a_2s = wire_add_sub1_result,
		invert_int_a = (~ int_a),
		leading_zeroes = (~ priority_encoder_reg),
		mag_int_a = (({15{(~ sign_int_a)}} & int_a) | ({15{sign_int_a}} & int_a_2s)),
		mantissa_bus = mantissa_rounded[22:0],
		mantissa_pre_round = {shifted_mag_int_a[14:0], {9{1'b0}}},
		mantissa_rounded = mantissa_pre_round_reg,
		max_neg_value_selector = (wire_cmpr4_alb & sign_int_a_reg2),
		max_neg_value_w = 8'b10001110,
		minus_leading_zero = {zero_padding_w, leading_zeroes},
		prio_mag_int_a = {mag_int_a_reg, 1'b1},
		result = result_reg,
		result_w = {sign_bus, exponent_bus, mantissa_bus},
		shifted_mag_int_a = wire_altbarrel_shift5_result[14:0],
		sign_bus = sign_int_a_reg5,
		sign_int_a = dataa[15],
		zero_padding_w = {4{1'b0}};
endmodule //signed2float_altfp_convert_psn
//VALID FILE



module signed2float (
	aclr,
	clk_en,
	clock,
	dataa,
	result);

	input	  aclr;
	input	  clk_en;
	input	  clock;
	input	[15:0]  dataa;
	output	[31:0]  result;

	wire [31:0] sub_wire0;
	wire [31:0] result = sub_wire0[31:0];

	signed2float_altfp_convert_psn	signed2float_altfp_convert_psn_component (
				.aclr (aclr),
				.clk_en (clk_en),
				.clock (clock),
				.dataa (dataa),
				.result (sub_wire0));

endmodule

*/