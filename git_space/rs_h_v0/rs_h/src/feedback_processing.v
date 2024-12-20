module feedback_processing(
	input clk,
    input rst,
    input [11:0] adc_in_v,
	input [15:0] frequency_v,
    input [11:0] min_v,
    input signed[15:0] phase_diff,
    output [15:0] E,
    output [15:0] EC
   
   // output reg select_input
);

	reg signed [15:0] previous_adc_in_v;   // 存储上一时刻的电流值
    reg [15:0] previous_frequency_v;	//存储上一时刻的电流频率
	
	//parameter signed [15:0] I_min = -1228; // 最小电流设置为-1228
	
	
	
	// 计算E和EC
    assign E = adc_in_v;
 /*    assign EC = (previous_frequency_v != 0) ? 
                ((adc_in_v - previous_adc_in_v) * 1) / 
                (frequency_v - previous_frequency_v) : 0; */
	assign EC = phase_diff;
	
	
	
endmodule
