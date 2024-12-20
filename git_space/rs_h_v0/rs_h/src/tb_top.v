`timescale 1ns / 1ns

module tb_top;
	reg clk_1M;
	reg clk_2M;
	reg clk_10M;
	reg clk_100M;
	reg rst;
	
	
    reg [31:0] drive_frequency;


wire [26:0] xk_re_v,xk_im_v,xk_re_i,xk_im_i;
wire [26:0] max_re_v; // 电压最大模值的实部
wire [26:0] max_im_v; // 电压最大模值的虚部
wire [9:0] max_idx_v; // 电压最大模值的索引
wire [26:0] max_re_i; // 电流最大模值的实部
wire [26:0] max_im_i; // 电流最大模值的虚部
wire [9:0] max_idx_i;  // 电流最大模值的索引
wire [31:0]  phase_v,phase_i;
wire signed[15:0] phase_fft;

GSR GSR(.GSRI(1'b1));
top insit_top(
	.clk_1M(clk_1M),
	.clk_2M(clk_2M),
	.clk_10M(clk_10M),
	.clk_100M(clk_100M),
	.rst(rst),
	
	
	.drive_frequency(drive_frequency)
	
	
		
);
initial begin
	clk_1M = 0;
	clk_2M = 0;
	clk_10M = 0;
	clk_100M = 0;
	rst = 0;
	
	#145;
	rst = 1;

end

always #500 clk_1M =~clk_1M;
always #250 clk_2M =~clk_2M;
always #50 clk_10M =~clk_10M;
always #5 clk_100M =~clk_100M;
always #500000 stm32_en =~stm32_en;   //每1us使能一次
endmodule
