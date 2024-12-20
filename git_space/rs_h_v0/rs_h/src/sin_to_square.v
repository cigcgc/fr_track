
module  sin_to_square(
    input wire clk,                // 系统时钟
    input wire rst,                // 复位信号
    input wire signed [28:0] adc_in, // 输入的正弦波信号
    output reg square_wave          // 输出方波信号
);

    // 参数定义
    parameter WINDOW_SIZE = 1024;  // 滑动窗口大小

    // 采样点存储
    reg signed [28:0] sample_m1, sample_0, sample_1, sample_2;

    // 滑动窗口均值估计
    reg [31:0] sample_sum;          // 样本累加和
    reg [9:0] sample_counter;       // 样本计数器
    reg signed [28:0] signal_mean;  // 动态估计的信号偏移值

    // 定义32位计数器，防止溢出
    reg [31:0] current_time;          // 当前时间计数器
    reg [31:0] last_zero_cross_time;  // 上一个过零点时间
    reg [31:0] zero_cross_interval;   // 过零点之间的时间间隔

    // 三次插值多项式系数
    reg signed [31:0] a0, a1, a2, a3;

    // 滑动平均滤波器计算偏移值
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            sample_sum <= 0;
            sample_counter <= 0;
            signal_mean <= 0;
        end else begin
            // 更新滑动窗口的累加和
            sample_sum <= sample_sum + adc_in;
            sample_counter <= sample_counter + 1;

            // 当样本数达到窗口大小时，计算信号均值
            if (sample_counter == WINDOW_SIZE) begin
                signal_mean <= sample_sum / WINDOW_SIZE;
                sample_sum <= 0;
                sample_counter <= 0;
            end
        end
    end

    // 定义计数器更新和过零点检测逻辑
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            sample_m1 <= 0;
            sample_0 <= 0;
            sample_1 <= 0;
            sample_2 <= 0;
            current_time <= 0;
            last_zero_cross_time <= 0;
            square_wave <= 0;
        end else begin
            // 滑动窗口更新采样点
            sample_m1 <= sample_0;
            sample_0 <= sample_1;
            sample_1 <= sample_2;
            sample_2 <= adc_in;

            // 当前时间计数器加1
            current_time <= current_time + 1;

            // 检测过零点，基于动态估计的偏移值
            if ((sample_0 > signal_mean && sample_1 <= signal_mean) || 
                (sample_0 < signal_mean && sample_1 >= signal_mean)) begin
                // 插值三次多项式计算
                a0 <= sample_0;
                a1 <= (sample_1 - sample_m1) >> 1;
                a2 <= (sample_2 - sample_0) - a1;
                a3 <= ((sample_2 - sample_1) - (sample_0 - sample_m1)) >> 1;

                // 计算过零点时间差
                if (current_time >= last_zero_cross_time) begin
                    zero_cross_interval <= current_time - last_zero_cross_time;
                end else begin
                    zero_cross_interval <= (32'hFFFFFFFF - last_zero_cross_time) + current_time + 1;
                end
                
                // 更新上次过零点时间
                last_zero_cross_time <= current_time;

                // 只在上升过零点时切换方波信号
                if (sample_0 < signal_mean && sample_1 >= signal_mean) begin
                    // 检测到上升过零点，从低电平切换到高电平
                    square_wave <= ~square_wave;
                end

            end
        end
    end
endmodule
