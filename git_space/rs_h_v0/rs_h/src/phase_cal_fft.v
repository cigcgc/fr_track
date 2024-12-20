module Phase_cal_fft (
    input wire clk,       // 1 MHz 时钟信号
    input wire rst,          // 复位信号（低电平有效）
    input wire max_done_v, 
    input wire max_done_i, 
    input [16:0] theta_o_v,
    input [16:0] theta_o_i,
    
    output reg signed [16:0] phase_diff, // 相位差输出
    output reg phase_diff_done      // FFT 完成标志位
);
reg phase_flag_fft;

always @(posedge clk or negedge rst) begin
        if (!rst) begin
            // 复位信号有效时，将标志位和相位差清零
            phase_diff <= 0;
            phase_diff_done<= 0;
            
        end else begin
				
                  
                    // 计算相位差
                    phase_diff <= (theta_o_v - theta_o_i);
                    phase_diff_done <= 1;
                
        end
       
 end


endmodule
