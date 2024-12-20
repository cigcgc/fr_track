`timescale 1ns / 1ps
module adc_ads804e(
	input clk,
	input rst,
	
	input [11:0] ad_in,
	
	output ad_clk,
	output reg [11:0] ad_out,
    output reg [31:0] sample_time
);

assign ad_clk = ~clk;
reg [31:0] clk_counter; // 时钟计数器
initial begin
clk_counter <= 0;
end

always @(posedge clk)begin
		//ad_out <= ad_in; 
         clk_counter <= clk_counter + 1;
        ad_out <= ad_in;
        sample_time <= clk_counter;
end
endmodule