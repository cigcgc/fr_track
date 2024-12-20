/* 
 * file			: FIR_params.v
 * author		: 今朝无言
 * lab			: WHU-EIS-LMSWE
 * date			: 2023-08-04
 * version		: v1.0
 * description	: FIR 滤波器    lowpass   N=20   fc=0.1 fs
 */
module FIR_params_0d1(
output	[335:0]	params
);

assign	params[15:0]	= 16'h0000;
assign	params[31:16]	= 16'h0057;
assign	params[47:32]	= 16'h0131;
assign	params[63:48]	= 16'h0302;
assign	params[79:64]	= 16'h0616;
assign	params[95:80]	= 16'h0A6D;
assign	params[111:96]	= 16'h0FA8;
assign	params[127:112]	= 16'h1518;
assign	params[143:128]	= 16'h19E1;
assign	params[159:144]	= 16'h1D28;
assign	params[175:160]	= 16'h1E53;
assign	params[191:176]	= 16'h1D28;
assign	params[207:192]	= 16'h19E1;
assign	params[223:208]	= 16'h1518;
assign	params[239:224]	= 16'h0FA8;
assign	params[255:240]	= 16'h0A6D;
assign	params[271:256]	= 16'h0616;
assign	params[287:272]	= 16'h0302;
assign	params[303:288]	= 16'h0131;
assign	params[319:304]	= 16'h0057;
assign	params[335:320]	= 16'h0000;

endmodule
