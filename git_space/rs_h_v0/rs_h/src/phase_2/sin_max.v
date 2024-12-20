// 文件名: sine_max_min.v
// 功能: 计算输入正弦波信号在10个周期内的最大值和最小值，并输出其与中点值的差异（有符号输出）

module sine_max_min (
    input wire clk,                            // 时钟信号
    input wire rst,                            // 低电平复位信号
    input wire [11:0] sine_wave,               // 输入正弦波信号，12位无符号整数
    output reg [11:0] min_v,
    output reg [12:0] mid_value,
    output reg signed [12:0] shifted_signal    // 输出信号，输入信号减去中点值后的结果（有符号）
);

    reg [15:0] cycle_counter;                  // 记录周期计数
    reg [11:0] temp_max;                       // 暂时保存每个周期的最大值
    reg [11:0] temp_min;                       // 暂时保存每个周期的最小值
    reg [15:0] sample_counter;                 // 记录每个周期内的采样点数

    reg [17:0] max_sum;                        // 10个周期的最大值之和
    reg [17:0] min_sum;                        // 10个周期的最小值之和
    reg [11:0] max_average;                    // 10个周期的最大值的平均值
    reg [11:0] min_average;                    // 10个周期的最小值的平均值
    //reg [12:0] mid_value;                      // 计算出的中点值

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            temp_max <= 12'd0;
            temp_min <= 12'd4095;              // 无符号数的最小值初始化为最大值，以便正确更新
            cycle_counter <= 16'd0;
            sample_counter <= 16'd0;
            mid_value <= 13'd0;
            max_sum <= 18'd0;
            min_sum <= 18'd0;
            shifted_signal <= 13'd0;
        end else begin
            // 第一个采样点时初始化
            if (sample_counter == 0) begin
                temp_max <= sine_wave;
                temp_min <= sine_wave;
            end

            // 更新每个周期的最大值和最小值
            if (sine_wave > temp_max) begin
                temp_max <= sine_wave;
            end
            if (sine_wave < temp_min) begin
                temp_min <= sine_wave;
            end

            sample_counter <= sample_counter + 1;

            // 假设每周期有1000个采样点，判断是否完成一个周期
            if (sample_counter == 39) begin
                // 累加每个周期的最大值和最小值
                max_sum <= max_sum + temp_max;
                min_sum <= min_sum + temp_min;

                cycle_counter <= cycle_counter + 1;
                sample_counter <= 16'd0;

                // 如果达到10个周期，计算最终的中点值
                if (cycle_counter == 9) begin
                    // 计算10个周期的最大值和最小值的平均值
                    max_average <= max_sum / 10;
                    min_average <= min_sum / 10;
                    min_v <= min_average;
                    // 计算平均值的中点值
                    mid_value <= (max_average + min_average) >>> 1;

                    // 重置所有累加器和计数器
                    max_sum <= 18'd0;
                    min_sum <= 18'd0;
                    cycle_counter <= 16'd0;
                end
            end

            // 计算输入信号减去中点值后的输出信号（有符号）
            shifted_signal <= sine_wave - mid_value;
        end
    end
endmodule
