/* 
 * file			: ADPLL.v
 * author		: 今朝无言
 * lab		    : WHU-EIS-LMSWE
 * date			: 2023-08-03
 * version		: v1.0
 * description	: 锁相环
 * Copyright © 2023 WHU-EIS-LMSWE, All Rights Reserved.
 */


module ADPLL(
input						clk,
input						rst_n,

input		signed	[15:0]	A,		//参考信号
input		signed	[15:0]	B,		//本地信号

output		signed	[15:0]	df		//频偏
);

parameter	CLK_FREQ	= 1_000_000;	//采样频率

reg signed	[15:0]	df	= 16'd0;

//-----------------------multi---------------------------------
reg	signed	[31:0]	multi	= 32'd0;

always @(posedge clk) begin
	if(~rst_n) begin
		multi	<= 32'd0;
	end
	else begin
		multi	<= A*B;
	end
end

//------------------------FIR---------------------------------
wire	signed	[15:0]	multi_filt  [1:3];

localparam	FIR_N = 20;	//FIR阶数

wire	[16*(FIR_N+1)-1:0]	FIR_params;

FIR_params_0d1 FIR_params_inst(
	.params		(FIR_params)
);

wire    clk_10M;
wire    clk_1M;



//低通滤波						多级低通滤波，中间穿插下采样
FIR_filter #(.N(FIR_N + 1))
FIR_filter_inst1(
	.clk			(clk_100M),
	.rst_n			(rst_n),

	.filter_params	(FIR_params),

	.data_in		(multi[31:16]),
	.data_out		(multi_filt[1])
);

//低通滤波
FIR_filter #(.N(FIR_N + 1))
FIR_filter_inst2(
	.clk			(clk_10M),
	.rst_n			(rst_n),

	.filter_params	(FIR_params),

	.data_in		(multi_filt[1]),
	.data_out		(multi_filt[2])
);

//低通滤波
FIR_filter #(.N(FIR_N + 1))
FIR_filter_inst3(
	.clk			(clk_1M),
	.rst_n			(rst_n),

	.filter_params	(FIR_params),

	.data_in		(multi_filt[2]),
	.data_out		(multi_filt[3])
);

//---------------------control---------------------------------
always @(posedge clk_1M) begin
	df	<= multi_filt[3];		//  df=K*multi_filt，此处省略鉴相灵敏度K，外部请自行设置合理的K值s
end

endmodule
