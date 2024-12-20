
module phase_cal_detector(
  input clk,
  input rst,
  input [11:0] r_adc_data_v,  // 电压信号的实部
  input [11:0] r_adc_data_i,  // 电流信号的实部
  output reg signed [15:0] phase_diff,  // 相位差，16位宽
  output reg m_phase_done
);

    reg xor_output;
    reg signed [31:0] phase_accum;  // 相位差累加器 (带符号)
    reg [11:0] r_adc_data_v_d1, r_adc_data_i_d1; // 延迟信号

    reg [11:0] max_v[2:0], min_v[2:0]; // 三个最大值和三个最小值
    reg [11:0] avg_v;    // 最大值和最小值的平均值
    reg [31:0] max_sum_v, min_sum_v;    // 用于计算平均值的累加器

    reg [11:0] max_i[2:0], min_i[2:0]; // 三个最大值和三个最小值
    reg [11:0] avg_i;    // 最大值和最小值的平均值
    reg [31:0] max_sum_i, min_sum_i;    // 用于计算平均值的累加器

    reg [2:0] count_v; // 计数器，跟踪收集到的最大值和最小值的数量
    reg [2:0] count_i; // 计数器，跟踪收集到的最大值和最小值的数量

    // 更新最大值和最小值
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            max_v[0] <= 12'b0;
            max_v[1] <= 12'b0;
            max_v[2] <= 12'b0;
            min_v[0] <= 12'hFFF;
            min_v[1] <= 12'hFFF;
            min_v[2] <= 12'hFFF;
            count_v <= 3'b0;

            max_i[0] <= 12'b0;
            max_i[1] <= 12'b0;
            max_i[2] <= 12'b0;
            min_i[0] <= 12'hFFF;
            min_i[1] <= 12'hFFF;
            min_i[2] <= 12'hFFF;
            count_i <= 3'b0;
        end else begin
            // 电压信号最大值更新
            if (count_v < 3) begin
                if (r_adc_data_v > max_v[count_v]) begin
                    max_v[count_v] <= r_adc_data_v;
                    count_v <= count_v + 1;
                end
            end else begin
                if (r_adc_data_v > max_v[0]) begin
                    max_v[2] <= max_v[1];
                    max_v[1] <= max_v[0];
                    max_v[0] <= r_adc_data_v;
                end else if (r_adc_data_v > max_v[1]) begin
                    max_v[2] <= max_v[1];
                    max_v[1] <= r_adc_data_v;
                end else if (r_adc_data_v > max_v[2]) begin
                    max_v[2] <= r_adc_data_v;
                end
            end

            // 电压信号最小值更新
            if (count_v < 3) begin
                if (r_adc_data_v < min_v[count_v]) begin
                    min_v[count_v] <= r_adc_data_v;
                    count_v <= count_v + 1;
                end
            end else begin
                if (r_adc_data_v < min_v[0]) begin
                    min_v[2] <= min_v[1];
                    min_v[1] <= min_v[0];
                    min_v[0] <= r_adc_data_v;
                end else if (r_adc_data_v < min_v[1]) begin
                    min_v[2] <= min_v[1];
                    min_v[1] <= r_adc_data_v;
                end else if (r_adc_data_v < min_v[2]) begin
                    min_v[2] <= r_adc_data_v;
                end
            end

            // 电流信号最大值更新
            if (count_i < 3) begin
                if (r_adc_data_i > max_i[count_i]) begin
                    max_i[count_i] <= r_adc_data_i;
                    count_i <= count_i + 1;
                end
            end else begin
                if (r_adc_data_i > max_i[0]) begin
                    max_i[2] <= max_i[1];
                    max_i[1] <= max_i[0];
                    max_i[0] <= r_adc_data_i;
                end else if (r_adc_data_i > max_i[1]) begin
                    max_i[2] <= max_i[1];
                    max_i[1] <= r_adc_data_i;
                end else if (r_adc_data_i > max_i[2]) begin
                    max_i[2] <= r_adc_data_i;
                end
            end

            // 电流信号最小值更新
            if (count_i < 3) begin
                if (r_adc_data_i < min_i[count_i]) begin
                    min_i[count_i] <= r_adc_data_i;
                    count_i <= count_i + 1;
                end
            end else begin
                if (r_adc_data_i < min_i[0]) begin
                    min_i[2] <= min_i[1];
                    min_i[1] <= min_i[0];
                    min_i[0] <= r_adc_data_i;
                end else if (r_adc_data_i < min_i[1]) begin
                    min_i[2] <= min_i[1];
                    min_i[1] <= r_adc_data_i;
                end else if (r_adc_data_i < min_i[2]) begin
                    min_i[2] <= r_adc_data_i;
                end
            end
        end
    end

    // 计算最大值和最小值的平均值
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            
            avg_v <= 12'b0;
            avg_i <= 12'b0;
            
        end else begin
            if (count_v == 3) begin
                avg_v <= (max_v[0] + max_v[1] + max_v[2]+ min_v[0] + min_v[1] + min_v[2])/6;
           
            end

            if (count_i == 3) begin
                avg_i <= (max_i[0] + max_i[1] + max_i[2]+ min_i[0] + min_i[1] + min_i[2])/6;
                
            end
        end
    end

    // 判断上升沿
    wire v_rising_edge = (r_adc_data_v > avg_v);
    wire i_rising_edge = (r_adc_data_i > avg_i);

    // 异或操作作为鉴相器
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            xor_output <= 0;
        end else begin
            xor_output <= v_rising_edge ^ i_rising_edge;
        end
    end

    // 延迟输入信号以检测边沿
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            r_adc_data_v_d1 <= 12'b0;
            r_adc_data_i_d1 <= 12'b0;
        end else begin
            r_adc_data_v_d1 <= r_adc_data_v;
            r_adc_data_i_d1 <= r_adc_data_i;
        end
    end

    // 累加相位差
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            phase_accum <= 0;
        end else if (xor_output) begin
            phase_accum <= phase_accum + (v_rising_edge ? 1 : -1);
        end
    end

    // 将累加器的值映射为相位差
    // 这里假设相位差的范围是-360到360度
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            phase_diff <= 16'b0;
            m_phase_done <= 0;
        end else begin
            phase_diff <= (phase_accum * 360) / (1 << 16); // 16位 phase_diff 的映射
            m_phase_done <= 1;
        end
    end


endmodule
