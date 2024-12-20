/* 
 * file         : FIR_filter.v
 * author       : 今朝无言
 * lab		    : WHU-EIS-LMSWE
 * date		    : 2023-07-03
 * version      : v1.0
 * description  : FIR 滤波器
 */
module FIR_filter(
input							clk,
input							rst_n,

input				[16*N-1:0]	filter_params,

input		signed	[15:0]		data_in,
output	reg	signed	[15:0]		data_out
);

parameter	N		= 32;	//滤波器参数个数
parameter	div_N	= 16;	//sum结果除 2^div_N，作为 filter 的输出

//FIR 滤波器参数
reg	signed	[15:0] b[0:N-1];

integer	m;
always @(*) begin
	for(m=0; m<N; m=m+1) begin
		b[m]	<= filter_params[(m << 4) +: 16];
	end
end

reg	signed	[15:0]	shift_reg[0:N-1];

integer	i;
always @(posedge clk) begin
	if(~rst_n) begin
		for(i=N-1; i>=0; i=i-1) begin
			shift_reg[i]	<= 16'd0;
		end
	end
	else begin
		for(i=N-1; i>0; i=i-1) begin
			shift_reg[i]	<= shift_reg[i-1];
		end
		shift_reg[0]		<= data_in;
	end
end

reg		signed	[31:0]	multi[0:N-1];

integer	j;
always @(*) begin
	for(j=0; j<N; j=j+1) begin
		multi[j]	<= shift_reg[j] * b[j];
		//这里可以考虑使用multiplier IP核，使用LUT搭建（而这里直接乘使用的是DSP资源，一般的FPGA芯片只有几百个）
	end
end

reg		signed	[47:0]	sum;

integer	k;
always @(*) begin
	sum		= 0;
	for(k=0; k<N; k=k+1) begin
		sum	= sum + multi[k];
	end
end

always @(posedge clk) begin
	data_out	<= sum[47-div_N : 32-div_N];
end

endmodule
